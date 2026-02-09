import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  double discount = 0.0;
  String? appliedCoupon;

  void applyCoupon(double total) async {
    var result = await ApiService().validateCoupon(_couponController.text, total);
    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'])));
    } else {
      setState(() {
        appliedCoupon = result['code'];
        if (result['discount_type'] == 'flat') {
          discount = double.parse(result['discount_value'].toString());
        } else {
          discount = total * (double.parse(result['discount_value'].toString()) / 100);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Coupon Applied!")));
    }
  }

  void processOrder(CartProvider cart, AuthProvider auth) async {
    if (!auth.isAuthenticated && (_nameController.text.isEmpty || _emailController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter Guest Details")));
      return;
    }

    List items = cart.items.values.map((i) => {
      "product_id": i.product.id,
      "quantity": i.quantity
    }).toList();

    Map<String, dynamic> orderData = {
      "full_name": auth.isAuthenticated ? auth.token : _nameController.text, // Simple logic for name
      "email": auth.isAuthenticated ? "user@test.com" : _emailController.text,
      "items": items,
      "coupon_code": appliedCoupon ?? ""
    };

    var result = await ApiService().placeOrder(orderData, auth.token);
    if (result.containsKey('order_id')) {
      cart.clearCart();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Success!"),
          content: Text("Order #${result['order_id']} placed successfully."),
          actions: [TextButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), child: Text("OK"))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    double total = cart.totalAmount;
    double finalPayable = total - discount;

    return Scaffold(
      appBar: AppBar(title: Text("My Cart")),
      body: cart.items.isEmpty
        ? Center(child: Text("Cart is empty"))
        : ListView(
            padding: EdgeInsets.all(10),
            children: [
              ...cart.items.values.map((item) => ListTile(
                title: Text(item.product.name),
                subtitle: Text("${item.quantity} x \$${item.product.price}"),
                trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => cart.removeItem(item.product.id)),
              )).toList(),
              Divider(),
              if (!auth.isAuthenticated) ...[
                TextField(controller: _nameController, decoration: InputDecoration(labelText: "Full Name")),
                TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
              ],
              Row(
                children: [
                  Expanded(child: TextField(controller: _couponController, decoration: InputDecoration(labelText: "Coupon Code"))),
                  ElevatedButton(onPressed: () => applyCoupon(total), child: Text("Apply")),
                ],
              ),
              SizedBox(height: 20),
              Text("Total: \$${total.toStringAsFixed(2)}"),
              Text("Discount: -\$${discount.toStringAsFixed(2)}", style: TextStyle(color: Colors.red)),
              Text("Final: \$${finalPayable.toStringAsFixed(2)}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: Size(double.infinity, 50)),
                onPressed: () => processOrder(cart, auth),
                child: Text("PLACE ORDER", style: TextStyle(color: Colors.white))
              ),
            ],
          ),
    );
  }
}
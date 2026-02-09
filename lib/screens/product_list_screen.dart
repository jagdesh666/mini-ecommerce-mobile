import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart'; // Naya import
import '../services/api_service.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart'; // Naya import
import 'cart_screen.dart'; // Naya import

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).fetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context); // Cart ka data lene ke liye

    return Scaffold(
      appBar: AppBar(
        title: Text("Mini E-Commerce", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Login / Profile Icon
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          // Cart Icon with Badge (Items count dikhane ke liye)
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
              if (cartProvider.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cartProvider.items.length}',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: productProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: productProvider.products.length,
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 3,
                  child: ListTile(
                    leading: product.image != null
                        ? Image.network(
                            "${ApiService.mediaBaseUrl}${product.image}",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                          )
                        : Icon(Icons.shopping_bag, size: 50),
                    title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("\$${product.price}", style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Stock: ${product.stock}"),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      // Detail Screen par jane ke liye
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
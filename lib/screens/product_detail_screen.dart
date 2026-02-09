import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            product.image != null
                ? Image.network("${ApiService.mediaBaseUrl}${product.image}", width: double.infinity, height: 300, fit: BoxFit.cover)
                : Container(height: 300, color: Colors.grey, child: Icon(Icons.image, size: 100)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("\$${product.price}", style: TextStyle(fontSize: 20, color: Colors.green)),
                  SizedBox(height: 10),
                  Text(product.description),
                  SizedBox(height: 20),
                  Text("Available Stock: ${product.stock}"),
                  SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Colors.orange),
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(product);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added to Cart!")));
                    },
                    child: Text("Add to Cart", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
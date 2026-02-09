import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  // Edge Browser ke liye 127.0.0.1
  static const String baseUrl = "http://127.0.0.1:8000/api";
  static const String mediaBaseUrl = "http://127.0.0.1:8000";

  // 1. Products mangwane ke liye
  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Product.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // 2. Coupon check karne ke liye
  Future<Map<String, dynamic>> validateCoupon(String code, double cartValue) async {
    final response = await http.post(
      Uri.parse('$baseUrl/validate-coupon/'),
      body: json.encode({"code": code, "cart_value": cartValue}),
      headers: {"Content-Type": "application/json"},
    );
    return json.decode(response.body);
  }

  // 3. Order place karne ke liye
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> orderData, String? token) async {
    Map<String, String> headers = {"Content-Type": "application/json"};
    if (token != null) {
      headers["Authorization"] = "Token $token";
    }

    final response = await http.post(
      Uri.parse('$baseUrl/place-order/'),
      body: json.encode(orderData),
      headers: headers,
    );
    return json.decode(response.body);
  }
} // Is bracket ka masla tha
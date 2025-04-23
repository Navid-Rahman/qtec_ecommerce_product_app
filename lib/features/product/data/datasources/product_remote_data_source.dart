import 'dart:convert';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts(int page);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;
  final Connectivity connectivity;
  final Box<ProductModel> productBox;

  ProductRemoteDataSourceImpl({
    required this.client,
    required this.connectivity,
    required this.productBox,
  });

  @override
  Future<List<ProductModel>> getProducts(int page) async {
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      final cachedProducts = productBox.values.toList();
      if (cachedProducts.isNotEmpty) {
        developer.log(
          'Fetching products from Hive cache (page: $page)',
          name: 'ProductRemoteDataSource',
        );
        return cachedProducts;
      }
      throw ServerException('No internet connection and no cached data');
    }

    developer.log(
      'Fetching products from API (page: $page)',
      name: 'ProductRemoteDataSource',
    );
    final response = await client.get(
      Uri.parse('https://fakestoreapi.com/products'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final products =
          jsonList.map((json) => ProductModel.fromJson(json)).toList();
      for (var product in products) {
        await productBox.put(product.id, product);
      }
      developer.log(
        'Successfully fetched and cached ${products.length} products',
        name: 'ProductRemoteDataSource',
      );
      return products;
    } else {
      throw ServerException('Failed to fetch products');
    }
  }
}

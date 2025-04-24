import 'dart:convert';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<(List<ProductModel>, bool, int?)> getProducts(int page);
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
  Future<(List<ProductModel>, bool, int?)> getProducts(int page) async {
    const int pageSize = 10;
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      final cachedProducts = productBox.values.toList();
      if (cachedProducts.isNotEmpty) {
        developer.log(
          'Fetching products from Hive cache (page: $page)',
          name: 'ProductRemoteDataSource',
        );

        final startIndex = (page - 1) * pageSize;
        final endIndex = startIndex + pageSize;
        final paginatedProducts = cachedProducts.sublist(
          startIndex,
          endIndex > cachedProducts.length ? cachedProducts.length : endIndex,
        );
        return (paginatedProducts, true, null);
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
      final List<ProductModel> products =
          jsonList
              .map((json) => ProductModel.fromJson(json))
              .toList()
              .cast<ProductModel>();
      for (var product in products) {
        await productBox.put(product.id, product);
      }

      final startIndex = (page - 1) * pageSize;
      if (startIndex >= products.length) {
        developer.log(
          'No more products to fetch (page: $page)',
          name: 'ProductRemoteDataSource',
        );
        return (<ProductModel>[], false, products.length);
      }
      final endIndex = startIndex + pageSize;
      final paginatedProducts = products.sublist(
        startIndex,
        endIndex > products.length ? products.length : endIndex,
      );
      developer.log(
        'Successfully fetched ${paginatedProducts.length} products for page $page, total: ${products.length}',
        name: 'ProductRemoteDataSource',
      );
      return (paginatedProducts, false, products.length);
    } else {
      throw ServerException('Failed to fetch products');
    }
  }
}

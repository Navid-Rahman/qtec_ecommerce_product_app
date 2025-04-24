import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;
  List<Product> allProducts = [];

  ProductBloc({required this.getProducts}) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<SearchProducts>(_onSearchProducts);
    on<SortProducts>(_onSortProducts);
  }

  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductInitial || event.page == 1) {
      emit(ProductLoading());
      final result = await getProducts(event.page);
      result.fold((failure) => emit(ProductError(failure.message)), (data) {
        final (products, isCached) = data;
        allProducts = products;
        emit(
          ProductLoaded(
            products: products,
            hasReachedMax: products.isEmpty,
            isCachedData: isCached,
          ),
        );
      });
    } else {
      final result = await getProducts(event.page);
      result.fold((failure) => emit(ProductError(failure.message)), (data) {
        final (products, isCached) = data;
        allProducts.addAll(products);
        emit(
          ProductLoaded(
            products: allProducts,
            hasReachedMax: products.isEmpty,
            isCachedData: isCached,
          ),
        );
      });
    }
  }

  void _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) {
    if (event.query.isEmpty) {
      emit(ProductLoaded(products: allProducts));
    } else {
      final filteredProducts =
          allProducts
              .where(
                (product) => product.title.toLowerCase().contains(
                  event.query.toLowerCase(),
                ),
              )
              .toList();
      emit(ProductLoaded(products: filteredProducts));
    }
  }

  void _onSortProducts(SortProducts event, Emitter<ProductState> emit) {
    developer.log(
      'Processing SortProducts event with sortBy: ${event.sortBy}',
      name: 'ProductBloc',
    );
    final currentState = state;
    if (currentState is ProductLoaded) {
      final sortedProducts = List<Product>.from(currentState.products);
      if (event.sortBy == 'price_low_high') {
        sortedProducts.sort((a, b) => a.price.compareTo(b.price));
      } else if (event.sortBy == 'price_high_low') {
        sortedProducts.sort((a, b) => b.price.compareTo(a.price));
      } else if (event.sortBy == 'rating') {
        sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
      }
      developer.log('Sorted products by ${event.sortBy}', name: 'ProductBloc');
      emit(ProductLoaded(products: sortedProducts));
    }
  }
}

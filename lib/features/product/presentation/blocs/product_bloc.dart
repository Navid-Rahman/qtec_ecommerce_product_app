import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;
  List<Product> allProducts = [];
  bool hasReachedMax = false;
  int? totalProductCount;

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
      developer.log('Fetching page ${event.page}', name: 'ProductBloc');
      emit(ProductLoading());
      final result = await getProducts(event.page);
      result.fold(
        (failure) {
          developer.log(
            'Error fetching page ${event.page}: ${failure.message}',
            name: 'ProductBloc',
          );
          emit(ProductError(failure.message));
        },
        (data) {
          final (products, isCached, total) = data;
          allProducts = products;
          totalProductCount = total;
          hasReachedMax =
              products.isEmpty ||
              (total != null && allProducts.length >= total);
          developer.log(
            'Emitting ProductLoaded for page ${event.page}: ${products.length} products, hasReachedMax: $hasReachedMax, total: ${allProducts.length}, totalCount: $totalProductCount',
            name: 'ProductBloc',
          );
          emit(
            ProductLoaded(
              products: products,
              hasReachedMax: hasReachedMax,
              isCachedData: isCached,
            ),
          );
        },
      );
    } else if (!hasReachedMax) {
      developer.log('Fetching page ${event.page}', name: 'ProductBloc');
      final result = await getProducts(event.page);
      result.fold(
        (failure) {
          developer.log(
            'Error fetching page ${event.page}: ${failure.message}',
            name: 'ProductBloc',
          );
          emit(ProductError(failure.message));
        },
        (data) {
          final (products, isCached, total) = data;
          allProducts.addAll(products);
          totalProductCount = total ?? totalProductCount;
          hasReachedMax =
              products.isEmpty ||
              (totalProductCount != null &&
                  allProducts.length >= totalProductCount!);
          developer.log(
            'Emitting ProductLoaded for page ${event.page}: ${products.length} new products, hasReachedMax: $hasReachedMax, total: ${allProducts.length}, totalCount: $totalProductCount',
            name: 'ProductBloc',
          );
          emit(
            ProductLoaded(
              products: allProducts,
              hasReachedMax: hasReachedMax,
              isCachedData: isCached,
            ),
          );
        },
      );
    } else {
      developer.log(
        'Skipping fetch for page ${event.page}: hasReachedMax is true',
        name: 'ProductBloc',
      );
    }
  }

  void _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) {
    developer.log('Searching with query: ${event.query}', name: 'ProductBloc');
    if (event.query.isEmpty) {
      emit(
        ProductLoaded(
          products: allProducts,
          hasReachedMax: hasReachedMax,
          isCachedData:
              state is ProductLoaded && (state as ProductLoaded).isCachedData,
        ),
      );
    } else {
      final filteredProducts =
          allProducts
              .where(
                (product) => product.title.toLowerCase().contains(
                  event.query.toLowerCase(),
                ),
              )
              .toList();
      emit(
        ProductLoaded(
          products: filteredProducts,
          hasReachedMax: hasReachedMax,
          isCachedData:
              state is ProductLoaded && (state as ProductLoaded).isCachedData,
        ),
      );
    }
  }

  void _onSortProducts(SortProducts event, Emitter<ProductState> emit) {
    developer.log('Sorting by: ${event.sortBy}', name: 'ProductBloc');
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
      emit(
        ProductLoaded(
          products: sortedProducts,
          hasReachedMax: hasReachedMax,
          isCachedData: currentState.isCachedData,
        ),
      );
    }
  }
}

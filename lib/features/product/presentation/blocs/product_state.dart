// features/product/presentation/blocs/product_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final bool hasReachedMax;
  final bool isCachedData;
  final String searchQuery;

  const ProductLoaded({
    required this.products,
    this.hasReachedMax = false,
    this.isCachedData = false,
    this.searchQuery = '',
  });

  @override
  List<Object> get props => [
    products,
    hasReachedMax,
    isCachedData,
    searchQuery,
  ];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}

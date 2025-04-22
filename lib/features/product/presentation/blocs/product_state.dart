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

  const ProductLoaded({required this.products, this.hasReachedMax = false});

  @override
  List<Object> get props => [products, hasReachedMax];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}

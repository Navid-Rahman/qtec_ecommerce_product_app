import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class FetchProducts extends ProductEvent {
  final int page;

  const FetchProducts(this.page);

  @override
  List<Object> get props => [page];
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object> get props => [query];
}

class SortProducts extends ProductEvent {
  final String sortBy;

  const SortProducts(this.sortBy);

  @override
  List<Object> get props => [sortBy];
}

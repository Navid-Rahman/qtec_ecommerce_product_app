import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts implements UseCase<(List<Product>, bool), int> {
  final ProductRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, (List<Product>, bool)>> call(int page) async {
    return await repository.getProducts(page);
  }
}

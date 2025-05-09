import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, (List<Product>, bool, int?)>> getProducts(
    int page,
  ) async {
    try {
      final (remoteProducts, isCached, totalCount) = await remoteDataSource
          .getProducts(page);
      return Right((remoteProducts, isCached, totalCount));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}

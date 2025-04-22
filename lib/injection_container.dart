import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'features/product/data/datasources/product_remote_data_source.dart';
import 'features/product/data/models/product_model.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/domain/usecases/get_products.dart';
import 'features/product/presentation/blocs/product_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());

  // Hive
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  final productBox = await Hive.openBox<ProductModel>('products');
  sl.registerLazySingleton<Box<ProductModel>>(() => productBox);

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(
      client: sl(),
      connectivity: sl(),
      productBox: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProducts(sl()));

  // Blocs
  sl.registerFactory(() => ProductBloc(getProducts: sl()));
}

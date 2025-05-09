import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/product/data/models/product_model.dart';
import 'features/product/presentation/blocs/product_bloc.dart' as di;
import 'features/product/presentation/pages/home_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive first
  await Hive.initFlutter();
  // Register adapter
  Hive.registerAdapter(ProductModelAdapter());
  // Then initialize dependencies
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce Product App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: BlocProvider(
        create: (context) => di.sl<di.ProductBloc>(),
        child: const HomePage(),
      ),
    );
  }
}

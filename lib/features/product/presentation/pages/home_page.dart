import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/product_bloc.dart';
import '../blocs/product_event.dart';
import '../blocs/product_state.dart';
import '../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(FetchProducts(_currentPage));
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _currentPage++;
      context.read<ProductBloc>().add(FetchProducts(_currentPage));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose(); // Fixed missing parentheses here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Listing'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              context.read<ProductBloc>().add(SortProducts(value));
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'price_low_high',
                    child: Text('Price: Low to High'),
                  ),
                  const PopupMenuItem(value: 'rating', child: Text('Rating')),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                context.read<ProductBloc>().add(SearchProducts(value));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading && _currentPage == 1) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductLoaded) {
                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount:
                        state.hasReachedMax
                            ? state.products.length
                            : state.products.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= state.products.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ProductCard(product: state.products[index]);
                    },
                  );
                } else if (state is ProductError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text('No products found'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

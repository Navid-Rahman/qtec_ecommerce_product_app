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
    super.dispose();
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<ProductBloc>(),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: const Text('Price: Low to High'),
                  onTap: () {
                    context.read<ProductBloc>().add(
                      const SortProducts('price_low_high'),
                    );
                    Navigator.pop(bottomSheetContext);
                  },
                ),
                ListTile(
                  title: const Text('Price: High to Low'),
                  onTap: () {
                    context.read<ProductBloc>().add(
                      const SortProducts('price_high_low'),
                    );
                    Navigator.pop(bottomSheetContext);
                  },
                ),
                ListTile(
                  title: const Text('Rating'),
                  onTap: () {
                    context.read<ProductBloc>().add(
                      const SortProducts('rating'),
                    );
                    Navigator.pop(bottomSheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
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
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: () => _showSortBottomSheet(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<ProductBloc, ProductState>(
                listener: (context, state) {
                  if (state is ProductLoaded && state.isCachedData) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Offline: Showing cached data'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else if (state is ProductError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
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
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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
      ),
    );
  }
}

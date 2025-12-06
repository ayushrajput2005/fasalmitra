import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fasalmitra/screens/phone_login.dart';
import 'package:fasalmitra/screens/create_listing_screen.dart';
import 'package:fasalmitra/screens/marketplace_screen.dart';
import 'package:fasalmitra/screens/my_orders_screen.dart';
import 'package:fasalmitra/screens/register_screen.dart';
import 'package:fasalmitra/services/auth_service.dart';
import 'package:fasalmitra/services/font_size_service.dart';
import 'package:fasalmitra/widgets/home/home_navbar.dart';
import 'package:fasalmitra/widgets/home/secondary_navbar.dart';
import 'package:fasalmitra/widgets/home/banner_carousel.dart';
import 'package:fasalmitra/widgets/home/feature_card_grid.dart';
import 'package:fasalmitra/widgets/home/home_footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/homepage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: FontSizeService.instance.listenable,
      builder: (context, fontSizeScale, _) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(fontSizeScale)),
          child: Scaffold(
            body: Column(
              children: [
                HomeNavbar(
                  onLogin: () {
                    Navigator.of(context).pushNamed(LoginScreen.routeName);
                  },
                  onRegister: () {
                    Navigator.of(context).pushNamed(RegisterScreen.routeName);
                  },
                  onAboutUs: () {
                    // TODO: Navigate to about us page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('About Us coming soon')),
                    );
                  },
                  onCustomerCare: () {
                    // TODO: Navigate to customer care page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Customer Care coming soon'),
                      ),
                    );
                  },
                ),
                SecondaryNavbar(
                  onListProduct: _handleListProduct,
                  onMarketplace: _handleMarketplace,
                  onRecentListings: _handleRecentListings,
                  onSearchByCategory: _handleSearchByCategory,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BannerCarousel(),
                        const SizedBox(height: 32),
                        FeatureCardGrid(
                          onSeedPriceMarket: _handleSeedPriceMarket,
                          onSellOilseed: _handleListProduct,
                          onBuyOilseed: _handleMarketplace,
                          onMyOrders: _handleMyOrders,
                          onOrderTracking: _handleOrderTracking,
                          onSearchOilSeed: _handleSearchOilSeed,
                          onRecentPost: _handleRecentPost,
                        ),
                        const SizedBox(height: 64),
                        HomeFooter(
                          onSeedPriceMarket: _handleSeedPriceMarket,
                          onSellOilseed: _handleListProduct,
                          onBuyOilseed: _handleMarketplace,
                          onMyOrders: _handleMyOrders,
                          onOrderTracking: _handleOrderTracking,
                          onSearchOilSeed: _handleSearchOilSeed,
                          onRecentPost: _handleRecentPost,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // TODO: Implement help/chat functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help feature coming soon')),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.help_outline, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void _handleListProduct() {
    final user = AuthService.instance.cachedUser;
    if (user == null) {
      Navigator.of(context).pushNamed(LoginScreen.routeName);
    } else {
      Navigator.of(context).pushNamed(CreateListingScreen.routeName);
    }
  }

  void _handleMarketplace() {
    Navigator.of(context).pushNamed(MarketplaceScreen.routeName);
  }

  void _handleRecentListings() {
    Navigator.of(context).pushNamed(
      MarketplaceScreen.routeName,
      arguments: {'sort': 'date_recent'},
    );
  }

  void _handleSearchByCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCategoryTile('Seeds'),
                _buildCategoryTile('Grains'),
                _buildCategoryTile('Vegetables'),
                _buildCategoryTile('Fruits'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryTile(String category) {
    return ListTile(
      leading: Icon(
        _getCategoryIcon(category),
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(category),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context); // Close dialog
        Navigator.of(context).pushNamed(
          MarketplaceScreen.routeName,
          arguments: {'category': category},
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Seeds':
        return Icons.eco;
      case 'Grains':
        return Icons.grain;
      case 'Vegetables':
        return Icons.local_florist;
      case 'Fruits':
        return Icons.apple;
      default:
        return Icons.category;
    }
  }

  void _handleSeedPriceMarket() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seed Price Market coming soon')),
    );
  }

  void _handleSearchOilSeed() {
    Navigator.of(context).pushNamed(
      MarketplaceScreen.routeName,
      arguments: {'focusSearch': true, 'category': 'Seeds'},
    );
  }

  Future<void> _handleRecentPost() async {
    const url = 'https://fasalmitra.com/blog';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not launch blog')));
      }
    }
  }

  void _handleMyOrders() {
    final user = AuthService.instance.cachedUser;
    if (user == null) {
      Navigator.of(context).pushNamed(LoginScreen.routeName);
    } else {
      Navigator.of(context).pushNamed(MyOrdersScreen.routeName);
    }
  }

  void _handleOrderTracking() {
    final user = AuthService.instance.cachedUser;
    if (user == null) {
      Navigator.of(context).pushNamed(LoginScreen.routeName);
    } else {
      // Navigate to My Orders layout which shows tracking status
      Navigator.of(context).pushNamed(MyOrdersScreen.routeName);
    }
  }
}

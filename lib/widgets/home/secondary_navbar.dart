import 'package:flutter/material.dart';
import 'package:fasalmitra/widgets/hoverable.dart';

class SecondaryNavbar extends StatelessWidget {
  const SecondaryNavbar({
    super.key,
    required this.onListProduct,
    required this.onMarketplace,
    required this.onRecentListings,
    required this.onSearchByCategory,
  });

  final VoidCallback onListProduct;
  final VoidCallback onMarketplace;
  final VoidCallback onRecentListings;
  final VoidCallback onSearchByCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            icon: Icons.add_circle_outline,
            label: 'Sell',
            onTap: onListProduct,
            color: theme.colorScheme.primary,
          ),
          _buildNavItem(
            context,
            icon: Icons.storefront_outlined,
            label: 'Buy',
            onTap: onMarketplace,
            color: theme.colorScheme.primary,
          ),
          _buildNavItem(
            context,
            icon: Icons.new_releases_outlined,
            label: 'New',
            onTap: onRecentListings,
            color: theme.colorScheme.primary,
          ),
          _buildNavItem(
            context,
            icon: Icons.category_outlined,
            label: 'Categories',
            onTap: onSearchByCategory,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Hoverable(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

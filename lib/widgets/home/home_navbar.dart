import 'package:flutter/material.dart';
import 'package:fasalmitra/widgets/language_selector.dart';
import 'package:fasalmitra/services/font_size_service.dart';
import 'package:fasalmitra/services/language_service.dart';
import 'package:fasalmitra/widgets/hoverable.dart';

class HomeNavbar extends StatelessWidget {
  const HomeNavbar({
    super.key,
    this.onLogin,
    this.onRegister,
    this.onAboutUs,
    this.onCustomerCare,
  });

  final VoidCallback? onLogin;
  final VoidCallback? onRegister;
  final VoidCallback? onAboutUs;
  final VoidCallback? onCustomerCare;

  @override
  Widget build(BuildContext context) {
    final fontSize = FontSizeService.instance;
    final lang = LanguageService.instance;
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Logo
            Text(
              'FasalMitra',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),

            // Links
            if (MediaQuery.of(context).size.width > 600) ...[
              Hoverable(
                child: TextButton(
                  onPressed: onAboutUs,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: Text(lang.t('aboutUs')),
                ),
              ),
              Hoverable(
                child: TextButton(
                  onPressed: onCustomerCare,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: Text(lang.t('customerCare')),
                ),
              ),
            ],

            // Font size controls
            ValueListenableBuilder<double>(
              valueListenable: fontSize.listenable,
              builder: (context, scale, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: fontSize.decrease,
                      icon: const Icon(Icons.remove, color: Colors.white),
                      tooltip: 'Decrease font size',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    Text(
                      'A',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    IconButton(
                      onPressed: fontSize.increase,
                      icon: const Icon(Icons.add, color: Colors.white),
                      tooltip: 'Increase font size',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(width: 8),

            // Language selector
            LanguageSelector(
              compact: true,
              iconColor: Colors.white,
              textColor: Colors.white,
            ),

            const SizedBox(width: 8),

            // Login button
            Hoverable(
              child: OutlinedButton(
                onPressed: onLogin,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                child: Text(lang.t('login')),
              ),
            ),

            const SizedBox(width: 8),

            // Register button (highlighted)
            Hoverable(
              child: FilledButton(
                onPressed: onRegister,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                ),
                child: Text(lang.t('register')),
              ),
            ),

            const SizedBox(width: 8),

            // Cart Icon
            Hoverable(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/cart');
                },
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                tooltip: 'Cart',
              ),
            ),

            // Profile Icon
            Hoverable(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/account');
                },
                icon: const Icon(Icons.person, color: Colors.white),
                tooltip: 'Account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

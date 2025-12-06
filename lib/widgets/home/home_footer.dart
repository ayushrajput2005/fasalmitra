import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fasalmitra/services/language_service.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({
    super.key,
    this.onSeedPriceMarket,
    this.onSellOilseed,
    this.onBuyOilseed,
    this.onMyOrders,
    this.onOrderTracking,
    this.onSearchOilSeed,
    this.onRecentPost,
  });

  final VoidCallback? onSeedPriceMarket;
  final VoidCallback? onSellOilseed;
  final VoidCallback? onBuyOilseed;
  final VoidCallback? onMyOrders;
  final VoidCallback? onOrderTracking;
  final VoidCallback? onSearchOilSeed;
  final VoidCallback? onRecentPost;

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final footerColor = const Color(0xFF202421);
    final textColor = Colors.white;

    return Container(
      color: footerColor,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildMenuSection(lang, textColor)),
                const SizedBox(width: 32),
                Expanded(child: _buildUsefulWebsitesSection(lang, textColor)),
                const SizedBox(width: 32),
                Expanded(child: _buildLogosSection(isWide: true)),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMenuSection(lang, textColor),
                const SizedBox(height: 32),
                _buildUsefulWebsitesSection(lang, textColor),
                const SizedBox(height: 32),
                _buildLogosSection(isWide: false),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildMenuSection(LanguageService lang, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('menu').toUpperCase(),
          style: TextStyle(
            color: textColor.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuLink(lang.t('seedPriceMarket'), onSeedPriceMarket, textColor),
        _buildMenuLink(lang.t('sellOilseed'), onSellOilseed, textColor),
        _buildMenuLink(lang.t('buyOilseed'), onBuyOilseed, textColor),
        _buildMenuLink(lang.t('myOrders'), onMyOrders, textColor),
        _buildMenuLink(lang.t('orderTracking'), onOrderTracking, textColor),
        _buildMenuLink(lang.t('searchOilSeed'), onSearchOilSeed, textColor),
        _buildMenuLink(lang.t('recentPost'), onRecentPost, textColor),
      ],
    );
  }

  Widget _buildMenuLink(String text, VoidCallback? onTap, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: textColor.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  Widget _buildUsefulWebsitesSection(LanguageService lang, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('usefulWebsites').toUpperCase(),
          style: TextStyle(
            color: textColor.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildExternalLink(
          lang.t('pmKisan'),
          'https://pmkisan.gov.in/',
          textColor,
        ),
        _buildExternalLink(
          lang.t('pmFasalBima'),
          'https://pmfby.gov.in/',
          textColor,
        ),
        _buildExternalLink(lang.t('enam'), 'https://enam.gov.in/', textColor),
        _buildExternalLink(
          lang.t('soilHealth'),
          'https://soilhealth.dac.gov.in/',
          textColor,
        ),
      ],
    );
  }

  Widget _buildExternalLink(String text, String url, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Text(
          text,
          style: TextStyle(
            color: textColor.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  Widget _buildLogosSection({required bool isWide}) {
    return Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            'assets/images/digital_india.png',
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: isWide
              ? MainAxisAlignment.end
              : MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/emblem.png',
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/sih.png',
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

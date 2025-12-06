import 'package:fasalmitra/services/api.dart';
import 'package:fasalmitra/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ListingData {
  const ListingData({
    required this.id,
    required this.title,
    required this.price,
    required this.priceUnit,
    this.description,
    this.imageUrls = const [],
    this.sellerId,
    this.sellerName,
    this.farmerProfileImage,
    this.category,
    this.type,
    this.rating,
    this.certificateGrade,
    this.certificateUrl,
    this.isCertified = false,
    this.processingDate,
    this.quantity,
    this.quantityUnit,
    this.distance,
    this.location,
    this.quality,
  });

  factory ListingData.fromJson(Map<String, dynamic> json) {
    // Helper to handle diverse API types (string vs double)
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    // Handle Image URL: API returns relative path like "/media/..."
    // We need to prepend base URL if it's relative.
    // For now, assuming ApiService has the base URL logic or we duplicate it.
    // Ideally we pass full URL from service, but here we construct it.
    String resolveUrl(String? path) {
      if (path == null || path.isEmpty) return '';
      if (path.startsWith('http')) return path;
      return 'http://localhost:8000$path'; // Using standard localhost from doc notes
    }

    return ListingData(
      id: json['id'].toString(), // API returns int ID
      title: json['product_name'] ?? json['title'] ?? 'Unknown Product',
      price: parseDouble(
        json['price_per_kg'] ?? json['market_price_per_kg_inr'],
      ),
      priceUnit: '/kg',
      description: null, // API doesn't have description
      imageUrls: json['image'] != null ? [resolveUrl(json['image'])] : [],
      sellerId: json['owner']
          ?.toString(), // owner is ID or username depending on endpoint
      sellerName: json['owner']?.toString(), // using same for name
      farmerProfileImage: null,
      category: json['type'] == 'seeds'
          ? 'Seeds'
          : 'Byproduct', // Map type to category or keep as type
      type: json['type'],
      rating: null,
      certificateGrade: null, // could map 'quality' here?
      certificateUrl: resolveUrl(json['certificate']),
      isCertified: json['certificate'] != null,
      processingDate: json['date_of_listing'] != null
          ? DateTime.tryParse(json['date_of_listing']) ?? DateTime.now()
          : json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      quantity: parseDouble(json['amount_kg']),
      quantityUnit: 'kg',
      distance: null, // API doesn't give distance yet
      location: json['location'],
      quality: json['quality'],
    );
  }

  final String id;
  final String title;
  final double price;
  final String priceUnit;
  final String? description;
  final List<String> imageUrls;
  final String? sellerId;
  final String? sellerName;
  final String? farmerProfileImage;
  final String? category;
  final String? type;
  final double? rating;
  final String? certificateGrade;
  final String? certificateUrl;
  final bool isCertified;
  final DateTime? processingDate;
  final double? quantity;
  final String? quantityUnit;
  final double? distance;
  final String? location;
  final String? quality;
}

class ListingService {
  ListingService._();

  static final ListingService instance = ListingService._();

  Future<List<ListingData>> getRecentListings({int limit = 10}) async {
    // Fetch from market API and just take first few
    final listings = await getMarketplaceListings();
    if (listings.length > limit) {
      return listings.sublist(0, limit);
    }
    return listings;
  }

  Future<List<ListingData>> getListingsByCategory(String category) async {
    // Naive implementation: fetch all and filter client side
    // OR create mapping: "Seeds" -> /market/seeds/, "Byproduct" -> /market/byproducts/
    if (category.toLowerCase() == 'seeds') {
      return _fetchFromEndpoint('/market/seeds/');
    } else if (category.toLowerCase() == 'byproduct') {
      return _fetchFromEndpoint('/market/byproducts/');
    }
    return getMarketplaceListings(); // Fallback
  }

  Future<List<ListingData>> getMarketplaceListings({
    String sortBy = 'distance',
    String? categoryFilter,
    String? searchQuery,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      // 1. Fetch from both endpoints
      final seeds = await _fetchFromEndpoint('/market/seeds/');
      final byproducts = await _fetchFromEndpoint('/market/byproducts/');

      var listings = [...seeds, ...byproducts];

      // 2. Filter Client Side (since API doesn't support query params yet per doc)
      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        // Map category filter strings
        final filterLower = categoryFilter.toLowerCase();
        listings = listings
            .where(
              (l) =>
                  (l.category?.toLowerCase() == filterLower) ||
                  (l.type?.toLowerCase() == filterLower),
            )
            .toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        listings = listings
            .where((l) => l.title.toLowerCase().contains(query))
            .toList();
      }

      // 3. Sort
      switch (sortBy) {
        case 'price_high':
          listings.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'price_low':
          listings.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'date_recent':
          // ... sorting logic ...
          break;
      }

      return listings;
    } catch (e) {
      print('Error fetching marketplace listings: $e');
      return [];
    }
  }

  Future<List<ListingData>> _fetchFromEndpoint(String path) async {
    try {
      final encodedToken = AuthService.instance.token;
      final response = await ApiService.instance.get(path, token: encodedToken);

      if (response['success'] != null) {
        final list = response['success']['body'] as List;
        return list.map((item) => ListingData.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Fetch error $path: $e');
      return [];
    }
  }

  Future<void> createListing({
    required String title,
    required String
    category, // 'Seeds' or 'Byproduct' to mapped to 'seeds'/'byproduct'
    required double quantity,
    required double price,
    required DateTime processingDate,
    required String certificatePath,
    required String imagePath,
    required String location,
  }) async {
    final token = AuthService.instance.token;
    if (token == null) throw Exception('User not logged in');

    // Map fields to API request
    // type: 'seeds' or 'byproduct'
    final type = category.toLowerCase().contains('seed')
        ? 'seeds'
        : 'byproduct';
    // quality: hardcoded to 'good' or passed? arguments didn't have quality. I'll default.

    // Prepare files
    List<http.MultipartFile> files = [];
    if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
      files.add(await http.MultipartFile.fromPath('image', imagePath));
    }
    if (certificatePath.isNotEmpty && !certificatePath.startsWith('http')) {
      files.add(
        await http.MultipartFile.fromPath('certificate', certificatePath),
      );
    }

    final fields = {
      'type': type,
      'product_name': title,
      'date_of_listing': processingDate.toIso8601String().split(
        'T',
      )[0], // YYYY-MM-DD
      'amount_kg': quantity.toString(),
      'market_price_per_kg_inr': price.toString(),
      'location': location,
      'quality': 'good', // Defaulting as UI doesn't allow selection yet
    };

    await ApiService.instance.multipartRequest(
      'POST',
      '/create/',
      fields: fields,
      files: files,
      token: token,
    );
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    // API Documentation does not specifically list an update endpoint.
    // Assuming unsupported or out of scope for this migration task.
    // Leaving empty or throwing error.
    throw UnimplementedError('Update listing not supported in API v1');
  }

  Future<void> deleteListing(String id) async {
    // API Doc doesn't list delete.
    throw UnimplementedError('Delete listing not supported in API v1');
  }

  Future<List<ListingData>> fetchListingsByUser(String userId) async {
    try {
      // Ignore userId arg, API uses token to identify user
      final seeds = await _fetchFromEndpoint('/seed/');
      final byproducts = await _fetchFromEndpoint('/byproduct/');
      return [...seeds, ...byproducts];
    } catch (e) {
      return [];
    }
  }
}

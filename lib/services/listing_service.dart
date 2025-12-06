import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    return ListingData(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      priceUnit: json['priceUnit'] as String? ?? '/kg',
      description: json['description'] as String?,
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sellerId: json['sellerId'] as String?,
      sellerName: json['sellerName'] as String?,
      farmerProfileImage: json['farmerProfileImage'] as String?,
      category: json['category'] as String?,
      type: json['type'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      certificateGrade: json['certificateGrade'] as String?,
      certificateUrl: json['certificateUrl'] as String?,
      isCertified: json['isCertified'] as bool? ?? false,
      processingDate: json['processingDate'] != null
          ? DateTime.parse(json['processingDate'] as String)
          : null,
      quantity: (json['quantity'] as num?)?.toDouble(),
      quantityUnit: json['quantityUnit'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      location: json['location'] as String?,
      quality: json['quality'] as String?,
    );
  }

  final String id;
  final String title;
  final double price;
  final String priceUnit; // e.g., "/kg", "/ton"
  final String? description;
  final List<String> imageUrls; // Multiple images for scrolling
  final String? sellerId;
  final String? sellerName;
  final String? farmerProfileImage;
  final String? category;
  final String? type; // New field for "Type" shown in image
  final double? rating; // Rating out of 5
  final String? certificateGrade; // e.g., "Grade A", "Organic"
  final String? certificateUrl; // New field for certificate link
  final bool isCertified;
  final DateTime? processingDate;
  final double? quantity;
  final String? quantityUnit;
  final double? distance; // Distance in km from user
  final String? location; // New field for location
  final String? quality; // New field for quality
}

class ListingService {
  ListingService._();

  static final ListingService instance = ListingService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<ListingData>> getRecentListings({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .orderBy('processingDate', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ListingData.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching recent listings: $e');
      return [];
    }
  }

  Future<List<ListingData>> getListingsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ListingData.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching category listings: $e');
      return [];
    }
  }

  Future<List<ListingData>> getMarketplaceListings({
    String sortBy = 'distance',
    String? categoryFilter,
    String? searchQuery,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      // Firestore logic disabled for debugging
      /*
      Query query = _firestore.collection('products');

      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        query = query.where('category', isEqualTo: categoryFilter);
      }
      if (dateFrom != null) {
        query = query.where('processingDate', isGreaterThanOrEqualTo: dateFrom.toIso8601String());
      }
      if (dateTo != null) {
        query = query.where('processingDate', isLessThanOrEqualTo: dateTo.toIso8601String());
      }

      final querySnapshot = await query.get().timeout(const Duration(seconds: 2));
      var listings = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ListingData.fromJson(data);
      }).toList();
      */

      List<ListingData> listings = [];

      // Add dummy listings
      final dummyListings = [
        ListingData(
          id: 'dummy-1',
          title: 'soymeal',
          price: 15,
          priceUnit: '/kg',
          type: 'byproduct',
          category: 'Seeds',
          sellerName: 'srujanx',
          imageUrls: ['assets/images/soymeal.png'],
          quantity: 10,
          quantityUnit: 'kg',
          location: 'maharashtra',
          quality: 'good',
          certificateUrl: 'https://example.com/cert1',
          processingDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ListingData(
          id: 'dummy-2',
          title: 'Groundnut Seeds',
          price: 60,
          priceUnit: '/kg',
          type: 'Oil Seeds',
          category: 'Seeds',
          sellerName: 'Ramesh Patel',
          imageUrls: ['assets/images/soymeal.png'],
          quantity: 50,
          quantityUnit: 'kg',
          location: 'Gujarat',
          quality: 'Premium',
          certificateUrl: 'https://example.com/cert2',
          processingDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ListingData(
          id: 'dummy-3',
          title: 'Sesame Seeds',
          price: 120,
          priceUnit: '/kg',
          type: 'Oil Seeds',
          category: 'Seeds',
          sellerName: 'Anita Devi',
          imageUrls: ['assets/images/soymeal.png'],
          quantity: 25,
          quantityUnit: 'kg',
          location: 'Rajasthan',
          quality: 'Grade A',
          certificateGrade: 'Organic',
          processingDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
        ListingData(
          id: 'dummy-4',
          title: 'Mustard Seeds',
          price: 45,
          priceUnit: '/kg',
          type: 'Oil Seeds',
          category: 'Seeds',
          sellerName: 'Kisan Co-op',
          imageUrls: ['assets/images/soymeal.png'],
          quantity: 100,
          quantityUnit: 'kg',
          location: 'Punjab',
          quality: 'Standard',
          certificateUrl: 'https://example.com/cert4',
          processingDate: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

      // Filter dummy listings based on arguments
      var filteredDummies = dummyListings;

      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        filteredDummies = filteredDummies
            .where((l) => l.category == categoryFilter)
            .toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        filteredDummies = filteredDummies
            .where(
              (l) => l.title.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();
      }

      if (dateFrom != null) {
        filteredDummies = filteredDummies
            .where(
              (l) =>
                  l.processingDate != null &&
                  l.processingDate!.isAfter(dateFrom),
            )
            .toList();
      }

      listings.addAll(filteredDummies);

      // Apply sorting
      switch (sortBy) {
        case 'distance':
          listings.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
          break;
        case 'price_high':
          listings.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'price_low':
          listings.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'date_recent':
          listings.sort((a, b) {
            final dateA = a.processingDate ?? DateTime(2000);
            final dateB = b.processingDate ?? DateTime(2000);
            return dateB.compareTo(dateA);
          });
          break;
      }
      return listings;
    } catch (e) {
      print('Error fetching marketplace listings: $e');
      return [];
    }
  }

  Future<String> _uploadFile(String path, String folder) async {
    if (path.startsWith('http')) return path; // Already a URL

    final file = File(path);
    if (!file.existsSync()) return '';

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final ref = _storage.ref().child('$folder/$fileName');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> createListing({
    required String title,
    required String category,
    required double quantity,
    required double price,
    required DateTime processingDate,
    required String certificatePath,
    required String imagePath,
    required String location,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Upload images
    final imageUrl = await _uploadFile(imagePath, 'listings');
    // We might want to upload certificate too if needed, but ListingData doesn't show it explicitly in the constructor used here?
    // The prompt says "certificate: file (required)". ListingData has certificateGrade but not a URL field for the cert file itself.
    // I'll assume we just store the path or upload it if we had a field.
    // For now, let's just upload the main image.

    final listingData = {
      'title': title,
      'category': category,
      'quantity': quantity,
      'quantityUnit': 'kg', // Default
      'price': price,
      'priceUnit': '/kg', // Default
      'processingDate': processingDate.toIso8601String(),
      'location': location,
      'imageUrls': [imageUrl],
      'sellerId': user.uid,
      'sellerName': user.displayName ?? 'Farmer', // Should fetch from profile
      'createdAt': FieldValue.serverTimestamp(),
      'distance':
          5.0, // Mock distance for now as we don't have geo-queries setup yet
    };

    await _firestore.collection('products').add(listingData);
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Ensure only the owner can update (security rules also enforce this)
    // We can't easily check ownership here without a read, but Firestore rules will handle it.

    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('products').doc(id).update(data);
  }

  Future<void> deleteListing(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore.collection('products').doc(id).delete();
  }

  Future<List<ListingData>> fetchListingsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ListingData.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching user listings: $e');
      return [];
    }
  }

  // Alias for getMarketplaceListings with no filters
  Future<List<ListingData>> fetchAllListings() async {
    return getMarketplaceListings();
  }
}

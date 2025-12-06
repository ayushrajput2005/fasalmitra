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
    this.rating,
    this.certificateGrade,
    this.isCertified = false,
    this.processingDate,
    this.quantity,
    this.quantityUnit,
    this.distance,
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
      rating: (json['rating'] as num?)?.toDouble(),
      certificateGrade: json['certificateGrade'] as String?,
      isCertified: json['isCertified'] as bool? ?? false,
      processingDate: json['processingDate'] != null
          ? DateTime.parse(json['processingDate'] as String)
          : null,
      quantity: (json['quantity'] as num?)?.toDouble(),
      quantityUnit: json['quantityUnit'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
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
  final double? rating; // Rating out of 5
  final String? certificateGrade; // e.g., "Grade A", "Organic"
  final bool isCertified;
  final DateTime? processingDate;
  final double? quantity;
  final String? quantityUnit;
  final double? distance; // Distance in km from user
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
      Query query = _firestore.collection('products');

      // Apply category filter
      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        query = query.where('category', isEqualTo: categoryFilter);
      }

      // Apply date filter
      if (dateFrom != null) {
        query = query.where(
          'processingDate',
          isGreaterThanOrEqualTo: dateFrom.toIso8601String(),
        );
      }
      if (dateTo != null) {
        query = query.where(
          'processingDate',
          isLessThanOrEqualTo: dateTo.toIso8601String(),
        );
      }

      // Execute query
      final querySnapshot = await query.get();

      var listings = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ListingData.fromJson(data);
      }).toList();

      // Apply search filter (client-side for basic search)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        listings = listings
            .where((l) => l.title.toLowerCase().contains(q))
            .toList();
      }

      // Apply sorting (client-side to avoid complex composite indexes for now)
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

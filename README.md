# FasalMitra 🌾

FasalMitra is a Flutter-based marketplace application designed to empower farmers by connecting them directly with buyers. It focuses on the trade of oilseeds, grains, vegetables, and fruits, providing a transparent and efficient platform for agricultural commerce.

## 🚀 Features

### 🛒 Marketplace
- **Browse Listings:** View a wide variety of agricultural products.
- **Smart Filtering:** Filter by category (Seeds, Grains, Vegetables, Fruits), date, and price.
- **Sorting:** Sort listings by distance, price, or recency.
- **Search:** Quickly find specific products.

### 👨‍🌾 Farmer Tools
- **Create Listings:** Farmers can easily list their produce with details like quantity, price, and harvest date.
- **Image Uploads:** Upload photos of produce and certificates directly to Firebase Storage.
- **Profile Management:** Manage personal details and view received orders.

### 👤 User Account
- **Secure Login:** OTP-based authentication using Phone Number.
- **Cart & Orders:** Add items to cart and place orders.
- **Order History:** Track past orders and status.

### 🌐 Additional Features
- **Bilingual Support:** (Planned/Partially Implemented) Support for local languages.
- **Farmer Tips:** Access helpful agricultural tips and best practices.

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase
  - **Authentication:** Firebase Phone Auth
  - **Database:** Cloud Firestore
  - **Storage:** Firebase Storage
- **State Management:** Provider / ChangeNotifier (Native)

## 📂 Project Structure

```
lib/
├── main.dart                 # Application entry point
├── firebase_options.dart     # Firebase configuration
├── screens/                  # UI Screens
│   ├── home_page.dart        # Main landing page
│   ├── marketplace_screen.dart # Product browsing
│   ├── create_listing_screen.dart # Add new product
│   ├── cart_screen.dart      # Shopping cart
│   ├── phone_login.dart      # Auth screens
│   └── ...
├── services/                 # Business Logic & Data Layer
│   ├── auth_service.dart     # Firebase Auth & User Profile
│   ├── listing_service.dart  # Firestore Products CRUD
│   ├── order_service.dart    # Order placement & history
│   ├── cart_service.dart     # Local cart management
│   └── ...
└── widgets/                  # Reusable UI Components
```

## ⚡ Setup & Installation

1.  **Prerequisites:**
    - Flutter SDK installed.
    - Firebase CLI installed.

2.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/fasalmitra.git
    cd fasalmitra
    ```

3.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Firebase Setup:**
    - Create a project in the [Firebase Console](https://console.firebase.google.com/).
    - Enable **Authentication** (Phone provider).
    - Enable **Cloud Firestore** and **Storage**.
    - Run `flutterfire configure` to generate `firebase_options.dart`.

5.  **Run the App:**
    ```bash
    flutter run
    ```

## 🔒 Security Rules

The project includes `firestore.rules` and `storage.rules` to ensure data security:
- **Users:** Can only edit their own profiles.
- **Products:** Publicly readable, but only editable by the seller.
- **Orders:** Visible only to the buyer and seller.

## 🤝 Contribution

Contributions are welcome! Please fork the repository and submit a pull request.

---
*Built with ❤️ for Indian Farmers*

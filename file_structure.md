# FasalMitra Backend - File Structure Directory

This document provides an overview of the "fasalmitra backend" Flutter project structure, which is integrated with Firebase for its backend services.

## Root Directory

*   **`pubspec.yaml`**: The project manifest. Defines the project name, version, SDK environment, and dependencies (Firebase, `fl_chart`, `translator`, etc.). Also declares assets.
*   **`firebase.json`**: Configuration file for Firebase services.
*   **`firestore.rules`**: Security rules for Cloud Firestore.
*   **`storage.rules`**: Security rules for Firebase Storage.
*   **`assets/`**: Contains static resources:
    *   `images/`: visuals and icons (e.g., `grass.png`, `banners/`).
    *   `data/`: Static data files like `farmer_tips.json`.

## `lib/` Directory

The main source code of the application.

### 1. Entry Points
*   **`main.dart`**: The application entry point. Initializes Firebase, sets up the main widget, and handles global configurations like themes and routes.
*   **`firebase_options.dart`**: Auto-generated configuration file connecting the app to the specific Firebase project.

### 2. `screens/` (Views)
Contains the full-page widgets representing different screens in the application.

*   **Authentication**
    *   `phone_login.dart`: Handles handling phone number authentication.
    *   `register_screen.dart`: User registration screen.
*   **Core Logic**
    *   `home_page.dart`: The main dashboard/landing page.
    *   `marketplace_screen.dart`: Interface for browsing, buying, and selling crops/items.
    *   `create_listing_screen.dart`: Form for users to post new items/crops for sale.
    *   `price_prediction_screen.dart`: Analytics view using charts to display market price trends.
*   **User Management**
    *   `account_screen.dart`: User profile management.
    *   `cart_screen.dart`: Shopping cart view.
    *   `my_orders_screen.dart`: List of orders placed by the user.
    *   `orders_received_screen.dart`: List of orders received by the user (as a seller).

### 3. `services/` (Business Logic & Data Layer)
Handles communication with backend APIs, Firebase, and state management.

*   **Firebase Integration**
    *   `auth_service.dart`: Authentication logic (Phone auth, Login/Register).
    *   `listing_service.dart`: CRUD operations for marketplace listings.
    *   `order_service.dart`: Management of orders.
    *   `banner_service.dart`: Fetches banner data.
*   **Application Utilities**
    *   `language_service.dart`: Handles translation and localization.
    *   `prediction_service.dart`: Logic for price prediction algorithms (or API calls).
    *   `cart_service.dart`: Manages cart state.
    *   `font_size_service.dart`: Handles dynamic font scaling.
    *   `api.dart`: General API helper methods.
    *   `cursor_service.dart`: Services related to custom cursor behavior.
    *   `category_service.dart`: Management of product categories.
    *   `tip_service.dart`: Logic for daily farmer tips.

### 4. `widgets/` (Components)
Reusable UI building blocks used to construct the screens.

*   **`home/`**: Components specific to the Home Page.
    *   `home_navbar.dart`: Top navigation bar.
    *   `home_footer.dart`: Page footer.
    *   `banner_carousel.dart`: Image carousel for the home screen.
    *   `feature_card_grid.dart`: Grid layout for feature links/buttons.
    *   `product_listing_card.dart`: Display card for individual products.
    *   `recent_listings_section.dart`: Section showing newest items.
    *   `secondary_navbar.dart`: Auxiliary navigation elements.
    *   `compact_listing_card.dart`: A smaller version of the product card.
*   **`orders/`**: Components for displaying order details.
*   **General Widgets**
    *   `language_selector.dart`: Dropdown/modal for selecting app language.
    *   `custom_cursor_overlay.dart`: Implementation of a custom cursor effect.
    *   `hoverable.dart`: Wrapper to handle hover states on web/desktop.

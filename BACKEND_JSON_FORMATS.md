# Backend JSON Data Structures

This document outlines the JSON formats for data exchanged with the backend (Firebase Firestore and External APIs).

## 1. Authentication & User Profile (`users` collection)

**Function:** `registerUser` (in `AuthService`)
**Firestore Collection:** `users`

```json
{
  "id": "String (Firebase UID)",
  "name": "String",
  "email": "String",
  "phone": "String",
  "state": "String",
  "role": "String (default: 'farmer')",
  "createdAt": "Timestamp (Server Timestamp)"
}
```

## 2. Marketplace Listings (`products` collection)

**Function:** `createListing` (in `ListingService`)
**Firestore Collection:** `products`

```json
{
  "title": "String",
  "category": "String (e.g., 'Seeds', 'Vegetables')",
  "quantity": "Number (double)",
  "quantityUnit": "String (default: 'kg')",
  "price": "Number (double)",
  "priceUnit": "String (default: '/kg')",
  "processingDate": "String (ISO8601 Date)",
  "location": "String",
  "imageUrls": ["String (URL)"],
  "sellerId": "String (User UID)",
  "sellerName": "String",
  "distance": "Number (double - mock)",
  "createdAt": "Timestamp (Server Timestamp)"
}
```

## 3. Orders (`orders` collection)

**Function:** `createOrder` (in `OrderService`)
**Firestore Collection:** `orders`

```json
{
  "buyerId": "String (User UID)",
  "buyerName": "String",
  "items": [
    {
      "listingId": "String",
      "quantity": "Integer",
      "listingTitle": "String",
      "listingPrice": "Number (double)",
      "listingImage": "String (URL)"
    }
  ],
  "totalAmount": "Number (double)",
  "status": "String (default: 'pending')",
  "sellerIds": ["String (List of Seller UIDs)"],
  "createdAt": "Timestamp (Server Timestamp)"
}
```

## 4. Price Prediction API

**Endpoint:** `https://oilseed-price-api-1.onrender.com/api/dashboard`
**Method:** `POST`
**Service:** `PredictionService`

**Request Payload:**

```json
{
  "name": "String (User Name)",
  "state": "String (State Name)",
  "language": "String ('english' or 'hindi')",
  "crops": ["String (List of crop names)"],
  "phone": "String (User Phone)"
}
```

**Response Format (Expected):**

```json
{
  "dashboard": {
    "farmer": {
      "name": "String"
    },
    "urgent_alerts": [
      {
        "message": "String (Alert text)"
      }
    ],
    "my_crops": [
      {
        "crop": "String",
        "current_price": "Number",
        "risk_level": "String (Low/Medium/High)",
        "recommendation": {
          "action": "String (SELL_NOW/HOLD)",
          "reason": "String"
        },
        "predictions": {
          "1_month": { "predicted_price": "Number" },
          "3_months": { "predicted_price": "Number" },
          "6_months": { "predicted_price": "Number" }
        },
        "seasonal": {
          "Best_Month_to_Sell": "String",
          "Best_Month_Price": "Number",
          "Opportunity_%": "Number"
        }
      }
    ],
    "trending_crops": [] // Same structure as my_crops
  }
}
```

## 5. Cart Structure (Local/Memory)

**Class:** `CartItem` (in `CartService`)

```json
{
  "listingId": "String",
  "quantity": "Integer",
  "listingTitle": "String",
  "listingPrice": "Number",
  "listingImage": "String (URL)"
}
```

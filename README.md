# 🧵 Dastkaari – AI-Powered E-commerce App for Handicrafts

**Dastkaari** is an AI-powered, multi-role e-commerce mobile and web application developed to promote and modernize the sale of traditional handicrafts. The platform empowers buyers, sellers, and administrators through immersive AR previews, intelligent product recommendations, and an intuitive marketplace.


## 📱 Tech Stack

- **Flutter** – Cross-platform app development
- **Firebase** – Authentication, Firestore, Storage, Cloud Functions
- **ARCore / ARKit** – Augmented Reality integration
- **AdMob** – Monetization through banner and interstitial ads
- **Python + scikit-learn** – KNN-based recommendation system
- **Stripe** – Secure payments
- **Provider** – State management
- **Google Sign-In** – OAuth authentication

---

## 🔥 Key Features

### 🛒 Buyer Features
- Browse, search, and filter handcrafted products
- Try-before-you-buy with **AR product previews**
- AI-based product **recommendations**
- Add to cart, manage orders, track deliveries
- Secure checkout with saved addresses and payment methods

### 🧵 Seller Features
- Seller portal to **add products**, manage inventory and orders
- Language toggle (English/Urdu) for accessibility
- View sales analytics and store status
- Receive order confirmation notifications

### 👨‍💼 Admin Features
- Approve/reject seller registrations
- Monitor revenue and active products
- Manage support tickets

---

## 🧠 AI Recommendation System

Implemented **Item-Based Collaborative Filtering** using KNN (Cosine Similarity) via `scikit-learn`:
- Based on **category, co-purchase frequency, and interaction history**
- Trained offline and deployed via a lightweight API
- Results displayed in the home screen recommendation list

---

## 🧳 AR Integration

Users can:
- Launch the **AR Viewer** via camera
- Visualize a 2D model of the product in their environment
- Interact via scale, rotation, and position

> Note: Works on devices supporting ARCore (Android) or ARKit (iOS)

---

## 🔐 Authentication & Roles

- Google Sign-In (OAuth)
- Firebase Authentication
- Users are assigned roles: `buyer`, `seller`, or `admin` on signup
- Restricted views and access based on roles

---

## 📊 Analytics & Ads

- **Firebase Analytics** integrated to track user behavior
- **Google AdMob**: Banner & Interstitial ads shown during navigation or loading

---

## 🧪 Testing

- Manual testing on Android, iOS, and Flutter Web
- Edge case testing for AR failures, empty carts, payment errors
- Auth validation, address/payment checks, and seller admin flows

---

## 📌 Future Work

- Convert recommendation model to TFLite for on-device suggestions
- Add real-time chat between buyers and sellers
- Expand localization and accessibility
- Implement feedback/rating system for products and sellers

---

## 🧾 License

This project is part of an academic Final Year Project and is licensed for educational use. For commercial rights, please contact the project owner.

---

## 👨‍🎓 Developed By

**Raja Rameez Rauf**  
B.S. Computer Science – Final Year  
Flutter Developer | AI Enthusiast | Firebase Expert  
[LinkedIn](https://www.linkedin.com/in/raja-rameez-rauf-27510a226/) • [Email](mailto:rjrameez843@gmail.com)

---




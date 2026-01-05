# 💊 Flutter Medicine Store

A modern pharmacy e-commerce application built with Flutter and Firebase.

![Flutter](https://img.shields.io/badge/Flutter-3.10.4-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 📱 Features

- ✅ **User Authentication** - Register, Login, and Logout
- ✅ **Role-based Access** - Admin and User roles
- ✅ **Medicine Management** - CRUD operations for medicines (Admin only)
- ✅ **Search & Filter** - Search medicines by name and filter by category
- ✅ **Shopping Cart** - Add, update, and remove items from cart
- ✅ **Checkout Process** - Simulated payment with shipping information
- ✅ **Order History** - View past orders with real-time updates
- ✅ **Admin Panel** - Manage medicines and approve/reject pending orders
- ✅ **Real-time Updates** - Live data synchronization with Firestore

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── medicine.dart
│   ├── user_model.dart
│   ├── cart_item.dart
│   └── order.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── medicine_service.dart
│   ├── cart_service.dart
│   └── order_service.dart
├── screens/                  # UI Screens
│   ├── auth/                # Login & Register
│   ├── home/                # Home screen
│   ├── admin/               # Admin panels
│   └── cart/                # Cart & Checkout
├── widgets/                  # Reusable widgets
└── utils/                    # Constants & utilities
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- Dart SDK
- Firebase account
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/GiaoDungCursor/FlutterMedicine.git
   cd FlutterMedicine
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add your app (Web/Android/iOS) to the project
   - Download configuration files:
     - For Android: `google-services.json` → `android/app/`
     - For Web: Copy config to `lib/firebase_options.dart`
   - Run `flutterfire configure` (recommended) or manually configure

4. **Configure Firestore**
   - Go to Firestore Database in Firebase Console
   - Create collections: `medicines`, `users`, `orders`
   - Copy `firestore.rules` content to Firestore Rules and publish

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔥 Firebase Setup

### Step-by-Step Guide

1. **Create Firebase Project**
   - Visit [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project"
   - Follow the setup wizard

2. **Add Flutter App**
   - Click the platform icon (Web/Android/iOS)
   - Register your app
   - Download configuration files

3. **Configure Firestore**
   - Enable Firestore Database
   - Set security rules (use `firestore.rules` from this project)
   - Publish the rules

4. **Enable Authentication**
   - Go to Authentication → Sign-in method
   - Enable Email/Password provider

### Seed Sample Data

Run the seed script to populate sample medicines:

```bash
dart run scripts/seed_data.dart
```

## 📚 Documentation

For detailed documentation, see [PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md)

The documentation includes:
- Detailed file descriptions
- Firestore connection guide
- Q&A about Firestore (32 questions)
- Best practices
- Troubleshooting guide

## 🛠️ Technologies Used

- **Flutter** - UI Framework
- **Firebase Core** - Firebase initialization
- **Firebase Auth** - User authentication
- **Cloud Firestore** - NoSQL database
- **Provider** - State management
- **Intl** - Internationalization

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  provider: ^6.1.1
  intl: ^0.19.0
```

## 🎯 User Roles

### Admin
- Manage medicines (CRUD)
- View and approve/reject pending orders
- Seed sample data

### User
- Browse and search medicines
- Add items to cart
- Place orders
- View order history

## 📝 Security Rules

The project includes Firestore security rules in `firestore.rules`:
- Users can only read/update their own data
- Admins have full access to orders
- Medicines are readable by all authenticated users

**Important**: Always publish security rules in Firebase Console!

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**GiaoDungCursor**

- GitHub: [@GiaoDungCursor](https://github.com/GiaoDungCursor)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- All contributors and users

---

⭐ If you find this project helpful, please give it a star!

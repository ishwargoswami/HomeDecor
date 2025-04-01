# DecorHome - Home Decoration App

<p align="center">
  <img src="assets/icons/home_decor_icon.png" alt="DecorHome Logo" width="200"/>
</p>

## 📱 About
DecorHome is a modern Flutter application for home decoration enthusiasts. It provides a platform for exploring, planning, and implementing interior design ideas, allowing users to visualize and organize their home decoration projects.

## ✨ Features

- **User Authentication**: Secure login and signup with email and Google Sign-In
- **Explore Decoration Items**: Browse trending decoration items with detailed information
- **Project Management**: Create and manage home decoration projects
- **Wishlist**: Save favorite items for future reference
- **Shopping Cart**: Add items to cart and seamless checkout process
- **Recently Viewed**: Track browsing history for easy access to previously viewed items
- **Budget Planning**: Set and track budgets for decoration projects
- **Categories**: Browse items by categories (furniture, lighting, accessories, etc.)
- **User Profile**: Personalized experience with profile management
- **Orders History**: View past orders and their status

## 📸 Screenshots

<p align="center">
  <img src="screenshots/splash_screen.png" alt="Splash Screen" width="200"/>
  <img src="screenshots/home_screen.png" alt="Home Screen" width="200"/>
  <img src="screenshots/detail_screen.png" alt="Detail Screen" width="200"/>
  <img src="screenshots/cart_screen.png" alt="Cart Screen" width="200"/>
</p>

<p align="center">
  <img src="screenshots/wishlist_screen.png" alt="Wishlist Screen" width="200"/>
  <img src="screenshots/project_screen.png" alt="Project Screen" width="200"/>
  <img src="screenshots/dashboard_screen.png" alt="Dashboard Screen" width="200"/>
  <img src="screenshots/profile_screen.png" alt="Profile Screen" width="200"/>
</p>

## 🔧 Technologies Used

- **Flutter**: Cross-platform UI toolkit for building natively compiled applications
- **Firebase**: Backend services including authentication, Firestore, and storage
- **Provider**: State management solution
- **Google Sign-In**: OAuth authentication with Google
- **Cloud Firestore**: NoSQL database for storing user and product data
- **Firebase Storage**: Media storage for product images
- **Animations**: Custom animations for enhanced user experience

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.16.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Firebase account

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/HomeDecor.git
cd HomeDecor
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and place the Google Services configuration files
   - Enable Authentication methods (Email/Password and Google Sign-In)
   - Set up Firestore database with appropriate rules

4. Run the app:
```bash
flutter run
```

## 🏗️ Project Structure

```
lib/
├── models/        # Data models
├── screens/       # UI screens
├── services/      # Business logic and services
├── util/          # Utilities and constants
├── widgets/       # Reusable UI components
└── main.dart      # App entry point
```

## 🔒 Environment Setup

For security reasons, sensitive information like API keys are not included in the repository. Create a `.env` file in the root directory with the following variables:

```
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📧 Contact

For any inquiries, please reach out to: your.email@example.com

---

<p align="center">Made with ❤️ by Your Name</p>

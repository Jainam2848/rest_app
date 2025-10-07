<div align="center">
  <h1>🍽️ CouponEats - Restaurant Coupon Management</h1>
  <p>Revolutionizing restaurant-customer engagement through digital coupons and loyalty programs</p>
  
  <!-- Badges -->
  <p>
    <img src="https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter" alt="Flutter Version">
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-34A853" alt="Platform Support">
    <img src="https://img.shields.io/badge/Status-Phase%203%20Complete-28A745" alt="Project Status">
    <a href="https://supabase.io/">
      <img src="https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase" alt="Supabase">
    </a>
  </p>
  
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
</div>

## 🚀 Overview

CouponEats is a comprehensive digital coupon management platform that bridges the gap between restaurants and customers. Built with Flutter and powered by Supabase, it offers a seamless experience across mobile and web platforms with robust role-based access control for customers, restaurant owners, and administrators.

## 🛠️ Tech Stack

### Frontend
- **Framework:** Flutter 3.9.2+
- **State Management:** Riverpod 2.4.0+
- **Navigation:** GoRouter 10.0.0+
- **UI Components:** Flutter 3.9.2 Material 3
- **Responsive Design:** Adaptive layouts for all screen sizes

### Backend (Supabase)
- **Authentication:** Email/Password, Phone OTP, Social Logins (Google, Apple)
- **Database:** PostgreSQL with Row Level Security
- **Storage:** File storage for images and media
- **Realtime:** Real-time updates for coupons and notifications
- **Edge Functions:** Serverless functions for custom business logic

### Development Tools
- **Version Control:** Git
- **CI/CD:** GitHub Actions
- **Code Analysis:** Flutter Analyze, Dart Analysis
- **Testing:** Flutter Test, Integration Tests

## ✅ Development Status

### 🎉 Completed Phases

**Phase 1: Project Foundation** ✅
- Flutter project setup with proper architecture
- Supabase backend configuration
- Development environment setup

**Phase 2: Authentication System** ✅
- Complete authentication with email/password, Google, Apple, and phone OTP
- Role-based access control (Customer, Restaurant, Admin)
- User profile management
- Secure session handling

**Phase 3: Core Infrastructure** ✅
- Enhanced UI/UX with light/dark theme system
- Reusable widget library
- Data models and API services
- Offline caching support
- Error handling and validation

### 🎯 Current Features

**Authentication & Security:**
- Multi-method authentication (Email, Google, Apple, Phone OTP)
- Role-based access control
- Secure session management
- Password recovery flow

**User Management:**
- Profile creation and editing
- Role-specific dashboards
- Account settings
- Theme preferences

**Core Infrastructure:**
- Responsive design system
- Offline data caching
- Comprehensive error handling
- Type-safe data models

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or later
- Dart SDK 3.1.0 or later
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio with Flutter plugins
- Supabase account (free tier available)

### 🛠 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/coupon-eats.git
   cd coupon-eats
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   - Copy `.env.example` to `.env`
   - Update with your Supabase credentials:
     ```env
     SUPABASE_URL=your_supabase_url
     SUPABASE_ANON_KEY=your_supabase_anon_key
     ```

4. **Database Setup**
   - Create a new project in Supabase
   - Run the SQL script from `supabase/migrations/initial_schema.sql`
   - Enable required authentication providers in Supabase dashboard

5. **Run the app**
   ```bash
   # For development
   flutter run -d chrome  # Web
   flutter run            # Mobile
   
   # For production build
   flutter build apk --release
   ```

## 📚 Documentation

### Available Documentation
- [Development Plan](development_plan.md) - Complete project roadmap
- [Phase 2 Complete](PHASE2_COMPLETE.md) - Authentication system details
- [Phase 3 Summary](PHASE_3_SUMMARY.md) - Core infrastructure implementation
- [Testing Checklist](TESTING_CHECKLIST.md) - Comprehensive testing guide
- [Security Improvements](SECURITY_IMPROVEMENTS.md) - Security best practices

## 🏗 Project Structure

```
lib/
├── core/
│   ├── models/       # Data models (User, Restaurant, Coupon)
│   ├── providers/    # Riverpod state management
│   ├── services/     # API and business logic
│   ├── theme/        # Light/dark theme system
│   ├── router/       # Navigation with GoRouter
│   ├── widgets/      # Reusable UI components
│   └── utils/        # Helper functions and validators
│
├── features/
│   ├── auth/         # Login, signup, password reset
│   ├── profile/      # User profile management
│   ├── customer/     # Customer dashboard
│   ├── restaurant/   # Restaurant dashboard
│   ├── admin/        # Admin dashboard
│   └── splash/       # App splash screen
│
└── main.dart         # App entry point
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Check code quality
flutter analyze
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🎯 What's Next for Your Teammate

### 🚀 Immediate Setup (Required)
1. **Database Setup:**
   - Run the SQL script from `supabase_setup.sql` in your Supabase project
   - Configure authentication providers in Supabase dashboard

2. **Environment Configuration:**
   - Update Supabase credentials in `lib/main.dart`
   - (Optional) Set up Google/Apple OAuth for social login

3. **Test the App:**
   ```bash
   flutter pub get
   flutter run
   ```

### 📋 Next Development Phase (Phase 4)

**Priority 1: Customer Features**
- Implement coupon discovery and browsing
- Add QR code scanning for redemption
- Create favorites and bookmark system
- Implement location-based search

**Priority 2: Restaurant Features**
- Build coupon creation and management
- Add analytics dashboard
- Implement QR code generation
- Create customer insights

**Priority 3: Admin Features**
- User management system
- Content moderation tools
- System analytics
- Settings management

### 🛠️ Development Guidelines

**Code Quality:**
- Run `flutter analyze` before committing
- Follow existing architecture patterns
- Use the established theme system
- Leverage the reusable widget library

**Testing:**
- Test on multiple platforms (Android, iOS, Web)
- Verify authentication flows
- Test role-based navigation
- Validate data persistence

**Documentation:**
- Update relevant documentation files
- Add comments for complex logic
- Update the development plan as you progress

### 📚 Key Resources

- **Architecture:** Follow the established patterns in `lib/core/`
- **UI Components:** Use widgets from `lib/core/widgets/`
- **State Management:** Leverage Riverpod providers
- **API Integration:** Use services from `lib/core/services/`
- **Theming:** Apply consistent styling with `AppTheme`

---

**Current Status:** Phase 3 Complete ✅ - Ready for Feature Development

Built with ❤️ using Flutter and Supabase

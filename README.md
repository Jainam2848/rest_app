# 🎟️ Coupon Manager - Flutter Restaurant Coupon Management App

A comprehensive Flutter application for managing and distributing restaurant coupons with role-based access for Customers, Restaurants, and Admins.

## 📱 Platform Support
- ✅ Android
- ✅ iOS  
- ✅ Web

## 🏗️ Tech Stack
- **Frontend:** Flutter 3.9.2+
- **Backend:** Supabase
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **Authentication:** Email/Password, Phone OTP, Google, Apple

## ✨ Current Features (Phase 2 Complete)

### 🔐 Authentication System
- Email/Password authentication
- Phone OTP verification
- Google Sign-In
- Apple Sign-In (iOS)
- Password reset/recovery
- Email verification
- Session persistence

### 👤 User Management
- User profile creation and editing
- Profile picture support
- Password change
- Role-based access (Customer, Restaurant, Admin)
- Account settings

### 🎯 Role-Based Features

**Customer App:**
- Discover coupons (UI ready)
- Browse by category
- Save favorites
- Redemption tracking
- Profile management

**Restaurant App:**
- Dashboard with statistics
- Coupon management
- Analytics overview
- Business profile
- QR code features (coming soon)

**Admin App:**
- System dashboard
- User management
- Coupon moderation
- System statistics
- Settings management

## 🚀 Quick Start

### Prerequisites
```bash
Flutter SDK >= 3.9.2
Dart SDK
Supabase Account
```

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd rest_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Setup Supabase**
- Create a Supabase project
- Run `supabase_setup.sql` in SQL Editor
- Configure auth providers in dashboard
- Update credentials in `lib/main.dart` (if needed)

4. **Run the app**
```bash
flutter run
```

## 📖 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Complete setup guide
- **[PHASE2_AUTH_README.md](PHASE2_AUTH_README.md)** - Authentication system details
- **[development_plan.md](development_plan.md)** - Full development roadmap
- **[supabase_setup.sql](supabase_setup.sql)** - Database setup script

## 🗂️ Project Structure

```
lib/
├── core/
│   ├── models/              # Data models (AppUser, UserRole)
│   ├── providers/           # Riverpod state providers
│   ├── router/              # Navigation & routing
│   └── services/            # Business logic (AuthService)
├── features/
│   ├── auth/               # Login, Signup, Password Reset
│   ├── profile/            # User Profile Management
│   ├── customer/           # Customer Dashboard
│   ├── restaurant/         # Restaurant Dashboard
│   ├── admin/              # Admin Dashboard
│   └── splash/             # Splash Screen
└── main.dart               # App Entry Point
```

## 🔑 Environment Variables

Supabase credentials are currently in `lib/main.dart`:
```dart
url: 'https://ixgvejltppxpnjkkucgs.supabase.co'
anonKey: '<your-anon-key>'
```

**⚠️ Production:** Move to secure environment variables.

## 🧪 Testing

Create test users for each role:
```dart
// Customer
Email: customer@test.com
Password: test123456

// Restaurant  
Email: restaurant@test.com
Password: test123456

// Admin
Email: admin@test.com
Password: test123456
```

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `supabase_flutter` | Backend & Authentication |
| `flutter_riverpod` | State Management |
| `go_router` | Navigation |
| `google_sign_in` | Google OAuth |
| `sign_in_with_apple` | Apple OAuth |
| `image_picker` | Profile Pictures |
| `qr_flutter` | QR Code Generation |
| `mobile_scanner` | QR Code Scanning |
| `geolocator` | Location Services |

## 🛣️ Development Roadmap

- [x] **Phase 1:** Project Setup
- [x] **Phase 2:** Authentication System ✅
- [ ] **Phase 3:** Core App Infrastructure
- [ ] **Phase 4:** Customer Features
- [ ] **Phase 5:** Restaurant Features
- [ ] **Phase 6:** Admin Features
- [ ] **Phase 7:** Advanced Features
- [ ] **Phase 8:** Performance & Optimization
- [ ] **Phase 9:** Testing & QA
- [ ] **Phase 10:** Deployment

## 🔒 Security Features

- Row Level Security (RLS) in Supabase
- Secure token storage
- Password validation
- Email verification
- Role-based access control
- Auth state persistence

## 🐛 Troubleshooting

**App won't build:**
```bash
flutter clean
flutter pub get
flutter run
```

**Auth not working:**
- Check Supabase dashboard for errors
- Verify auth providers are enabled
- Ensure database schema is correct

**Navigation issues:**
- Check user role in database
- Verify GoRouter configuration
- Check console for errors

## 📝 License

This project is private. All rights reserved.

## 🤝 Contributing

This is a private project. For team members:
1. Create feature branch
2. Make changes
3. Test thoroughly
4. Submit pull request

## 📧 Support

For issues or questions:
- Check documentation files
- Review Supabase logs
- Verify database schema
- Check Flutter console

## 🎯 Next Steps

**Phase 3 - Core Infrastructure:**
- Enhanced UI components
- Theme system (dark/light)
- Data models for coupons
- API service layer
- Error handling

**Phase 4 - Customer Features:**
- Coupon browsing
- QR scanning
- Location-based search
- Favorites management

**Phase 5 - Restaurant Features:**
- Coupon creation
- Analytics dashboard  
- Customer insights
- QR generation

---

**Current Status:** Phase 2 Complete ✅ - Authentication System Fully Implemented

Built with ❤️ using Flutter and Supabase

Flutter Boilerplate Features Document
1. Project Overview

Purpose: Template for building a modern, full-featured mobile application with Flutter.

Platforms: Android (Google Play) & iOS (App Store)

Backend: Supabase (Auth, Database, Storage)

Goal: Provide a complete structure with essential features required in production-ready apps, including coupon management.

2. Core App Features
2.1 Splash & Onboarding

Animated/static splash screen with app logo (2–3 seconds)

Onboarding/tutorial screens highlighting app benefits

Skip option for returning users

2.2 Authentication & User Management

Sign Up / Login

Email/password

Phone OTP

Social login (Google, Apple, Facebook optional)

Password Recovery

User Profile

Update personal info

Profile picture upload to Supabase Storage

Account Settings

Delete account

Change password

Privacy & notification preferences

2.3 Coupon Management System
Restaurant Role

Restaurant Login

Separate authentication for restaurants

Access dashboard to manage coupons

Coupon CRUD

Create, edit, delete coupons

Fields: Title, description, discount, validity, quantity, category, image/video

Analytics

View redemption stats and engagement

Push Notifications

Notify nearby users when new coupons are available

Location-Based Coupons

Option to show coupons based on user location

Admin Role

Admin Dashboard

Approve/reject coupons before publishing

Monitor active/inactive coupons

Track user engagement and coupon redemptions

Customer Role

Browse Coupons

Search, filter by category, popularity, or nearby restaurants

Coupon Details

View description, expiry, restaurant info, images

Redeem Coupons

QR code scanning or code entry

Track redemption counts

Favorites

Save/bookmark coupons for later

2.4 Home & Core App Functionality

Dynamic home screen with categories and featured content

Nearby items/restaurants using user location

Search and filters

Map integration (Google Maps / Apple Maps)

2.5 Notifications

Push notifications via Supabase + OneSignal/Firebase

In-app notification center with actionable messages

2.6 Settings & Preferences

App settings: theme, language, notifications

Privacy & security: location, data permissions, GDPR compliance

2.7 Media & Storage

Supabase storage for images/videos

Media gallery and preview

Offline caching with Hive/SharedPreferences

2.8 Search & Filters

Global search for content, coupons, restaurants

Filters: category, location, popularity, expiry

Sort options: newest, nearest, highest rating

2.9 User Interaction & Social Features

Comments/reviews on coupons (optional)

Like/share/bookmark functionality

Social sharing of coupons

2.10 Analytics & Tracking

Supabase + optional third-party analytics

Track user activity, coupon usage, push notification engagement

2.11 Security

Authentication via Supabase

Encrypted data transfer (HTTPS)

Role-based access: Admin / Restaurant / Customer

Input validation & sanitization

2.12 Additional Features

Deep linking for app content

Referral system

App update alerts

Error & crash reporting (Sentry or similar)

3. App Architecture (Boilerplate Structure)
lib/
├── main.dart
├── models/                     # User, Restaurant, Coupon, Admin
├── services/                   # Supabase services, notifications, location
├── screens/
│   ├── splash/
│   ├── onboarding/
│   ├── auth/
│   ├── home/
│   ├── coupons/                # Customer coupon screens
│   ├── restaurant/             # Restaurant dashboard & coupon management
│   ├── admin/                  # Admin dashboard
│   ├── profile/
│   ├── settings/
│   └── map/
├── widgets/
├── utils/
├── routes/
└── localization/

4. Play Store & App Store Compliance

Target latest Android & iOS SDKs

Proper metadata, screenshots, privacy policy

Permission handling for location, notifications, and storage

GDPR & privacy compliance

Fully functional app without crashes

5. Notes & Recommendations

Use Riverpod or Bloc for state management

Modular code structure for maintainability

Test on multiple screen sizes and OS versions

Optimize media assets and performance

Transparent permission requests (location, push, storage)

✅ This now fully supports coupons with restaurant and admin roles, alongside all essential features required in any modern Play Store or App Store app.
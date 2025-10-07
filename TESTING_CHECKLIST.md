# ✅ Testing Checklist - Phase 2 Authentication System

## Pre-Testing Setup

### 1. Supabase Database Setup
- [ ] Run `supabase_setup.sql` in Supabase SQL Editor
- [ ] Verify `users` table exists with correct schema
- [ ] Check RLS policies are enabled
- [ ] Verify storage bucket `avatars` is created

### 2. Authentication Providers
- [ ] Email/Password enabled in Supabase Auth
- [ ] Phone provider configured (optional - requires Twilio)
- [ ] Google OAuth configured (optional)
- [ ] Apple Sign In configured (optional - iOS only)

### 3. App Configuration
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App builds without errors (`flutter analyze` passes)
- [ ] Supabase URL and key configured in `main.dart`

---

## Authentication Flow Testing

### Email/Password Authentication

#### Sign Up Flow
- [ ] Navigate to Sign Up screen
- [ ] Test form validation:
  - [ ] Empty fields show error messages
  - [ ] Invalid email format shows error
  - [ ] Password < 6 chars shows error
  - [ ] Mismatched passwords show error
- [ ] Select role (Customer/Restaurant)
- [ ] Create account successfully
- [ ] Verify success message displays
- [ ] Verify navigation to login screen
- [ ] Check user exists in Supabase `users` table
- [ ] Verify email verification sent (check email)

#### Login Flow
- [ ] Enter valid email/password
- [ ] Test form validation:
  - [ ] Empty fields show error
  - [ ] Invalid format shows error
- [ ] Login successfully
- [ ] Verify navigation to role-based home screen
- [ ] Test "Forgot Password" link works
- [ ] Test "Sign Up" link navigates correctly

#### Password Reset
- [ ] Click "Forgot Password"
- [ ] Enter registered email
- [ ] Verify success message
- [ ] Check email received
- [ ] Click reset link in email
- [ ] Set new password
- [ ] Login with new password

### Social Authentication

#### Google Sign-In (if configured)
- [ ] Click Google sign-in button
- [ ] Verify Google OAuth screen appears
- [ ] Sign in with Google account
- [ ] Verify user created in database
- [ ] Verify navigation to home screen
- [ ] Check profile shows Google info

#### Apple Sign-In (if configured - iOS)
- [ ] Click Apple sign-in button (iOS device)
- [ ] Complete Apple authentication
- [ ] Verify user created
- [ ] Check profile information

#### Phone Authentication (if configured)
- [ ] Navigate to Phone Login
- [ ] Enter phone number with country code (+1234567890)
- [ ] Verify OTP sent
- [ ] Enter OTP code
- [ ] Verify login successful
- [ ] Check user created with phone number

---

## User Profile Testing

### View Profile
- [ ] Navigate to Profile screen
- [ ] Verify user information displays:
  - [ ] Display name
  - [ ] Email address
  - [ ] Phone number (if set)
  - [ ] Role
  - [ ] Email verification status
- [ ] Check profile picture placeholder shows
- [ ] Verify settings options visible

### Edit Profile
- [ ] Click Edit Profile
- [ ] Change display name
- [ ] Save changes
- [ ] Verify success message
- [ ] Verify changes reflected in profile
- [ ] Check database updated

### Change Password
- [ ] Navigate to Change Password
- [ ] Test validation:
  - [ ] Empty fields show errors
  - [ ] Password < 6 chars shows error
  - [ ] Mismatched passwords show error
- [ ] Enter new password
- [ ] Save successfully
- [ ] Logout
- [ ] Login with new password
- [ ] Verify login works

---

## Role-Based Navigation Testing

### Customer Role
- [ ] Login as customer
- [ ] Verify Customer Home Screen displays
- [ ] Check bottom navigation has 4 tabs:
  - [ ] Discover
  - [ ] My Coupons
  - [ ] Favorites
  - [ ] Profile
- [ ] Navigate between tabs
- [ ] Verify each tab loads correctly
- [ ] Check profile access works

### Restaurant Role
- [ ] Login as restaurant
- [ ] Verify Restaurant Home Screen displays
- [ ] Check bottom navigation has 4 tabs:
  - [ ] Dashboard
  - [ ] Coupons
  - [ ] Analytics
  - [ ] Profile
- [ ] Navigate between tabs
- [ ] Verify dashboard stats display (0s)
- [ ] Check quick actions visible
- [ ] Verify profile access works

### Admin Role
- [ ] Create admin user in database:
  ```sql
  UPDATE public.users
  SET role = 'admin'
  WHERE email = 'admin@test.com';
  ```
- [ ] Login as admin
- [ ] Verify Admin Home Screen displays
- [ ] Check bottom navigation has 4 tabs:
  - [ ] Dashboard
  - [ ] Users
  - [ ] Coupons
  - [ ] Settings
- [ ] Navigate between tabs
- [ ] Verify system statistics display

---

## Session & State Management

### Session Persistence
- [ ] Login to app
- [ ] Close app completely
- [ ] Reopen app
- [ ] Verify user still logged in
- [ ] Verify navigates to correct home screen

### Logout Flow
- [ ] Navigate to Profile
- [ ] Click Logout
- [ ] Confirm logout in dialog
- [ ] Verify navigation to login screen
- [ ] Verify cannot access protected screens
- [ ] Verify can login again

### Auth State Changes
- [ ] Login successfully
- [ ] Open new tab/window (web)
- [ ] Logout in one tab
- [ ] Verify other tab updates (web)

---

## Error Handling

### Network Errors
- [ ] Disable network/Wi-Fi
- [ ] Try to login
- [ ] Verify error message displays
- [ ] Re-enable network
- [ ] Verify can login

### Invalid Credentials
- [ ] Enter wrong email
- [ ] Verify error message
- [ ] Enter wrong password
- [ ] Verify error message
- [ ] Clear error and try valid credentials

### Form Validation
- [ ] Test all required fields show errors when empty
- [ ] Test email format validation
- [ ] Test password strength validation
- [ ] Test password match validation
- [ ] Verify error messages are user-friendly

---

## UI/UX Testing

### Responsive Design
- [ ] Test on small phone screen
- [ ] Test on large tablet screen
- [ ] Test on web browser (different sizes)
- [ ] Verify all UI elements visible
- [ ] Check scrolling works properly

### Loading States
- [ ] Verify loading indicators show during:
  - [ ] Login
  - [ ] Sign up
  - [ ] Password reset
  - [ ] Profile update
  - [ ] Social login
- [ ] Check buttons disabled during loading
- [ ] Verify no double-submission possible

### Navigation
- [ ] Test back button behavior
- [ ] Test deep links (if configured)
- [ ] Verify can't go back to login after login
- [ ] Test navigation guards work

---

## Security Testing

### Authentication Security
- [ ] Verify can't access home without login
- [ ] Test protected routes redirect to login
- [ ] Verify tokens stored securely
- [ ] Check password not visible in logs

### Role-Based Access
- [ ] Verify customer can't access restaurant dashboard
- [ ] Verify restaurant can't access admin dashboard
- [ ] Verify admin policies work in database
- [ ] Test RLS policies prevent unauthorized access

### Data Privacy
- [ ] Verify users can only see own data
- [ ] Test user can only update own profile
- [ ] Check admin can view all users (if implemented)
- [ ] Verify sensitive data encrypted

---

## Database Testing

### User Creation
- [ ] Create user through app
- [ ] Check user exists in `auth.users`
- [ ] Check profile exists in `public.users`
- [ ] Verify all fields populated correctly
- [ ] Check `created_at` timestamp set

### Profile Updates
- [ ] Update user profile
- [ ] Check `updated_at` timestamp changes
- [ ] Verify trigger fired correctly
- [ ] Check all changes persisted

### Data Integrity
- [ ] Try creating duplicate email
- [ ] Verify unique constraint works
- [ ] Test cascade delete (if deleting user)
- [ ] Verify foreign keys maintained

---

## Cross-Platform Testing

### Android
- [ ] Build APK successfully
- [ ] Install on Android device
- [ ] Test all authentication flows
- [ ] Verify Google Sign-In works
- [ ] Check UI renders correctly
- [ ] Test back button behavior

### iOS
- [ ] Build iOS app successfully
- [ ] Install on iOS device/simulator
- [ ] Test all authentication flows
- [ ] Verify Apple Sign-In works
- [ ] Verify Google Sign-In works
- [ ] Check UI renders correctly

### Web
- [ ] Run on Chrome
- [ ] Run on Firefox
- [ ] Run on Safari
- [ ] Test responsive design
- [ ] Verify social login works
- [ ] Check localStorage/session storage

---

## Performance Testing

### App Launch
- [ ] Measure cold start time
- [ ] Measure warm start time
- [ ] Check splash screen displays
- [ ] Verify quick navigation to login/home

### API Calls
- [ ] Monitor network requests
- [ ] Verify no unnecessary calls
- [ ] Check response times acceptable
- [ ] Test with slow network

### Memory Usage
- [ ] Check for memory leaks
- [ ] Verify images load efficiently
- [ ] Test navigation doesn't cause issues
- [ ] Monitor app size

---

## Test User Credentials

Create these test users for comprehensive testing:

```dart
// Customer Test User
Email: customer@test.com
Password: test123456
Role: customer

// Restaurant Test User
Email: restaurant@test.com
Password: test123456
Role: restaurant

// Admin Test User (update role in DB)
Email: admin@test.com
Password: test123456
Role: admin

// Test Various Scenarios
Email: verified@test.com (email verified)
Email: unverified@test.com (email not verified)
Phone: +15555551234 (phone user)
```

---

## Known Limitations to Note

### Not Yet Implemented
- [ ] Profile picture upload (UI ready, needs implementation)
- [ ] Email verification enforcement
- [ ] Facebook login (optional)
- [ ] Two-factor authentication
- [ ] Account deletion

### Platform Specific
- [ ] Apple Sign-In only on iOS
- [ ] Some permissions need platform config
- [ ] Phone auth requires Twilio setup

---

## Bug Reporting Template

If you find issues, document them as:

```markdown
**Issue:** Brief description
**Steps to Reproduce:**
1. Step one
2. Step two
3. Step three

**Expected:** What should happen
**Actual:** What actually happens
**Platform:** Android/iOS/Web
**Environment:** Debug/Release
**Screenshots:** If applicable
```

---

## Post-Testing Checklist

- [ ] All critical authentication flows work
- [ ] All role-based features accessible
- [ ] Profile management functional
- [ ] No console errors or warnings
- [ ] `flutter analyze` passes
- [ ] Documentation updated
- [ ] Known issues documented

---

## ✅ Sign-Off

Once all tests pass:

- **Tester Name:** _______________
- **Date:** _______________
- **Platform(s) Tested:** _______________
- **Overall Status:** ⬜ Pass  ⬜ Pass with minor issues  ⬜ Fail
- **Notes:** _______________

---

**Phase 2 Testing Complete!** 🎉

Ready to proceed to Phase 3: Core App Infrastructure

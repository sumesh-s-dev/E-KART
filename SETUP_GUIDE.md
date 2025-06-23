# LEAD-KART Setup Guide

This guide will help you set up the LEAD-KART e-commerce app step by step.

## 🚀 Quick Start

### Step 1: Prerequisites
- Flutter SDK 3.0+ installed
- Dart SDK 2.17+ installed
- Supabase account (free tier works)
- Android Studio / VS Code

### Step 2: Clone and Setup
```bash
# Clone the repository
git clone <repository-url>
cd E-KART

# Install dependencies
flutter pub get

# Check if everything is working
flutter doctor
```

### Step 3: Supabase Setup

#### 3.1 Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Choose your organization
4. Enter project name: `lead-kart`
5. Enter database password (save it!)
6. Choose region closest to you
7. Click "Create new project"

#### 3.2 Get Project Credentials
1. Go to Settings → API
2. Copy the Project URL
3. Copy the anon public key

#### 3.3 Update App Configuration
Edit `lib/utils/supabase_client.dart`:
```dart
class SupabaseService {
  // Replace with your actual credentials
  static const String url = 'https://your-project-id.supabase.co';
  static const String anonKey = 'your-anon-key';
  // ... rest remains the same
}
```

### Step 4: Database Setup

#### 4.1 Run SQL Script
1. Go to SQL Editor in Supabase
2. Copy and paste the entire SQL script from the README
3. Click "Run" to execute

#### 4.2 Verify Tables
Check that these tables were created:
- `users`
- `products`
- `orders`

#### 4.3 Storage Setup
1. Go to Storage in Supabase
2. Create bucket: `product-images`
3. Set to public
4. Add the storage policy from README

### Step 5: Test the App

#### 5.1 Run the App
```bash
flutter run
```

#### 5.2 Test Authentication
1. Open the app
2. Click "Sign Up"
3. Choose "Customer" or "Seller"
4. Fill in the form
5. Create account
6. Try logging in

#### 5.3 Test Features
- **Customer**: Browse products, place orders
- **Seller**: Add products, manage orders

## 🔧 Troubleshooting

### Issue 1: Supabase Connection Error
**Error**: `Failed to connect to Supabase`

**Solution**:
1. Check your URL and anon key
2. Ensure project is active
3. Check internet connection
4. Verify RLS policies are set

### Issue 2: Authentication Not Working
**Error**: `Login failed` or `Signup failed`

**Solution**:
1. Check users table exists
2. Verify RLS policies for users table
3. Disable email confirmation in Auth settings
4. Check auth flow in Supabase dashboard

### Issue 3: Products Not Loading
**Error**: `No products found`

**Solution**:
1. Check products table exists
2. Verify RLS policies for products
3. Add some test products
4. Check real-time subscriptions

### Issue 4: Orders Not Working
**Error**: `Error creating order`

**Solution**:
1. Check orders table exists
2. Verify RLS policies for orders
3. Ensure user is authenticated
4. Check product exists

### Issue 5: Image Upload Issues
**Error**: `Error uploading image`

**Solution**:
1. Check storage bucket exists
2. Verify storage policies
3. Check image format and size
4. Ensure bucket is public

## 🧪 Testing

### Test Data Setup
You can add test data using the Supabase dashboard:

#### Add Test Products
```sql
INSERT INTO products (seller_id, name, description, price, category, stock, image_url)
VALUES 
  ('your-user-id', 'Test Product 1', 'Description 1', 29.99, 'Electronics', 10, 'https://via.placeholder.com/300x300'),
  ('your-user-id', 'Test Product 2', 'Description 2', 49.99, 'Clothing', 5, 'https://via.placeholder.com/300x300');
```

#### Add Test Orders
```sql
INSERT INTO orders (customer_id, seller_id, product_id, quantity, total_amount, shipping_address, status)
VALUES 
  ('customer-user-id', 'seller-user-id', 'product-id', 2, 59.98, '123 Test St, City', 'pending');
```

## 📱 Platform-Specific Setup

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d chrome
```

### Desktop
```bash
flutter run -d windows  # or macos, linux
```

## 🔒 Security Checklist

- [ ] RLS policies enabled on all tables
- [ ] Storage bucket is properly configured
- [ ] Auth settings are secure
- [ ] API keys are not exposed in code
- [ ] Input validation is working
- [ ] Error handling is in place

## 🚀 Deployment

### Web Deployment
```bash
flutter build web
# Deploy to Firebase Hosting, Netlify, or Vercel
```

### Mobile Deployment
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 📞 Support

If you encounter issues:

1. Check this setup guide
2. Review the troubleshooting section
3. Check Flutter and Dart versions
4. Verify Supabase project status
5. Create an issue with:
   - Error message
   - Steps to reproduce
   - Platform details
   - Flutter doctor output

## 🎯 Next Steps

After successful setup:

1. Customize the UI colors in `lib/utils/constants.dart`
2. Add your own product categories
3. Implement image upload to Supabase storage
4. Add payment gateway integration
5. Implement push notifications
6. Add analytics and monitoring

---

**Happy coding! 🚀** 
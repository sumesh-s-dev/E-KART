# LEAD-KART - Modern Flutter E-Commerce App

A fully functional Flutter e-commerce application with Supabase backend, featuring authentication, product management, order management, and real-time updates with a modern chalkboard-style UI.

## 🚀 Features

### Authentication
- ✅ User registration and login
- ✅ Role-based access (Customer/Seller)
- ✅ Secure authentication with Supabase
- ✅ Profile management
- ✅ Session persistence

### Product Management
- ✅ Product listing with grid view
- ✅ Product search and filtering
- ✅ Category-based filtering
- ✅ Product details with images
- ✅ Stock management
- ✅ Add/Edit products (for sellers)

### Order Management
- ✅ Place orders with cash-on-delivery
- ✅ Order tracking and status updates
- ✅ Order history for customers
- ✅ Order management for sellers
- ✅ Real-time order updates

### UI/UX Features
- ✅ Modern chalkboard-style design
- ✅ Smooth animations and transitions
- ✅ Responsive design
- ✅ Loading states and error handling
- ✅ Dark theme with gradient backgrounds
- ✅ Role-based navigation

### Technical Features
- ✅ BLoC pattern for state management
- ✅ Real-time Supabase subscriptions
- ✅ Offline support with local storage
- ✅ Error handling and validation
- ✅ Responsive design for all screen sizes

## 📱 Screenshots

The app features a modern, dark-themed interface with:
- Gradient backgrounds
- Smooth animations
- Role-based navigation
- Product grids and order lists
- Modern form designs

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / VS Code
- Supabase account

### 1. Clone the Repository
```bash
git clone <repository-url>
cd E-KART
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Supabase Setup

#### Create a Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note down your project URL and anon key

#### Database Schema
Run the following SQL in your Supabase SQL editor:

```sql
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL CHECK (role IN ('customer', 'seller')),
    brand_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Products table
CREATE TABLE products (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    seller_id UUID REFERENCES users(id) NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category TEXT NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Orders table
CREATE TABLE orders (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_id UUID REFERENCES users(id) NOT NULL,
    seller_id UUID REFERENCES users(id) NOT NULL,
    product_id UUID REFERENCES products(id) NOT NULL,
    quantity INTEGER NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    shipping_address TEXT NOT NULL,
    order_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- RLS Policies for products
CREATE POLICY "Anyone can view products" ON products
    FOR SELECT USING (true);

CREATE POLICY "Sellers can insert their own products" ON products
    FOR INSERT WITH CHECK (auth.uid() = seller_id);

CREATE POLICY "Sellers can update their own products" ON products
    FOR UPDATE USING (auth.uid() = seller_id);

CREATE POLICY "Sellers can delete their own products" ON products
    FOR DELETE USING (auth.uid() = seller_id);

-- RLS Policies for orders
CREATE POLICY "Users can view their own orders" ON orders
    FOR SELECT USING (auth.uid() = customer_id OR auth.uid() = seller_id);

CREATE POLICY "Customers can create orders" ON orders
    FOR INSERT WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "Sellers can update order status" ON orders
    FOR UPDATE USING (auth.uid() = seller_id);

-- Create indexes for better performance
CREATE INDEX idx_products_seller_id ON products(seller_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_seller_id ON orders(seller_id);
CREATE INDEX idx_orders_status ON orders(status);
```

#### Storage Setup
1. Go to Storage in your Supabase dashboard
2. Create a new bucket called `product-images`
3. Set the bucket to public
4. Add the following policy:

```sql
CREATE POLICY "Public Access" ON storage.objects
    FOR SELECT USING (bucket_id = 'product-images');
```

### 4. Configure the App

#### Update Supabase Configuration
Edit `lib/utils/supabase_client.dart`:

```dart
class SupabaseService {
  // Replace with your actual Supabase credentials
  static const String url = 'https://your-project.supabase.co';
  static const String anonKey = 'your-anon-key';
  // ... rest of the code
}
```

### 5. Run the App
```bash
flutter run
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Supabase Connection Error
- Verify your Supabase URL and anon key
- Check if your Supabase project is active
- Ensure RLS policies are properly configured

#### 2. Authentication Issues
- Make sure the users table is created with proper RLS policies
- Check if email confirmation is disabled in Supabase Auth settings
- Verify the auth flow in Supabase dashboard

#### 3. Product/Order Loading Issues
- Ensure all database tables are created
- Check RLS policies for proper access
- Verify real-time subscriptions are enabled

#### 4. Image Upload Issues
- Ensure storage bucket is created and public
- Check storage policies
- Verify image URL format

### Debug Mode
Run the app in debug mode to see detailed logs:
```bash
flutter run --debug
```

## 📁 Project Structure

```
lib/
├── blocs/                 # State management
│   ├── auth_bloc.dart
│   ├── product_bloc.dart
│   └── order_bloc.dart
├── models/               # Data models
│   ├── user.dart
│   ├── product.dart
│   └── order.dart
├── screens/              # UI screens
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── product_add_screen.dart
│   └── profile_screen.dart
├── widgets/              # Reusable widgets
│   ├── custom_button.dart
│   ├── product_card.dart
│   └── order_card.dart
├── utils/                # Utilities
│   ├── constants.dart
│   └── supabase_client.dart
└── main.dart            # App entry point
```

## 🎨 UI Components

### Design System
- **Colors**: Dark theme with accent colors
- **Typography**: Modern font hierarchy
- **Spacing**: Consistent padding and margins
- **Animations**: Smooth transitions and micro-interactions

### Key Components
- **CustomButton**: Reusable button with loading states
- **ProductCard**: Product display with actions
- **OrderCard**: Order information with status
- **Form Fields**: Modern input fields with validation

## 🔒 Security Features

- Row Level Security (RLS) policies
- User authentication and authorization
- Input validation and sanitization
- Secure API communication
- Role-based access control

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Desktop (Windows, macOS, Linux)

## 🚀 Deployment

### Web Deployment
```bash
flutter build web
```

### Android Deployment
```bash
flutter build apk --release
```

### iOS Deployment
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

If you encounter any issues:
1. Check the troubleshooting section
2. Review the Supabase documentation
3. Check Flutter and Dart versions
4. Create an issue with detailed error information

## 🔄 Updates

The app is actively maintained and updated with:
- Latest Flutter and Dart versions
- Security patches
- UI/UX improvements
- New features and bug fixes

---

**LEAD-KART** - Your modern e-commerce solution! 🛒✨ 
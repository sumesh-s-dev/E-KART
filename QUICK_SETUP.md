# 🚨 QUICK FIX: Supabase Connection Error

## The Problem
You're getting this error because the app is trying to connect to placeholder Supabase credentials instead of your actual project.

## 🔧 Solution (5 minutes)

### Step 1: Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Fill in:
   - **Name**: `lead-kart` (or any name)
   - **Database Password**: Create a strong password
   - **Region**: Choose closest to you
4. Click "Create new project"
5. Wait for setup to complete (2-3 minutes)

### Step 2: Get Your Credentials
1. In your Supabase dashboard, click **Settings** (⚙️ icon)
2. Click **API** in the left menu
3. Copy these two values:
   - **Project URL** (looks like: `https://abcdefghijklmnop.supabase.co`)
   - **anon public** key (starts with `eyJ...`)

### Step 3: Update the App
1. Open `lib/utils/supabase_client.dart`
2. Replace these lines:
   ```dart
   static const String url = 'https://your-project.supabase.co';
   static const String anonKey = 'your-anon-key';
   ```
3. With your actual values:
   ```dart
   static const String url = 'https://YOUR-ACTUAL-PROJECT-ID.supabase.co';
   static const String anonKey = 'YOUR-ACTUAL-ANON-KEY';
   ```

### Step 4: Set Up Database
1. In Supabase dashboard, go to **SQL Editor**
2. Copy and paste this SQL script:
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
   ```
3. Click **Run** to execute

### Step 5: Test the App
1. Stop the app if it's running (`Ctrl+C`)
2. Run: `flutter run`
3. Try signing up again

## ✅ Expected Result
- App should start without errors
- Signup should work successfully
- You should be redirected to the main app

## 🆘 Still Having Issues?

### Check These:
1. **Internet connection** - Make sure you're online
2. **Supabase project status** - Should show "Active" in dashboard
3. **Credentials copied correctly** - No extra spaces or characters
4. **Database tables created** - Check Tables section in Supabase

### Common Mistakes:
- ❌ Forgetting to replace both URL and anon key
- ❌ Adding extra quotes or spaces
- ❌ Not running the SQL script
- ❌ Using wrong credentials

### Debug Steps:
1. Check console output for specific error messages
2. Verify Supabase project is active
3. Test connection in Supabase dashboard
4. Check if tables exist in Database section

## 📞 Need Help?
If you're still stuck, share:
1. The exact error message
2. Your Supabase project status
3. Whether you've completed all steps above

---

**This should fix your connection issue! 🚀** 
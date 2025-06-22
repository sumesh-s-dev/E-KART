# Lead Kart

A production-ready Flutter e-commerce app with Supabase backend.

## Features
- Email/password authentication with Supabase Auth
- Product management (CRUD, image upload)
- Order management
- Real-time updates via Supabase
- Provider state management
- Modular, scalable architecture

## Getting Started

### 1. Clone the repository
```
git clone <your-repo-url>
cd Lead-Kart
```

### 2. Install dependencies
```
flutter pub get
```

### 3. Supabase Setup
- Create a project at [Supabase](https://supabase.com)
- Go to Settings → API to get your URL and anon key
- Update `lib/config/supabase_config.dart` with your credentials
- Create tables: `users`, `products`, `orders` (see below for SQL)
- Enable Email Auth in Supabase Dashboard
- Create a public storage bucket called `product-images`

### 4. Run the app
```
flutter run
```

### 5. Build for production
```
flutter build apk --release
flutter build ios --release
```

## Supabase SQL Example
```
-- Users table
create table users (
  id uuid primary key default uuid_generate_v4(),
  email text unique not null,
  name text
);

-- Products table
create table products (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  description text,
  price numeric not null,
  image_url text,
  category text
);

-- Orders table
create table orders (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references users(id),
  product_ids uuid[],
  status text,
  created_at timestamp default now()
);
```

## Troubleshooting
- Check your Supabase credentials and policies
- Run `flutter clean && flutter pub get` if you have build issues
- Ensure all dependencies are compatible with your Flutter SDK

---

**Happy coding!** 
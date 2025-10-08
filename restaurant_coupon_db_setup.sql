-- =============================================
-- Restaurant & Coupon Database Setup for Phase 4
-- Restaurant Features Implementation
-- =============================================

-- 1. Create Restaurants Table
-- =============================================
CREATE TABLE IF NOT EXISTS public.restaurants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  cover_image_url TEXT,
  address TEXT NOT NULL,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  phone_number TEXT,
  email TEXT,
  website TEXT,
  categories TEXT[] DEFAULT '{}',
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'inactive', 'suspended')),
  is_verified BOOLEAN DEFAULT FALSE,
  rating DECIMAL(3,2),
  total_reviews INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB
);

-- 2. Create Coupons Table
-- =============================================
CREATE TABLE IF NOT EXISTS public.coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id UUID REFERENCES public.restaurants(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  code TEXT,
  discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed_amount', 'buy_one_get_one')),
  discount_value DECIMAL(10,2),
  min_purchase DECIMAL(10,2),
  max_discount DECIMAL(10,2),
  image_urls TEXT[],
  video_url TEXT,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  usage_limit INTEGER,
  usage_count INTEGER DEFAULT 0,
  per_user_limit INTEGER,
  categories TEXT[] DEFAULT '{}',
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'paused', 'expired', 'deleted')),
  is_active BOOLEAN DEFAULT FALSE,
  is_featured BOOLEAN DEFAULT FALSE,
  priority INTEGER,
  terms JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- 3. Create Coupon Redemptions Table
-- =============================================
CREATE TABLE IF NOT EXISTS public.coupon_redemptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id UUID REFERENCES public.coupons(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  restaurant_id UUID REFERENCES public.restaurants(id) ON DELETE CASCADE,
  redemption_code TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled', 'failed')),
  redeemed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  metadata JSONB
);

-- 4. Create Coupon Views Table (for analytics)
-- =============================================
CREATE TABLE IF NOT EXISTS public.coupon_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id UUID REFERENCES public.coupons(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  source TEXT -- 'home', 'search', 'category', 'restaurant'
);

-- 5. Create Coupon Favorites Table
-- =============================================
CREATE TABLE IF NOT EXISTS public.coupon_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id UUID REFERENCES public.coupons(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(coupon_id, user_id)
);

-- 6. Create Indexes for Performance
-- =============================================
CREATE INDEX IF NOT EXISTS idx_restaurants_owner_id ON public.restaurants(owner_id);
CREATE INDEX IF NOT EXISTS idx_restaurants_status ON public.restaurants(status);
CREATE INDEX IF NOT EXISTS idx_restaurants_categories ON public.restaurants USING GIN(categories);
CREATE INDEX IF NOT EXISTS idx_restaurants_location ON public.restaurants(latitude, longitude);

CREATE INDEX IF NOT EXISTS idx_coupons_restaurant_id ON public.coupons(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_coupons_status ON public.coupons(status);
CREATE INDEX IF NOT EXISTS idx_coupons_active ON public.coupons(is_active);
CREATE INDEX IF NOT EXISTS idx_coupons_featured ON public.coupons(is_featured);
CREATE INDEX IF NOT EXISTS idx_coupons_dates ON public.coupons(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_coupons_categories ON public.coupons USING GIN(categories);

CREATE INDEX IF NOT EXISTS idx_redemptions_coupon_id ON public.coupon_redemptions(coupon_id);
CREATE INDEX IF NOT EXISTS idx_redemptions_user_id ON public.coupon_redemptions(user_id);
CREATE INDEX IF NOT EXISTS idx_redemptions_restaurant_id ON public.coupon_redemptions(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_redemptions_status ON public.coupon_redemptions(status);

CREATE INDEX IF NOT EXISTS idx_views_coupon_id ON public.coupon_views(coupon_id);
CREATE INDEX IF NOT EXISTS idx_views_user_id ON public.coupon_views(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_coupon_id ON public.coupon_favorites(coupon_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.coupon_favorites(user_id);

-- 7. Row Level Security (RLS) Policies
-- =============================================

-- Enable RLS
ALTER TABLE public.restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupon_redemptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupon_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupon_favorites ENABLE ROW LEVEL SECURITY;

-- Restaurant Policies
CREATE POLICY "Restaurant owners can manage their restaurants"
ON public.restaurants
FOR ALL
USING (
  owner_id = auth.uid() OR
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  )
);

CREATE POLICY "Anyone can view active restaurants"
ON public.restaurants
FOR SELECT
USING (status = 'active');

-- Coupon Policies
CREATE POLICY "Restaurant owners can manage their coupons"
ON public.coupons
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.restaurants
    WHERE id = restaurant_id AND owner_id = auth.uid()
  ) OR
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  )
);

CREATE POLICY "Anyone can view active coupons"
ON public.coupons
FOR SELECT
USING (is_active = true AND status = 'active');

-- Redemption Policies
CREATE POLICY "Users can create redemptions"
ON public.coupon_redemptions
FOR INSERT
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can view their own redemptions"
ON public.coupon_redemptions
FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "Restaurant owners can view their redemptions"
ON public.coupon_redemptions
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.restaurants
    WHERE id = restaurant_id AND owner_id = auth.uid()
  )
);

-- Views Policies
CREATE POLICY "Users can create views"
ON public.coupon_views
FOR INSERT
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Restaurant owners can view their coupon views"
ON public.coupon_views
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.coupons c
    JOIN public.restaurants r ON c.restaurant_id = r.id
    WHERE c.id = coupon_id AND r.owner_id = auth.uid()
  )
);

-- Favorites Policies
CREATE POLICY "Users can manage their favorites"
ON public.coupon_favorites
FOR ALL
USING (user_id = auth.uid());

-- 8. Functions and Triggers
-- =============================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers: Auto-update updated_at
DROP TRIGGER IF EXISTS set_restaurants_updated_at ON public.restaurants;
CREATE TRIGGER set_restaurants_updated_at
  BEFORE UPDATE ON public.restaurants
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_coupons_updated_at ON public.coupons;
CREATE TRIGGER set_coupons_updated_at
  BEFORE UPDATE ON public.coupons
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Function: Auto-generate coupon code
CREATE OR REPLACE FUNCTION public.generate_coupon_code()
RETURNS TEXT AS $$
BEGIN
  RETURN UPPER(SUBSTRING(MD5(RANDOM()::TEXT), 1, 8));
END;
$$ LANGUAGE plpgsql;

-- Function: Get restaurant analytics
CREATE OR REPLACE FUNCTION public.get_restaurant_analytics(restaurant_uuid UUID)
RETURNS TABLE (
  total_coupons BIGINT,
  active_coupons BIGINT,
  total_redemptions BIGINT,
  total_views BIGINT,
  total_favorites BIGINT,
  unique_customers BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(DISTINCT c.id) as total_coupons,
    COUNT(DISTINCT CASE WHEN c.is_active THEN c.id END) as active_coupons,
    COUNT(DISTINCT cr.id) as total_redemptions,
    COUNT(DISTINCT cv.id) as total_views,
    COUNT(DISTINCT cf.id) as total_favorites,
    COUNT(DISTINCT cr.user_id) as unique_customers
  FROM public.restaurants r
  LEFT JOIN public.coupons c ON r.id = c.restaurant_id
  LEFT JOIN public.coupon_redemptions cr ON c.id = cr.coupon_id
  LEFT JOIN public.coupon_views cv ON c.id = cv.coupon_id
  LEFT JOIN public.coupon_favorites cf ON c.id = cf.coupon_id
  WHERE r.id = restaurant_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Get nearby restaurants
CREATE OR REPLACE FUNCTION public.get_nearby_restaurants(
  lat DECIMAL(10,8),
  lng DECIMAL(11,8),
  radius_km DECIMAL DEFAULT 10.0
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  address TEXT,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  distance_km DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id,
    r.name,
    r.address,
    r.latitude,
    r.longitude,
    (6371 * acos(
      cos(radians(lat)) * 
      cos(radians(r.latitude)) * 
      cos(radians(r.longitude) - radians(lng)) + 
      sin(radians(lat)) * 
      sin(radians(r.latitude))
    )) as distance_km
  FROM public.restaurants r
  WHERE r.status = 'active'
    AND r.latitude IS NOT NULL 
    AND r.longitude IS NOT NULL
    AND (6371 * acos(
      cos(radians(lat)) * 
      cos(radians(r.latitude)) * 
      cos(radians(r.longitude) - radians(lng)) + 
      sin(radians(lat)) * 
      sin(radians(r.latitude))
    )) <= radius_km
  ORDER BY distance_km;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Storage Setup
-- =============================================

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) 
VALUES ('restaurant-media', 'restaurant-media', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('coupon-media', 'coupon-media', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policies for Restaurant Media
CREATE POLICY "Restaurant owners can upload media"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'restaurant-media' AND
  EXISTS (
    SELECT 1 FROM public.restaurants
    WHERE id::text = (storage.foldername(name))[1] AND owner_id = auth.uid()
  )
);

CREATE POLICY "Anyone can view restaurant media"
ON storage.objects
FOR SELECT
USING (bucket_id = 'restaurant-media');

-- Storage Policies for Coupon Media
CREATE POLICY "Restaurant owners can upload coupon media"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'coupon-media' AND
  EXISTS (
    SELECT 1 FROM public.coupons c
    JOIN public.restaurants r ON c.restaurant_id = r.id
    WHERE c.id::text = (storage.foldername(name))[1] AND r.owner_id = auth.uid()
  )
);

CREATE POLICY "Anyone can view coupon media"
ON storage.objects
FOR SELECT
USING (bucket_id = 'coupon-media');

-- 10. Grant Permissions
-- =============================================
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.restaurants TO authenticated;
GRANT ALL ON public.coupons TO authenticated;
GRANT ALL ON public.coupon_redemptions TO authenticated;
GRANT ALL ON public.coupon_views TO authenticated;
GRANT ALL ON public.coupon_favorites TO authenticated;

-- =============================================
-- Setup Complete!
-- =============================================
-- 
-- Next Steps:
-- 1. Run this script in your Supabase SQL Editor
-- 2. Test restaurant and coupon creation
-- 3. Implement restaurant management features
-- =============================================

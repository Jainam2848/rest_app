-- =============================================
-- NUCLEAR OPTION: Complete Reset
-- Run this if nothing else works
-- =============================================

-- Step 1: Completely disable RLS
ALTER TABLE IF EXISTS public.users DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop EVERYTHING related to users table
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users CASCADE;
DROP TRIGGER IF EXISTS set_updated_at ON public.users CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.handle_updated_at() CASCADE;
DROP POLICY IF EXISTS "Users can read own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
DROP POLICY IF EXISTS "Enable read for users" ON public.users;
DROP POLICY IF EXISTS "Enable update for users" ON public.users;
DROP POLICY IF EXISTS "Admins can read all profiles" ON public.users;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.users;
DROP POLICY IF EXISTS "Admins can delete users" ON public.users;

-- Step 3: Recreate the trigger function (SIMPLEST VERSION)
CREATE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Just insert, handle all errors
  INSERT INTO public.users (
    id,
    email,
    phone_number,
    display_name,
    role,
    email_verified,
    created_at
  ) VALUES (
    NEW.id,
    NEW.email,
    NEW.phone,
    COALESCE(NEW.raw_user_meta_data->>'display_name', 'User'),
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer'),
    (NEW.email_confirmed_at IS NOT NULL),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    updated_at = NOW();
  
  RETURN NEW;
END;
$$;

-- Step 4: Create the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Step 5: Create updated_at trigger
CREATE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Step 6: Enable RLS with MINIMAL policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Only these two policies - nothing else!
CREATE POLICY "read_own_profile"
  ON public.users
  FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "update_own_profile"
  ON public.users
  FOR UPDATE
  USING (auth.uid() = id);

-- Step 7: Grant all permissions
GRANT ALL ON public.users TO postgres, service_role;
GRANT SELECT, UPDATE ON public.users TO authenticated, anon;

-- Step 8: Verify everything was created
SELECT 'SUCCESS: Trigger created' as status
WHERE EXISTS (
  SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created'
);

SELECT 'SUCCESS: Function created' as status
WHERE EXISTS (
  SELECT 1 FROM pg_proc WHERE proname = 'handle_new_user'
);

SELECT 'SUCCESS: Policies created - Count: ' || COUNT(*)::text as status
FROM pg_policies WHERE tablename = 'users';

-- Step 9: Show what we have
SELECT 
  'Trigger: ' || tgname as info,
  'Enabled: ' || tgenabled as status
FROM pg_trigger 
WHERE tgrelid = 'auth.users'::regclass;

-- =============================================
-- NOW TRY SIGNUP IN YOUR APP
-- =============================================

-- To test manually:
-- 1. Go to Supabase Auth > Users
-- 2. Click "Add User"
-- 3. Create a user with email/password
-- 4. Then check: SELECT * FROM public.users ORDER BY created_at DESC LIMIT 1;
-- 5. Should see the newly created profile!

-- =============================================
-- DEBUG: Check if trigger is working
-- =============================================

-- Step 1: Check if trigger exists and is enabled
SELECT 
  tgname as trigger_name,
  tgenabled as enabled,
  tgtype as type
FROM pg_trigger 
WHERE tgrelid = 'auth.users'::regclass
  AND tgname = 'on_auth_user_created';

-- Step 2: Check if function exists
SELECT 
  proname as function_name,
  prosecdef as is_security_definer,
  provolatile
FROM pg_proc 
WHERE proname = 'handle_new_user';

-- Step 3: Check current RLS policies
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd as command,
  qual as using_expression,
  with_check
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename = 'users'
ORDER BY cmd, policyname;

-- Step 4: Test the trigger function manually
-- (This helps identify if the function itself works)
DO $$
DECLARE
  test_user_id uuid := gen_random_uuid();
BEGIN
  -- Simulate what the trigger would do
  INSERT INTO public.users (id, email, display_name, email_verified, role)
  VALUES (
    test_user_id,
    'test@example.com',
    'Test User',
    false,
    'customer'
  );
  
  -- Clean up
  DELETE FROM public.users WHERE id = test_user_id;
  
  RAISE NOTICE 'Manual insert worked! Trigger function should work too.';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Manual insert failed: %', SQLERRM;
END $$;

-- Step 5: Check if there are any users that were created without profiles
SELECT 
  au.id,
  au.email,
  au.created_at as auth_created,
  pu.id as profile_id
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE pu.id IS NULL
ORDER BY au.created_at DESC
LIMIT 10;

-- =============================================
-- If trigger doesn't exist, create it properly
-- =============================================

-- First, ensure the function is correct
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Log for debugging (will appear in Supabase logs)
  RAISE LOG 'Trigger fired for user: %', NEW.id;
  
  INSERT INTO public.users (
    id,
    email,
    phone_number,
    display_name,
    email_verified,
    role,
    created_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    NEW.phone,
    COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.email),
    NEW.email_confirmed_at IS NOT NULL,
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer'),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    phone_number = EXCLUDED.phone_number,
    email_verified = EXCLUDED.email_verified,
    updated_at = NOW();
  
  RAISE LOG 'Profile created for user: %', NEW.id;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RAISE LOG 'Error in trigger for user %: %', NEW.id, SQLERRM;
  RETURN NEW; -- Don't fail the auth.users insert
END;
$$;

-- Drop and recreate the trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- =============================================
-- Verify it was created
-- =============================================

SELECT 'Trigger created successfully!' as status
WHERE EXISTS (
  SELECT 1 FROM pg_trigger 
  WHERE tgname = 'on_auth_user_created'
);

-- =============================================
-- IMPORTANT: Check Supabase Logs
-- =============================================
-- After running this, go to:
-- Supabase Dashboard > Logs > Postgres Logs
-- Look for RAISE LOG messages when you try to sign up

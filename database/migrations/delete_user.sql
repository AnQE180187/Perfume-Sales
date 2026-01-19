-- 1. Cập nhật bảng profiles (Quan trọng nhất)
ALTER TABLE public.profiles
DROP CONSTRAINT IF EXISTS profiles_id_fkey,
ADD CONSTRAINT profiles_id_fkey 
  FOREIGN KEY (id) 
  REFERENCES auth.users(id) 
  ON DELETE CASCADE;

-- 2. Cập nhật các bảng tham chiếu đến profiles
ALTER TABLE public.user_addresses
DROP CONSTRAINT IF EXISTS user_addresses_user_id_fkey,
ADD CONSTRAINT user_addresses_user_id_fkey 
  FOREIGN KEY (user_id) 
  REFERENCES public.profiles(id) 
  ON DELETE CASCADE;

ALTER TABLE public.chat_sessions
DROP CONSTRAINT IF EXISTS chat_sessions_user_id_fkey,
ADD CONSTRAINT chat_sessions_user_id_fkey 
  FOREIGN KEY (user_id) 
  REFERENCES public.profiles(id) 
  ON DELETE CASCADE;

ALTER TABLE public.quiz_results
DROP CONSTRAINT IF EXISTS quiz_results_user_id_fkey,
ADD CONSTRAINT quiz_results_user_id_fkey 
  FOREIGN KEY (user_id) 
  REFERENCES public.profiles(id) 
  ON DELETE CASCADE;

ALTER TABLE public.product_reviews
DROP CONSTRAINT IF EXISTS product_reviews_user_id_fkey,
ADD CONSTRAINT product_reviews_user_id_fkey 
  FOREIGN KEY (user_id) 
  REFERENCES public.profiles(id) 
  ON DELETE CASCADE;

ALTER TABLE public.notifications
DROP CONSTRAINT IF EXISTS notifications_user_id_fkey,
ADD CONSTRAINT notifications_user_id_fkey 
  FOREIGN KEY (user_id) 
  REFERENCES public.profiles(id) 
  ON DELETE CASCADE;
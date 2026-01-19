-- =========================================================
-- PERFUMEGPT – FINAL ENTERPRISE DATABASE SCHEMA
-- Target: Supabase PostgreSQL (Fresh Project)
-- Architecture: Next.js (BFF) + Supabase + Flutter
-- Status: FINAL – DATABASE FREEZE (100% COVERAGE)
-- =========================================================

-- ==============================
-- EXTENSIONS
-- ==============================
create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";
create extension if not exists vector;
create extension if not exists pg_trgm;

-- ==============================
-- ENUMS
-- ==============================
create type order_status as enum
  ('pending','confirmed','packing','shipping','completed','cancelled','returned');

create type payment_status as enum
  ('pending','paid','failed','refunded','cod_pending');

create type refund_status as enum
  ('requested','approved','rejected','processed');

create type promotion_type as enum
  ('percentage','fixed_amount','combo','free_sample');

create type promotion_scope as enum
  ('order','product','category');

create type notification_channel as enum
  ('push','email','sms');

create type pos_session_status as enum
  ('open','closed');

create type ai_request_type as enum
  ('chat','quiz','semantic_search','review_summary','forecast');

create type marketing_campaign_status as enum
  ('draft','scheduled','running','sent','cancelled');

create type shipment_status as enum
  ('pending','picked_up','in_transit','delivered','failed','returned');

create type sales_channel as enum
  ('web','mobile','pos','shopee');

create type shipping_provider as enum
  ('ghn','ghtk');

create type import_status as enum
  ('draft','confirmed','cancelled');

create type account_status as enum
  ('active','suspended','banned');

create type staff_role as enum
  ('manager','cashier','inventory');

-- ==============================
-- STORES
-- ==============================
create table stores (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  phone text,
  is_active boolean default true,
  created_at timestamptz default now()
);

-- ==============================
-- PROFILES (Auth.users extension)
-- ==============================
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  avatar_url text,
  scent_preferences jsonb,
  budget_range jsonb,
  style_preferences text[],
  account_status account_status default 'active',
  last_consulted_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table user_status_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id),
  old_status account_status,
  new_status account_status,
  changed_by uuid references profiles(id),
  reason text,
  created_at timestamptz default now()
);

-- ==============================
-- RBAC
-- ==============================
create table roles (
  id uuid primary key default gen_random_uuid(),
  code text unique not null
);

insert into roles (code)
values ('admin'),('staff'),('customer'),('ai_consultant')
on conflict do nothing;

create table permissions (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  description text
);

create table role_permissions (
  role_id uuid references roles(id) on delete cascade,
  permission_id uuid references permissions(id) on delete cascade,
  primary key (role_id, permission_id)
);

create table user_roles (
  user_id uuid references profiles(id) on delete cascade,
  role_id uuid references roles(id) on delete cascade,
  primary key (user_id, role_id)
);

-- ==============================
-- STORE STAFF
-- ==============================
create table store_staffs (
  store_id uuid references stores(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  role staff_role not null,
  is_active boolean default true,
  assigned_at timestamptz default now(),
  primary key (store_id, user_id)
);

-- ==============================
-- SUPPLIERS & IMPORT
-- ==============================
create table suppliers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text,
  email text,
  address text
);

create table import_documents (
  id uuid primary key default gen_random_uuid(),
  supplier_id uuid references suppliers(id),
  store_id uuid references stores(id),
  status import_status default 'draft',
  total_cost numeric,
  imported_by uuid references profiles(id),
  imported_at timestamptz default now()
);

create table import_items (
  id uuid primary key default gen_random_uuid(),
  import_document_id uuid references import_documents(id) on delete cascade,
  variant_id uuid,
  quantity int check (quantity > 0),
  unit_cost numeric,
  total_cost numeric generated always as (quantity * unit_cost) stored
);

-- ==============================
-- PRODUCT CATALOG
-- ==============================
create table brands (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  origin_country text
);

create table categories (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  slug text unique
);

create table products (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid references brands(id),
  category_id uuid references categories(id),
  name text not null,
  slug text unique,
  description text,
  gender text,
  seasons text[],
  occasions text[],
  styles text[],
  scent_notes jsonb,
  embedding vector(1536),
  ai_summary text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  deleted_at timestamptz
);

create index idx_products_embedding
on products using ivfflat (embedding vector_cosine_ops);

create table product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete cascade,
  sku text unique not null,
  barcode text,
  volume_ml int,
  concentration text,
  price numeric(12,2),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create unique index idx_variant_barcode_not_null
on product_variants(barcode)
where barcode is not null;

create table product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete cascade,
  image_url text not null,
  position int default 0,
  created_at timestamptz default now()
);

-- ==============================
-- INVENTORY
-- ==============================
create table product_batches (
  id uuid primary key default gen_random_uuid(),
  variant_id uuid references product_variants(id),
  store_id uuid references stores(id),
  import_document_id uuid references import_documents(id),
  batch_code text,
  quantity int check (quantity >= 0),
  expiry_date date,
  import_price numeric,
  created_at timestamptz default now()
);

create table inventory (
  id uuid primary key default gen_random_uuid(),
  variant_id uuid references product_variants(id),
  store_id uuid references stores(id),
  quantity int default 0,
  updated_at timestamptz default now(),
  unique (variant_id, store_id)
);

create table inventory_logs (
  id uuid primary key default gen_random_uuid(),
  variant_id uuid,
  store_id uuid,
  change int,
  reason text,
  reference_id uuid,
  created_at timestamptz default now()
);

create table inventory_alerts (
  id uuid primary key default gen_random_uuid(),
  variant_id uuid references product_variants(id),
  store_id uuid references stores(id),
  alert_type text check (alert_type in ('low_stock','expiry_soon')),
  threshold int,
  triggered_at timestamptz default now(),
  resolved boolean default false,
  resolved_at timestamptz
);

-- ==============================
-- POS & ORDERS
-- ==============================
create table pos_sessions (
  id uuid primary key default gen_random_uuid(),
  staff_id uuid references profiles(id),
  store_id uuid references stores(id),
  opened_at timestamptz default now(),
  closed_at timestamptz,
  status pos_session_status default 'open'
);

create table orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id),
  staff_id uuid references profiles(id),
  store_id uuid references stores(id),
  pos_session_id uuid references pos_sessions(id),
  status order_status default 'pending',
  channel sales_channel,
  total_amount numeric,
  discount_amount numeric default 0,
  final_amount numeric,
  receiver_name text,
  receiver_phone text,
  shipping_address jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id) on delete cascade,
  variant_id uuid references product_variants(id),
  product_name_snapshot text,
  variant_snapshot jsonb,
  quantity int,
  unit_price numeric,
  total_price numeric
);

create table order_status_logs (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id) on delete cascade,
  old_status order_status,
  new_status order_status,
  changed_by uuid references profiles(id),
  note text,
  created_at timestamptz default now()
);

-- ==============================
-- PAYMENT & REFUND
-- ==============================
create table payment_transactions (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id),
  provider text,
  transaction_code text,
  amount numeric,
  status payment_status,
  is_cod boolean default false,
  paid_at timestamptz,
  raw_response jsonb,
  created_at timestamptz default now(),
  unique (order_id, provider)
);

create table refunds (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id),
  payment_transaction_id uuid references payment_transactions(id),
  status refund_status default 'requested',
  refund_amount numeric not null,
  reason text,
  requested_by uuid references profiles(id),
  processed_by uuid references profiles(id),
  processed_at timestamptz,
  created_at timestamptz default now()
);

-- ==============================
-- SHIPPING
-- ==============================
create table shipments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id),
  provider shipping_provider,
  tracking_code text,
  status shipment_status,
  shipping_fee numeric default 0,
  fee_snapshot jsonb,
  updated_at timestamptz default now()
);

-- ==============================
-- AI MODULE
-- ==============================
create table ai_models (
  id uuid primary key default gen_random_uuid(),
  provider text,
  model_name text,
  version text,
  is_active boolean default true
);

create table ai_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id),
  request_type ai_request_type,
  latency_ms int,
  success boolean,
  created_at timestamptz default now()
);

create table ai_fallback_logs (
  id uuid primary key default gen_random_uuid(),
  request_id uuid references ai_requests(id),
  fallback_type text,
  reason text,
  created_at timestamptz default now()
);

create table ai_recommendations (
  id uuid primary key default gen_random_uuid(),
  ai_request_id uuid references ai_requests(id),
  user_id uuid references profiles(id),
  product_id uuid references products(id),
  rank int,
  explanation text,
  accepted boolean,
  accepted_at timestamptz,
  created_at timestamptz default now()
);

-- ==============================
-- PROMOTION & LOYALTY
-- ==============================
create table promotions (
  id uuid primary key default gen_random_uuid(),
  code text unique,
  name text,
  type promotion_type,
  value numeric,
  scope promotion_scope,
  conditions jsonb,
  start_date timestamptz,
  end_date timestamptz,
  is_active boolean default true
);

create table promotion_targets (
  id uuid primary key default gen_random_uuid(),
  promotion_id uuid references promotions(id),
  target_type text,
  target_id uuid
);

create table promotion_usages (
  id uuid primary key default gen_random_uuid(),
  promotion_id uuid references promotions(id),
  order_id uuid references orders(id),
  user_id uuid references profiles(id),
  discount_amount numeric,
  used_at timestamptz default now(),
  unique (promotion_id, order_id)
);

create table loyalty_accounts (
  user_id uuid primary key references profiles(id),
  current_points int default 0,
  updated_at timestamptz default now()
);

create table loyalty_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id),
  order_id uuid references orders(id),
  points_change int,
  reason text,
  created_at timestamptz default now(),
  unique (user_id, order_id)
);

-- ==============================
-- NOTIFICATIONS & MARKETING
-- ==============================
create table notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id),
  channel notification_channel,
  title text,
  content text,
  metadata jsonb,
  is_read boolean default false,
  sent_at timestamptz,
  created_at timestamptz default now()
);

create table marketing_campaigns (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  channel notification_channel,
  status marketing_campaign_status default 'draft',
  scheduled_at timestamptz,
  content jsonb,
  created_by uuid references profiles(id),
  created_at timestamptz default now()
);

create table marketing_campaign_targets (
  campaign_id uuid references marketing_campaigns(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  primary key (campaign_id, user_id)
);

-- ==============================
-- OMNICHANNEL & AUDIT
-- ==============================
create table external_orders (
  id uuid primary key default gen_random_uuid(),
  channel sales_channel,
  external_order_id text,
  internal_order_id uuid references orders(id),
  raw_payload jsonb,
  synced_at timestamptz default now(),
  unique (channel, external_order_id)
);

create table audit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  action text,
  target_table text,
  target_id uuid,
  metadata jsonb,
  created_at timestamptz default now()
);

-- ==============================
-- TRIGGERS & FUNCTIONS
-- ==============================

-- Trigger to handle new user registration
create or replace function public.handle_new_user()
returns trigger as $$
declare
  customer_role_id uuid;
begin
  -- 1. Create Profile
  insert into public.profiles (id, full_name, phone, avatar_url, account_status)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'phone',
    new.raw_user_meta_data->>'avatar_url',
    'active'
  );

  -- 2. Assign 'customer' role
  select id into customer_role_id from public.roles where code = 'customer';
  if customer_role_id is not null then
    insert into public.user_roles (user_id, role_id)
    values (new.id, customer_role_id);
  end if;

  -- 3. Initialize Loyalty Account
  insert into public.loyalty_accounts (user_id, current_points)
  values (new.id, 0);

  return new;
end;
$$ language plpgsql security definer;

-- Create the trigger
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Updated At Trigger Function
create or replace function update_updated_at_column()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language 'plpgsql';

-- Apply updated_at to relevant tables
create trigger update_profiles_updated_at before update on profiles for each row execute procedure update_updated_at_column();
create trigger update_products_updated_at before update on products for each row execute procedure update_updated_at_column();
create trigger update_product_variants_updated_at before update on product_variants for each row execute procedure update_updated_at_column();
create trigger update_orders_updated_at before update on orders for each row execute procedure update_updated_at_column();

-- ==============================
-- SECURITY (RLS)
-- ==============================

-- 1. Enable RLS on core tables
alter table profiles enable row level security;
alter table roles enable row level security;
alter table user_roles enable row level security;
alter table loyalty_accounts enable row level security;
alter table products enable row level security;
alter table product_variants enable row level security;
alter table categories enable row level security;
alter table brands enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;

-- 2. Drop existing policies to prevent conflicts
drop policy if exists "Public profiles are viewable by everyone" on profiles;
drop policy if exists "Users can update own profile" on profiles;
drop policy if exists "Roles are viewable by authenticated users" on roles;
drop policy if exists "User roles are viewable by owner" on user_roles;
drop policy if exists "Users can view own loyalty points" on loyalty_accounts;
drop policy if exists "Products are viewable by everyone" on products;
drop policy if exists "Variants are viewable by everyone" on product_variants;
drop policy if exists "Categories are viewable by everyone" on categories;
drop policy if exists "Brands are viewable by everyone" on brands;
drop policy if exists "Users can view own orders" on orders;
drop policy if exists "Users can view own order items" on order_items;

-- 3. Define Policies
create policy "Public profiles are viewable by everyone" on profiles for select using (true);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);

create policy "Roles are viewable by authenticated users" on roles for select using (auth.role() = 'authenticated');
create policy "User roles are viewable by owner" on user_roles for select using (auth.uid() = user_id);

create policy "Users can view own loyalty points" on loyalty_accounts for select using (auth.uid() = user_id);

create policy "Products are viewable by everyone" on products for select using (true);
create policy "Variants are viewable by everyone" on product_variants for select using (true);
create policy "Categories are viewable by everyone" on categories for select using (true);
create policy "Brands are viewable by everyone" on brands for select using (true);

create policy "Users can view own orders" on orders for select using (auth.uid() = user_id);
create policy "Users can view own order items" on order_items for select 
  using (exists (select 1 from orders where orders.id = order_items.order_id and orders.user_id = auth.uid()));

-- ==============================
-- GRANTS
-- ==============================
grant usage on schema public to anon, authenticated;
grant select on all tables in schema public to anon, authenticated;
grant insert, update on profiles to authenticated;
grant insert, update on orders to authenticated;
grant insert on order_items to authenticated;
grant insert, update on loyalty_accounts to authenticated;

-- Enable real-time
alter publication supabase_realtime add table orders;
alter publication supabase_realtime add table notifications;

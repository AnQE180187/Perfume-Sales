-- ==============================
-- COLLECTIONS & CURATION
-- ==============================
create table if not exists collections (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  description text,
  image_url text,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists collection_products (
  collection_id uuid references collections(id) on delete cascade,
  product_id uuid references products(id) on delete cascade,
  position int default 0,
  primary key (collection_id, product_id)
);

-- Enable RLS
alter table collections enable row level security;
alter table collection_products enable row level security;

-- Policies
create policy "Collections are viewable by everyone" on collections for select using (true);
create policy "Collection products are viewable by everyone" on collection_products for select using (true);

-- Trigger for updated_at
create trigger update_collections_updated_at before update on collections for each row execute procedure update_updated_at_column();

-- Seed some collections
insert into collections (name, slug, description, image_url)
values 
('Signature Collection', 'signature', 'Our most iconic and timeless scents.', '/images/collection-banner.png'),
('Summer Essentials', 'summer-essentials', 'Fresh and vibrant fragrances for sunny days.', '/images/collection-banner.png'),
('Midnight Mystery', 'midnight-mystery', 'Deep, seductive, and enigmatic aromas.', '/images/collection-banner.png')
on conflict do nothing;

-- Grants
grant select on table collections to anon, authenticated, service_role;
grant select on table collection_products to anon, authenticated, service_role;

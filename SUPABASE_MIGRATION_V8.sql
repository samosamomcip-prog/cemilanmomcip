-- CEMILAN MOMCIP V8.0
-- Multi-user hardening: least-privilege grants, active-user RLS,
-- immutable audit trail, secure views/functions, timestamps, and indexes.

begin;

-- Explicit Data API grants (required by current Supabase defaults).
revoke all on all tables in schema public from anon;
revoke all on all sequences in schema public from anon;

revoke all on table
  public.products,
  public.raw_materials,
  public.packaging,
  public.orders,
  public.order_items,
  public.raw_material_transactions,
  public.packaging_transactions,
  public.productions,
  public.production_raw_materials,
  public.production_packaging,
  public.audit_trail,
  public.user_profiles
from authenticated;

grant select, insert, update, delete on table
  public.products,
  public.raw_materials,
  public.packaging,
  public.orders,
  public.order_items,
  public.raw_material_transactions,
  public.packaging_transactions,
  public.productions,
  public.production_raw_materials,
  public.production_packaging
to authenticated;

grant select, insert on table public.audit_trail to authenticated;
grant select on table public.user_profiles to authenticated;

-- Profiles: a user only reads their own profile. Profile creation remains
-- controlled by the auth.users trigger.
drop policy if exists authenticated_all_user_profiles on public.user_profiles;
drop policy if exists users_read_own_profile on public.user_profiles;
create policy users_read_own_profile
on public.user_profiles
for select
to authenticated
using (user_id = (select auth.uid()));

-- Shared business data: every active authenticated user can work with all
-- operational rows. An inactive profile cannot use the Data API.
drop policy if exists authenticated_all_products on public.products;
create policy active_users_shared_access on public.products
for all to authenticated
using (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif))
with check (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif));

drop policy if exists authenticated_all_raw_materials on public.raw_materials;
create policy active_users_shared_access on public.raw_materials
for all to authenticated
using (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif))
with check (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif));

drop policy if exists authenticated_all_packaging on public.packaging;
create policy active_users_shared_access on public.packaging
for all to authenticated
using (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif))
with check (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif));

drop policy if exists authenticated_all_orders on public.orders;
create policy active_users_shared_access on public.orders
for all to authenticated
using (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif))
with check (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif));

drop policy if exists authenticated_all_order_items on public.order_items;
create policy active_users_shared_access on public.order_items
for all to authenticated
using (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif))
with check (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif));

drop policy if exists authenticated_all_raw_material_transactions on public.raw_material_transactions;
create policy active_users_shared_access on public.raw_material_transactions
for all to authenticated
using (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif))
with check (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif));

drop policy if exists authenticated_all_packaging_transactions on public.packaging_transactions;
create policy active_users_shared_access on public.packaging_transactions
for all to authenticated
using (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif))
with check (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif));

drop policy if exists authenticated_all_productions on public.productions;
create policy active_users_shared_access on public.productions
for all to authenticated
using (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif))
with check (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif));

drop policy if exists authenticated_all_production_raw_materials on public.production_raw_materials;
create policy active_users_shared_access on public.production_raw_materials
for all to authenticated
using (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif))
with check (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif));

drop policy if exists authenticated_all_production_packaging on public.production_packaging;
create policy active_users_shared_access on public.production_packaging
for all to authenticated
using (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif))
with check (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif));

-- Audit is shared and append-only. Existing history cannot be edited/deleted
-- from the public client.
drop policy if exists authenticated_all_audit_trail on public.audit_trail;
drop policy if exists active_users_read_audit on public.audit_trail;
drop policy if exists active_users_insert_audit on public.audit_trail;
create policy active_users_read_audit
on public.audit_trail
for select to authenticated
using (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif));
create policy active_users_insert_audit
on public.audit_trail
for insert to authenticated
with check (exists (select 1 from public.user_profiles p where p.user_id = (select auth.uid()) and p.aktif));

-- Views must respect the querying user's RLS policies.
alter view public.finish_good_stock set (security_invoker = true);
alter view public.production_costing set (security_invoker = true);
alter view public.product_costing set (security_invoker = true);
revoke all on table public.finish_good_stock, public.production_costing, public.product_costing from anon, authenticated;
grant select on table public.finish_good_stock, public.production_costing, public.product_costing to authenticated;

-- Trigger helpers are internal implementation details, not public RPCs.
alter function public.update_updated_at_column() set search_path = pg_catalog;
alter function public.handle_new_user() set search_path = pg_catalog;
alter function public.set_audit_user() set search_path = pg_catalog;
revoke all on function public.update_updated_at_column() from public, anon, authenticated;
revoke all on function public.handle_new_user() from public, anon, authenticated;
revoke all on function public.set_audit_user() from public, anon, authenticated;

-- Child rows also carry an update timestamp for synchronization diagnostics.
alter table public.order_items add column if not exists updated_at timestamptz not null default now();
alter table public.production_raw_materials add column if not exists updated_at timestamptz not null default now();
alter table public.production_packaging add column if not exists updated_at timestamptz not null default now();

drop trigger if exists update_order_items_updated_at on public.order_items;
create trigger update_order_items_updated_at before update on public.order_items
for each row execute function public.update_updated_at_column();
drop trigger if exists update_production_raw_materials_updated_at on public.production_raw_materials;
create trigger update_production_raw_materials_updated_at before update on public.production_raw_materials
for each row execute function public.update_updated_at_column();
drop trigger if exists update_production_packaging_updated_at on public.production_packaging;
create trigger update_production_packaging_updated_at before update on public.production_packaging
for each row execute function public.update_updated_at_column();

-- Cover foreign keys and frequent sort/filter paths used by the app.
create index if not exists idx_orders_created_by on public.orders(created_by);
create index if not exists idx_orders_updated_by on public.orders(updated_by);
create index if not exists idx_order_items_created_by on public.order_items(created_by);
create index if not exists idx_order_items_updated_by on public.order_items(updated_by);
create index if not exists idx_productions_created_by on public.productions(created_by);
create index if not exists idx_productions_updated_by on public.productions(updated_by);
create index if not exists idx_raw_tx_material_id on public.raw_material_transactions(material_id);
create index if not exists idx_raw_tx_production_id on public.raw_material_transactions(production_id);
create index if not exists idx_raw_tx_created_by on public.raw_material_transactions(created_by);
create index if not exists idx_raw_tx_updated_by on public.raw_material_transactions(updated_by);
create index if not exists idx_pack_tx_packaging_id on public.packaging_transactions(packaging_id);
create index if not exists idx_pack_tx_production_id on public.packaging_transactions(production_id);
create index if not exists idx_pack_tx_created_by on public.packaging_transactions(created_by);
create index if not exists idx_pack_tx_updated_by on public.packaging_transactions(updated_by);
create index if not exists idx_prod_rm_material_id on public.production_raw_materials(material_id);
create index if not exists idx_prod_rm_created_by on public.production_raw_materials(created_by);
create index if not exists idx_prod_rm_updated_by on public.production_raw_materials(updated_by);
create index if not exists idx_prod_pack_packaging_id on public.production_packaging(packaging_id);
create index if not exists idx_prod_pack_created_by on public.production_packaging(created_by);
create index if not exists idx_prod_pack_updated_by on public.production_packaging(updated_by);
create index if not exists idx_products_created_by on public.products(created_by);
create index if not exists idx_products_updated_by on public.products(updated_by);
create index if not exists idx_raw_materials_created_by on public.raw_materials(created_by);
create index if not exists idx_raw_materials_updated_by on public.raw_materials(updated_by);
create index if not exists idx_packaging_created_by on public.packaging(created_by);
create index if not exists idx_packaging_updated_by on public.packaging(updated_by);
create index if not exists idx_audit_trail_created_by on public.audit_trail(created_by);
create index if not exists idx_audit_trail_updated_by on public.audit_trail(updated_by);

commit;

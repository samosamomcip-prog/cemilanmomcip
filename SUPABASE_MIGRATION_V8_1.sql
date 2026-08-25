-- Follow-up for projects that already applied cemilan_momcip_v8_multi_user_hardening.
begin;

revoke all on table public.finish_good_stock, public.production_costing, public.product_costing from anon, authenticated;
grant select on table public.finish_good_stock, public.production_costing, public.product_costing to authenticated;

-- Keep the pre-existing equivalent indexes and remove only V8 duplicates.
drop index if exists public.idx_order_items_order_id;
drop index if exists public.idx_order_items_product_id;
drop index if exists public.idx_orders_order_date;
drop index if exists public.idx_prod_pack_production_id;
drop index if exists public.idx_prod_rm_production_id;
drop index if exists public.idx_productions_product_id;
drop index if exists public.idx_productions_production_date;

create index if not exists idx_audit_trail_created_by on public.audit_trail(created_by);
create index if not exists idx_audit_trail_updated_by on public.audit_trail(updated_by);

commit;

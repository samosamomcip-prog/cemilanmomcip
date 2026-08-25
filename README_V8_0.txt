CEMILAN MOMCIP V8.0
- Hotfix V8.0.1: audit duplikat tidak lagi membuat sinkronisasi order berulang dengan respons 409.
- Order lama tetap tampil setelah order baru disimpan dan diverifikasi dari cloud.
- Sinkronisasi multi-user per baris; salinan perangkat lama tidak lagi mengunggah ulang seluruh database.
- Refresh background mempertahankan semua isi form dan posisi kursor.
- Service worker tidak lagi me-reload aplikasi otomatis saat user sedang input.
- Transaksi baru diverifikasi kembali dari Supabase setelah disimpan.
- Konflik perubahan bersamaan mempertahankan data cloud dan tidak menghapus transaksi user lain.
- Saldo stok dihitung dari transaksi, bukan ditimpa oleh saldo perangkat.
- RLS, grant, audit user, view security, dan index database diperketat melalui SUPABASE_MIGRATION_V8.sql.

CEMILAN MOMCIP V8.0
- Sinkronisasi multi-user per baris; salinan perangkat lama tidak lagi mengunggah ulang seluruh database.
- Refresh background mempertahankan semua isi form dan posisi kursor.
- Service worker tidak lagi me-reload aplikasi otomatis saat user sedang input.
- Transaksi baru diverifikasi kembali dari Supabase setelah disimpan.
- Konflik perubahan bersamaan mempertahankan data cloud dan tidak menghapus transaksi user lain.
- Saldo stok dihitung dari transaksi, bukan ditimpa oleh saldo perangkat.
- RLS, grant, audit user, view security, dan index database diperketat melalui SUPABASE_MIGRATION_V8.sql.

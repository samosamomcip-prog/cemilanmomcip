CEMILAN MOMCIP V6.8 ONLINE - MULTI USER AUDIT

Perubahan utama:
- Terhubung ke public.user_profiles untuk membaca nama user login.
- Setiap input baru menyimpan identitas pembuat (UID di belakang layar, nama user untuk tampilan).
- Edit data menyimpan user terakhir yang mengubah.
- Kolom Input Oleh/Dibuat Oleh ditampilkan pada Order, Raw Material, Packaging, Produksi, dan Master.
- Riwayat Perubahan menampilkan nama User.
- Laporan pembelian RM, pembelian Packaging, dan hasil Produksi menampilkan Input Oleh pada detail.
- Shared-state multi-device memakai timestamp updatedAt agar edit terbaru lebih diprioritaskan saat merge.
- Mirror tabel Supabase dibuat non-destruktif: data yang tidak berubah tidak dihapus lalu diinsert ulang, sehingga audit created_by/updated_by tidak mudah tertimpa user lain.
- Child table order_items / production usage memakai ID UUID stabil untuk sinkronisasi mirror.
- Status Online tetap berada di atas tombol Keluar seperti V6.7.

Prasyarat database:
1. public.user_profiles sudah dibuat.
2. Trigger auto-create user profile sudah dibuat.
3. Kolom created_by, created_by_name, updated_by, updated_by_name dan trigger set_audit_user sudah dibuat pada tabel aplikasi.

Catatan:
- Data lama yang dibuat sebelum V6.8 dapat tampil dengan User '-' karena belum memiliki histori pembuat.
- Data baru setelah V6.8 akan otomatis memakai nama dari user_profiles.

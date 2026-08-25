CEMILAN MOMCIP V6 ONLINE

- Data utama tersinkron ke Supabase.
- Login menggunakan Supabase Authentication.
- Project URL: https://xwnwsjwhizpoukqctylp.supabase.co
- Hanya Publishable Key dipakai di frontend. Secret key TIDAK dipakai.
- localStorage tetap dipakai sebagai cache lokal agar UI tetap cepat.
- Saat login pertama:
  * Jika database Supabase sudah berisi data, aplikasi menarik data online.
  * Jika database Supabase kosong, data lokal V5.1 diunggah sebagai migrasi awal.
- Setiap perubahan lokal memicu sinkronisasi penuh ke database online.

CATATAN:
Untuk penggunaan multi-user bersamaan dalam skala lebih besar, model sinkronisasi sebaiknya dikembangkan menjadi transaksi per-record/realtime. V6 ini ditujukan untuk tahap migrasi online dan penggunaan operasional ringan.

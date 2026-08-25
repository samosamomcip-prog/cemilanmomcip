CEMILAN MOMCIP WEBAPP V7.1 - ROW-LEVEL MULTI USER SYNC

Perubahan utama:
- Menghapus shared snapshot sebagai mekanisme sync utama.
- Supabase normalized tables menjadi source of truth.
- Upsert per row, aman untuk input paralel dari banyak user/device.
- Durable delete queue agar delete tidak hilang saat offline/refresh.
- Pending local recovery sebelum cloud pull.
- Cloud pull hanya sesudah write sukses; data dirty tidak ditimpa.
- Child reconciliation untuk order_items dan usage produksi.
- Status Online hanya setelah write + read-back cloud berhasil.

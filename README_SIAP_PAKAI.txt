CEMILAN MOMCIP WEBAPP V3

Revisi utama:
- Branding: CEMILAN MOMCIP / Homemade Snack & Drink With Love
- Logo dipertahankan
- Tabel operasional dibuat fit-to-content
- Printer thermal 57 / 75 / 80 mm untuk struk dan outstanding produksi
- Logo tampil pada struk
- Laporan layar: detail penjualan per tanggal, tanpa detail nomor order
- Print Ringkasan YTD/MTD: ringkasan per produk YTD & MTD + grafik penjualan
- Print Detail Penjualan: detail per tanggal dan produk
- Ringkasan YTD & grafik hanya tampil pada hasil print
- Master item tetap dapat dihapus jika belum memiliki transaksi/stok

UPDATE GITHUB PAGES:
Upload/replace seluruh file ke repository mini-erp-samosa pada branch main.
GitHub Pages akan deploy ulang otomatis. Jika tampilan lama masih muncul, refresh/clear cache atau tunggu service worker V3 aktif.

UPDATE V4
- Input Order sekarang memiliki UNIT: PCS / PACK.
- Konversi PACK ke PCS berdasarkan Isi/Pack pada Master Produk.
- Harga Reguler dan Reseller dapat dibedakan per PCS dan per PACK.
- Stok FG, outstanding produksi, dan HPP tetap dihitung menggunakan PCS sebagai unit dasar.
- Struk menampilkan Qty sesuai unit order, contoh 5 PACK (50 pcs).

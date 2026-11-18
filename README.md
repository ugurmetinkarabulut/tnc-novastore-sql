# NovaStore Veri Yönetim Sistemi

SQL Server için beş ilişkili tablo, örnek veriler, altı analiz sorgusu, sipariş özet görünümü ve yedekleme komutu.

## Çalıştırma

SQL Server 2019 veya üstünde, GO batch ayırıcısını destekleyen SSMS veya sqlcmd ile `UgurMetinKarabulut_NovaStore_Proje.sql` dosyasını çalıştır.

Veritabanı ve tablolar ilk çalıştırmada oluşturulur. Örnek veri, beş tablo da boşsa bir transaction içerisinde eklenir. Tekrar çalıştırmak mevcut kayıtlara yeni örnekler eklemez. Betik mevcut veritabanını silmez.

Windows üzerinde yedekleme için sunucuda `C:\Yedek` klasörü ve SQL Server servis hesabının yazma yetkisi gerekir. Linux üzerinde yedek `/var/opt/mssql/data/NovaStoreDB.bak` konumuna yazılır.

Örnek müşteri e-postaları example.com alan adını kullanır. Ürün fiyatları ve müşteri kayıtları eğitim için hazırlanmıştır. Şema yönergedeki alanları kullanır. Sipariş toplamları örnek verideki ürün fiyatları ve adetler üzerinden hesaplanır. Gerçek bir satış sisteminde sipariş anındaki fiyat ayrıca saklanmalıdır.

## Teslim

- UgurMetinKarabulut_NovaStore_Proje.sql
- UgurMetinKarabulut_NovaStore_Proje.docx
- UgurMetinKarabulut_NovaStore_Proje.png

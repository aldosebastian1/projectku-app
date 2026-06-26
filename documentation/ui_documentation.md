# 💎 Dokumentasi Sistem Desain UI/UX — ProjectKu v4

## Calm Workspace Edition

Dokumen ini adalah panduan referensi komprehensif sistem desain UI/UX untuk **ProjectKu (Freelancer Workspace)**.

Arah visual aplikasi terinspirasi dari aplikasi produktivitas yang tenang (*calm productivity*) dan antarmuka editorial yang mengutamakan: ruang nafas (*breathing room*), kontras lembut (*soft contrast*), hierarki minimal, kebisingan visual rendah, dan kesederhanaan premium. Antarmuka ini dirancang agar terasa seperti alat kerja harian yang bisa digunakan berjam-jam tanpa kelelahan visual.

---

# 🎨 1. Fondasi Token Visual

## Filosofi Desain

Antarmuka referensi mengikuti empat prinsip utama:
1.  **Soft Contrast:** Tidak ada warna hitam pekat atau putih murni untuk mencegah ketegangan mata.
2.  **Monochromatic Surfaces:** Sebagian besar elemen berasal dari satu keluarga warna.
3.  **Low Visual Noise:** Hampir tidak ada bayangan, gradien, atau efek cahaya.
4.  **Generous White Space:** Jarak antar elemen menciptakan hierarki, bukan warna.

---

# Sistem Warna (Color System)

## Base Background
```dart
static const Color baseBackground = Color(0xFFF2F5F9);
```
Abu-abu netral lembut — tidak pernah menggunakan putih murni.

## Surface Background
```dart
static const Color surfaceBackground = Color(0xFFF7F9FC);
```
Digunakan untuk kartu default, seksi, dan kontainer input.

## Elevated Surface
```dart
static const Color elevatedSurface = Color(0xFFFFFFFF);
```
Digunakan khusus untuk kartu aktif, dialog, dan bottom sheets.

## Border
```dart
static const Color border = Color(0xFFE8EDF3);
```
Digunakan untuk pembatas, garis tepi, segmented control, dan outline input.

---

# Warna Teks (Typography Colors)

## Text Primary
```dart
static const Color textPrimary = Color(0xFF111827);
```

## Text Secondary
```dart
static const Color textColorSecondary = Color(0xFF6B7280);
```

## Text Tertiary
```dart
static const Color textTertiary = Color(0xFF9CA3AF);
```

---

# Sistem Aksen (Accent System)

Sistem referensi menggunakan aksen sesedikit mungkin.

## Primary Accent
```dart
static const Color primaryAccent = Color(0xFF5C7CFA);
```
Digunakan untuk tab aktif, status fokus, dan tombol utama (maksimal 10% penggunaan).

## Success Accent
```dart
static const Color successAccent = Color(0xFF6FCF97);
```
Digunakan untuk statistik positif dan badge status selesai/terbayar.

## Warning Accent
```dart
static const Color warningAccent = Color(0xFFF2C94C);
```
Digunakan untuk tag peringatan dan status tertunda.

## Error Accent
```dart
static const Color errorAccent = Color(0xFFEB5757);
```
Digunakan untuk peringatan error dan indikator tenggat terlewat.

---

# Rasio Penggunaan Warna
```text
85% Netral (abu-abu)
10% Primer (indigo)
 5% Semantik (hijau, oranye, merah)
```

---

# 🔠 2. Sistem Tipografi

## Keluarga Font
Gunakan **Inter** via `google_fonts` untuk tampilan minimal dan tenang.

| Gaya           | Ukuran | Ketebalan |
| -------------- | ------ | --------- |
| Display Large  | 34     | w700      |
| Heading Large  | 28     | w600      |
| Heading Medium | 22     | w600      |
| Title          | 18     | w600      |
| Body           | 16     | w400      |
| Caption        | 14     | w400      |
| Small          | 12     | w400      |

Sebagian besar teks menggunakan ketebalan ringan (`400`, `500`, `600`). Ketebalan berat (`800`, `900`) dihindari agar antarmuka terasa ramah dan tidak kaku.

---

# 📏 3. Sistem Jarak (Spacing System)

## Skala
`4`, `8`, `12`, `16`, `24`, `32`, `48`, `64`

## Aturan Layout
*   Antar section: `32px`
*   Antar card: `16px`
*   Konten di dalam card: `24px`

---

# Sistem Corner Radius

| Elemen           | Radius |
|------------------|--------|
| Kartu utama      | `24`   |
| Input form       | `16`   |
| Segmented control| `14`   |
| Chip kecil       | `12`   |

---

# 🌑 4. Sistem Elevasi (Elevation System)

## Level 1 — Shadow kartu sangat lembut
```dart
BoxShadow(
  color: Colors.black.withValues(alpha: .03),
  blurRadius: 20,
  offset: Offset(0, 4),
)
```

## Level 2 — Bottom sheets & dialog
```dart
BoxShadow(
  color: Colors.black.withValues(alpha: .05),
  blurRadius: 24,
  offset: Offset(0, 8),
)
```
Tidak ada glow, tidak ada shadow berwarna, tidak ada shadow besar.

---

# 🏗️ 5. Arsitektur Komponen

## Komponen Reusable

### StatusChip (`lib/views/widgets/status_chip.dart`)
Komponen pill status dengan titik indikator berwarna sesuai kondisi:
- 🔵 **In Progress / Aktif** — Primary Accent (`0xFF5C7CFA`)
- 🟢 **Completed / Lunas** — Success Accent (`0xFF6FCF97`)
- 🟡 **Invoice / Tertunda** — Warning Accent (`0xFFF2C94C`)
- 🔴 **Overdue / Error** — Error Accent (`0xFFEB5757`)

### CustomProgressBar (`lib/views/widgets/custom_progress_bar.dart`)
Progress bar tipis adaptif dengan perubahan warna otomatis:
- Normal → Primary Accent
- Mendekati deadline (>80%) → Warning Accent
- Overdue → Error Accent
- Selesai → Success Accent

## Adaptasi Kartu Dasbor ProjectKu
Alih-alih menggabungkan data keuangan, status, dan jumlah proyek dalam satu kartu besar, data dipecah menjadi kartu-kartu mandiri bertujuan tunggal:
1.  **Revenue Card:** Total Pendapatan Terbayar — layout teks bersih.
2.  **Summary Card:** Ringkasan proyek dengan circular progress indicator.
3.  **Project Card:** Satu kartu per proyek dengan Status Chip dan Progress Bar.

Setiap kartu hanya memiliki satu tujuan.

---

# 📱 6. Sistem Responsif

Layout menggunakan `card-first` dengan batasan lebar kontainer:
```dart
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: 480),
)
```
Berbeda dari dasbor pada umumnya, lebar dibatasi sempit untuk mempertahankan fokus ruang kerja *freelancer* dan kemudahan operasi satu tangan.

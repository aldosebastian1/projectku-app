# 📱 ProjectKu — Professional Freelancer Workspace Tracker

[![Flutter](https://img.shields.io/badge/Flutter-v3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.4+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-v3.3--State-38BDF8?logo=flutter)](https://riverpod.dev)
[![Firebase Cloud Firestore](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![GoRouter](https://img.shields.io/badge/GoRouter-v17--Declarative-0A0F1D)](https://pub.dev/packages/go_router)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

**ProjectKu** adalah aplikasi mobile manajemen proyek dan pelacak finansial *real-time* yang dirancang khusus untuk memenuhi kebutuhan administrasi pekerja lepas (*freelancer*). Dibangun menggunakan **Flutter (Material 3)**, dengan pengelolaan state reaktif **Riverpod**, navigasi deklaratif **GoRouter**, autentikasi **Firebase Authentication (Email & Password)**, serta sinkronisasi data instan berbasis **Firebase Cloud Firestore**.

Aplikasi ini berfokus pada penyelesaian masalah klasik *freelancer*, seperti pencatatan keuangan yang tercecer, manajemen klien yang tidak terpusat, serta kelalaian dalam memantau tenggat waktu proyek (*due date*).

---

## 📂 Peta Dokumentasi Proyek (Documentation Roadmap)

Untuk mempermudah peninjauan teknis, dokumentasi proyek ini telah dibagi menjadi beberapa panduan terstruktur di dalam folder [`documentation/`](documentation/):

1.  📱 **[USAGE.md](documentation/USAGE.md)**: Panduan penggunaan lengkap — alur navigasi, penjelasan tiap layar, semua field, dan sistem status proyek.
2.  💼 **[PORTFOLIO_CASE_STUDY.md](documentation/PORTFOLIO_CASE_STUDY.md)**: Analisis mendalam tentang keputusan rekayasa perangkat lunak, penyelesaian masalah, diagram arsitektur MVC-Riverpod, skema database, pengujian, dan otomatisasi alur.
3.  📂 **[PROJECT_DOCUMENTATION.md](documentation/PROJECT_DOCUMENTATION.md)**: Manual referensi komponen kode, penjelasan folder `lib`, dan cara kerja data flow.
4.  🎨 **[ui_documentation.md](documentation/ui_documentation.md)**: Panduan visual sistem desain UI/UX, token warna, tipografi Inter, komponen, dan responsivitas layout.
5.  ⚡ **[PANDUAN_SETUP_FIREBASE.md](documentation/PANDUAN_SETUP_FIREBASE.md)**: Panduan langkah demi langkah cara menghubungkan aplikasi ini ke konsol Firebase Anda sendiri menggunakan FlutterFire CLI.

---

## ✨ Fitur Utama (Core Features)

*   🔐 **Auth-Gated Workspace:** Login berbasis Email & Password dengan redirect otomatis ke `/login` sebelum pengguna masuk ke dashboard.
*   💳 **Dasbor Wallet-style Hero Card:** Visualisasi rekap keuangan real-time yang memisahkan Total Pendapatan Bersih (Terbayar), Total Tagihan Aktif (Belum Terbayar), serta jumlah proyek yang sedang berjalan.
*   🔄 **Real-time Firestore Integration:** Pembaruan data instan di seluruh perangkat pengguna tanpa perlu memuat ulang halaman (*pull-to-refresh*), dengan query Firestore yang dibatasi berdasarkan `userId` milik akun login.
*   🏷️ **Dynamic Progress Bar Timeline:** Bar kemajuan pengerjaan proyek yang beradaptasi secara otomatis (berwarna merah jika terlambat, kuning jika mendekati tenggat waktu, dan hijau jika selesai).
*   📱 **Responsive Layout (Adaptabilitas Layar):** Pembatasan lebar kontainer cerdas (maksimal 850px) memastikan kenyamanan visual yang prima pada perangkat mobile, tablet, hingga desktop web.
*   🇺🇸🇮🇩 **Lokalisasi Bahasa (Localization):** Mendukung Bahasa Indonesia (default) dan Bahasa Inggris untuk cakupan audiens profesional yang lebih luas.

---

## 🏗️ Struktur Proyek (MVC Architecture)

Basis kode ProjectKu menerapkan arsitektur **MVC (Model-View-Controller)** yang terpisah rapi guna menjaga prinsip *Separation of Concerns* (SoC):

```text
lib/
├── models/        # Entitas data bisnis murni (contoh: project_model.dart)
├── views/         # Representasi tampilan UI & Layout (contoh: project_list_view.dart)
├── controllers/   # Logika bisnis & manipulasi state Riverpod (auth, project_controller.dart)
├── services/      # Abstraksi koneksi luar, Firebase Auth, dan Database Firestore
├── utils/         # Konfigurasi router, format rupiah, dan tema global Material 3
└── views/         # UI screens termasuk login, dashboard, detail, dan form proyek
```

---

## ⚙️ Cara Memulai & Menjalankan Proyek (Getting Started)

### 📋 Prasyarat
*   Flutter SDK terinstal (versi `>= 3.22.x` direkomendasikan).
*   Dart SDK terinstal (versi `>= 3.4.x`).
*   Firebase CLI & Node.js terpasang pada komputer Anda.

### 🛠️ Langkah Instalasi
1.  Kloning repositori ini ke komputer lokal Anda.
2.  Masuk ke direktori proyek dan pasang dependensi Flutter:
    ```bash
    flutter pub get
    ```
3.  Hubungkan dengan Firebase Anda sendiri dengan mengikuti panduan terperinci di berkas **[PANDUAN_SETUP_FIREBASE.md](documentation/PANDUAN_SETUP_FIREBASE.md)**, lalu aktifkan **Authentication > Email/Password**.
4.  Jalankan static analysis untuk memastikan kode bersih dari kesalahan:
    ```bash
    flutter analyze
    ```
5.  Jalankan seluruh suite pengujian widget:
    ```bash
    flutter test
    ```
6.  Nyalakan emulator atau perangkat fisik Anda, kemudian jalankan aplikasi:
    ```bash
    flutter run
    ```

---

## 🧪 Kualitas Pengujian (Testing Quality)

ProjectKu dilengkapi dengan widget testing terotomatisasi di **[widget_test.dart](test/widget_test.dart)** yang memvalidasi integritas dasbor keuangan, pemrosesan filter tab, serta rendering komponen data tanpa perlu tersambung ke koneksi internet Firestore (menggunakan state overrides). Alur auth juga sudah dipisahkan sehingga dashboard hanya dapat diakses setelah login.

Untuk menjalankan pengujian:
```bash
flutter test
```

---

## 👤 Pembuat / Kontak (Author)

*   **Aldo Sebastian**
*   LinkedIn: [aldosebastian](https://id.linkedin.com/in/aldosebastian)
*   Portfolio Website: *(belum ada)*
*   Email: [emailaldosebastian@gmail.com](mailto:emailaldosebastian@gmail.com)

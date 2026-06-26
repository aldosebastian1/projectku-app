// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'ProjectKu';

  @override
  String get appSubtitle => 'Freelancer Workspace';

  @override
  String get syncStatus => 'Firebase Sync Aktif secara Real-Time';

  @override
  String get welcomeTitle => 'Halo, Freelancer!';

  @override
  String get welcomeSubtitle =>
      'Pantau status pengerjaan proyek dan kelola keuangan Anda.';

  @override
  String get searchHint => 'Cari proyek atau klien...';

  @override
  String get totalPaid => 'TOTAL PENDAPATAN LUNAS';

  @override
  String get verified => 'Verified';

  @override
  String get tagihanTertunda => 'Tagihan Tertunda';

  @override
  String get proyekAktif => 'Proyek Aktif';

  @override
  String activeProjectsCount(int count) {
    return '$count Proyek';
  }

  @override
  String get daftarProyek => 'Daftar Proyek';

  @override
  String get tabAll => 'Semua';

  @override
  String get tabInProgress => 'Dikerjakan';

  @override
  String get tabCompleted => 'Selesai';

  @override
  String get workspaceEmptyTitle => 'Workspace Masih Kosong';

  @override
  String get workspaceEmptySubtitle =>
      'Mulai kelola bisnis freelancer Anda dengan menambahkan proyek pertamamu.';

  @override
  String get filterEmptyCompletedTitle => 'Belum Ada Proyek Selesai';

  @override
  String get filterEmptyCompletedSubtitle =>
      'Selesaikan proyek Anda untuk melihat daftarnya di sini.';

  @override
  String get filterEmptyInProgressTitle => 'Tidak Ada Proyek Dikerjakan';

  @override
  String get filterEmptyInProgressSubtitle =>
      'Semua proyek Anda telah selesai atau belum dimulai.';

  @override
  String get filterEmptyGenericTitle => 'Proyek Tidak Ditemukan';

  @override
  String get filterEmptyGenericSubtitle =>
      'Tidak ada proyek yang sesuai dengan kriteria penyaringan atau pencarian Anda.';

  @override
  String get timeRemainingCompleted => 'Proyek telah selesai';

  @override
  String timeRemainingDays(int days) {
    return '$days hari tersisa';
  }

  @override
  String get timeRemainingToday => 'Hari ini batas waktu';

  @override
  String get timeProgressCompleted => '100% Selesai';

  @override
  String timeProgressPercent(int percentage) {
    return '$percentage% Waktu';
  }

  @override
  String get statusInProgress => 'Dikerjakan';

  @override
  String get statusCompleted => 'Selesai';

  @override
  String get statusOnHold => 'Tertunda';

  @override
  String get paymentPaid => 'Lunas';

  @override
  String get paymentInvoiceSent => 'Invoice';

  @override
  String get paymentUnpaid => 'Belum Bayar';

  @override
  String get overdueBadge => 'TELAT';

  @override
  String get deleteTitle => 'Hapus Proyek?';

  @override
  String deleteConfirm(String name) {
    return 'Apakah Anda yakin ingin menghapus proyek \"$name\" secara permanen?';
  }

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String deleteSuccess(String name) {
    return 'Proyek \"$name\" berhasil dihapus.';
  }

  @override
  String get sortTitle => 'Urutkan Proyek';

  @override
  String get sortSubtitle =>
      'Pilih kriteria untuk menyusun daftar proyek Anda.';

  @override
  String get sortDueDate => 'Tenggat Waktu Terdekat';

  @override
  String get sortBudget => 'Budget Tertinggi';

  @override
  String get sortCreatedAt => 'Terbaru Dibuat';

  @override
  String get addProject => 'Tambah Proyek Baru';

  @override
  String get informasiUtama => 'Informasi Utama';

  @override
  String get statusKeuangan => 'Status & Keuangan';

  @override
  String get informasiTambahan => 'Informasi Tambahan';

  @override
  String get projectNameLabel => 'Nama Proyek *';

  @override
  String get projectNameHint => 'Misal: Desain Landing Page Toko';

  @override
  String get clientNameLabel => 'Nama Klien *';

  @override
  String get clientNameHint => 'Misal: PT. Jaya Makmur';

  @override
  String get projectBudgetLabel => 'Budget Proyek (Rp) *';

  @override
  String get projectBudgetHint => 'Misal: 5000000';

  @override
  String get dueDateLabel => 'Tenggat Waktu (Due Date) *';

  @override
  String get validationNameRequired => 'Nama proyek wajib diisi';

  @override
  String get validationClientRequired => 'Nama klien wajib diisi';

  @override
  String get validationBudgetRequired => 'Budget wajib diisi';

  @override
  String get validationBudgetInvalid => 'Masukkan nominal budget valid';

  @override
  String get statusPengerjaan => 'Status Pengerjaan';

  @override
  String get statusPembayaran => 'Status Pembayaran';

  @override
  String get descriptionLabel => 'Catatan / Cakupan Kerja';

  @override
  String get descriptionHint =>
      'Tulis cakupan proyek, figma link, atau instruksi khusus dari klien...';

  @override
  String get saveToDatabase => 'Simpan ke Database';

  @override
  String get saveSuccess => 'Proyek sukses disimpan ke Cloud Firestore';

  @override
  String saveError(String error) {
    return 'Gagal menyimpan ke Firestore: $error';
  }

  @override
  String get projectDetail => 'Detail Proyek';

  @override
  String get projectBudgetHeader => 'BUDGET PROYEK';

  @override
  String get quickUpdateStatus => 'Ubah Status Cepat';

  @override
  String get deleteProjectBtn => 'Hapus Proyek';

  @override
  String get editProjectInfo => 'Edit Informasi Proyek';

  @override
  String get saveChanges => 'Simpan Perubahan';

  @override
  String get saveChangesSuccess => 'Perubahan proyek sukses disimpan';

  @override
  String get errorLoadDetail => 'Gagal memuat detail proyek';

  @override
  String get tenggatWaktu => 'Tenggat Waktu';

  @override
  String get sisaWaktu => 'Sisa Waktu';

  @override
  String get deskripsiProyek => 'Deskripsi / Catatan Proyek';

  @override
  String get noNotes => 'Tidak ada catatan tambahan.';

  @override
  String get quickUpdateSheetTitle => 'Ubah Status Proyek';

  @override
  String get quickUpdateSheetSubtitle =>
      'Ubah pengerjaan atau status pembayaran dengan cepat.';

  @override
  String get timeRemainingOverdue => 'Batas waktu berakhir';

  @override
  String get tugasChecklist => 'Daftar Tugas / Milestone';

  @override
  String get tambahTugas => 'Tambah Tugas';

  @override
  String get tugasHint => 'Tulis nama tugas...';

  @override
  String get tugasKosong =>
      'Belum ada tugas. Tambahkan tugas pertamamu di atas!';

  @override
  String get analitikKeuangan => 'Analitik Keuangan';

  @override
  String get perbandinganPendapatan => 'Status Pendapatan';

  @override
  String get pendapatan6Bulan => 'Pendapatan Lunas: 6 Bulan Terakhir';
}

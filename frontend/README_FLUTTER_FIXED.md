# Task Manager App - Flutter Fixed

Perbaikan yang sudah dilakukan:

- Menambahkan `AuthProvider` agar login, register, logout, dan cek token lebih rapi.
- Memperbaiki mapping enum `TaskStatus.inProgress` supaya dikirim ke backend sebagai `IN_PROGRESS`.
- Menambahkan CRUD task lengkap: tambah, edit, hapus, lihat daftar task, dan update status cepat.
- Menambahkan search task dan filter task berdasarkan status/kategori.
- Menambahkan `TaskFormScreen`, `TaskListScreen`, `TaskCard`, dan `LoadingOverlay`.
- Menambahkan error handling dan retry sederhana di `ApiService`.
- Menambahkan permission internet dan `usesCleartextTraffic=true` pada Android Manifest untuk akses backend HTTP lokal.

## Cara menjalankan

1. Jalankan backend Spring Boot dulu:

```powershell
cd C:\naila
.\mvnw.cmd spring-boot:run
```

Tunggu sampai muncul `Tomcat started on port 8080`.

2. Jalankan Flutter:

```powershell
cd path\ke\task_manager_app
flutter pub get
flutter run
```

## Catatan baseUrl

File yang mengatur alamat backend:

```dart
lib/services/api_service.dart
```

Default:

```dart
static const String baseUrl = 'http://10.0.2.2:8080/api';
```

Gunakan ini jika menjalankan Flutter di Android Emulator.

Jika menjalankan di Chrome/Desktop/iOS Simulator, ubah menjadi:

```dart
static const String baseUrl = 'http://localhost:8080/api';
```

Jika menjalankan di HP fisik, ubah `10.0.2.2` menjadi IP laptop pada WiFi yang sama, contoh:

```dart
static const String baseUrl = 'http://192.168.1.10:8080/api';
```

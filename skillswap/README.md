# SkillSwap - Flutter Learning Platform

SkillSwap adalah platform pembelajaran yang menghubungkan instructor dan student untuk sesi pembelajaran one-on-one. Aplikasi ini dibangun dengan Flutter dan menggunakan Firebase sebagai backend.

## 🚀 Fitur Utama

### 👨‍🏫 Instructor Features
- **Dashboard Modern**: Interface yang intuitif dengan statistik dan navigasi yang mudah
- **Create Session**: Membuat sesi pembelajaran dengan date picker dan time picker
- **Session Management**: Mengelola semua sesi yang telah dibuat
- **Booking Management**: Melihat dan mengelola booking dari student
- **Timetable View**: Kalender mingguan untuk melihat jadwal booking
- **Profile Management**: Mengelola profil instructor

### 👨‍🎓 Student Features
- **Modern Dashboard**: UI yang menarik dengan grid layout untuk course cards
- **Advanced Search**: Pencarian berdasarkan nama course dan tema pembelajaran
- **Category Filtering**: Filter berdasarkan kategori pembelajaran
- **Advanced Booking**: Sistem booking yang lengkap dengan payment simulation
- **Session Details**: Detail lengkap setiap sesi dengan modal bottom sheet
- **Profile Management**: Mengelola profil student

### 🔧 Technical Features
- **Provider State Management**: Menggunakan Provider untuk state management
- **Firebase Integration**: Firestore untuk database, Auth untuk authentication
- **Modern UI/UX**: Material 3 design dengan komponen reusable
- **Responsive Design**: Mendukung berbagai ukuran layar
- **Real-time Updates**: Data terupdate secara real-time

## 📁 Struktur Project

```
skillswap/
├── lib/
│   ├── main.dart                 # Entry point dengan Provider setup
│   ├── models/                   # Data models
│   │   ├── booking_model.dart
│   │   ├── instructor_model.dart
│   │   ├── session_model.dart
│   │   └── student_model.dart
│   ├── services/                 # Business logic & API calls
│   │   ├── auth_service.dart
│   │   ├── booking_service.dart
│   │   ├── session_service.dart
│   │   └── storage_service.dart
│   ├── viewmodels/              # State management
│   │   ├── auth_view_model.dart
│   │   ├── booking_view_model.dart
│   │   ├── session_view_model.dart
│   │   └── instructor_view_model.dart
│   ├── views/                   # UI Screens
│   │   ├── auth/               # Authentication screens
│   │   ├── dashboard/          # Dashboard screens
│   │   ├── sessions/           # Session management
│   │   ├── bookings/           # Booking management
│   │   ├── profile/            # Profile screens
│   │   └── timetable/          # Timetable screens
│   └── widgets/                # Reusable components
│       ├── course_card.dart
│       ├── search_bar.dart
│       └── empty_state.dart
```

## 🛠 Setup & Installation

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Firebase project setup
- Android Studio / VS Code

### Installation Steps

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd skillswap
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Buat project Firebase baru
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Download `google-services.json` untuk Android
   - Download `GoogleService-Info.plist` untuk iOS
   - Place files di folder yang sesuai

4. **Run Application**
   ```bash
   flutter run
   ```

## 📱 Screenshots & Features

### Student Dashboard
- Modern grid layout dengan course cards
- Search dan filter functionality
- Tab untuk available courses dan enrolled courses
- Bottom navigation dengan 4 tabs utama

### Instructor Dashboard
- Feature cards untuk berbagai fungsi
- Quick access ke create session, bookings, timetable
- Modern gradient design
- Profile management

### Create Session Screen
- Form yang lengkap dengan validasi
- Date picker dan time picker
- Category selection
- Online/Offline session toggle
- Price dan duration input

### Timetable Screen
- Weekly dan daily view
- Booking cards dengan status indicators
- Action buttons untuk approve/reject
- Filter expired bookings

## 🔄 State Management

Project menggunakan **Provider** pattern untuk state management:

```dart
// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthViewModel(AuthService())),
    ChangeNotifierProvider(create: (_) => SessionViewModel()),
    ChangeNotifierProvider(create: (_) => BookingViewModel()),
    ChangeNotifierProvider(create: (_) => InstructorViewModel()),
  ],
  child: MaterialApp(...),
)
```

## 🗄 Database Schema

### Firestore Collections

#### `sessions`
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "category": "string",
  "instructorId": "string",
  "instructor": "string",
  "price": "number",
  "startDate": "timestamp",
  "durationHours": "number",
  "isOnline": "boolean",
  "location": "string?",
  "meetingUrl": "string?",
  "image": "string?",
  "isAvailable": "boolean"
}
```

#### `bookings`
```json
{
  "id": "string",
  "userId": "string",
  "sessionId": "string",
  "instructorId": "string",
  "bookingDate": "timestamp",
  "status": "string",
  "paymentStatus": "boolean",
  "additionalNotes": "string?"
}
```

## 🎨 UI Components

### Reusable Widgets
- **CourseCard**: Modern card design untuk menampilkan session
- **SearchWithFilters**: Search bar dengan category filters
- **EmptyState**: Komponen untuk state kosong dengan animasi
- **ModernSearchBar**: Search bar dengan clear functionality

### Design System
- **Colors**: Consistent color palette dengan primary blue (#667eea)
- **Typography**: Material 3 typography scale
- **Spacing**: Consistent 8px grid system
- **Shadows**: Subtle shadows untuk depth

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🔧 Configuration

### Environment Variables
- Firebase configuration di `firebase_options.dart`
- API keys dan secrets di environment variables

### Build Configuration
- Android: `android/app/build.gradle.kts`
- iOS: `ios/Runner.xcodeproj`

## 📝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

Untuk support dan pertanyaan:
- Email: support@skillswap.com
- Documentation: [docs.skillswap.com](https://docs.skillswap.com)
- Issues: [GitHub Issues](https://github.com/skillswap/issues)

---

**SkillSwap** - Connecting knowledge seekers with expert instructors 🎓

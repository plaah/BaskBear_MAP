# BaskBear Group
# SkillSwap - Flutter Learning Platform

SkillSwap is a learning platform that connects instructors and students for one-on-one learning sessions. This application is built with Flutter and uses Firebase as the backend.

## 🚀 Key Features

### 👨‍🏫 Instructor Features
- **Modern Dashboard**: Intuitive interface with statistics and easy navigation
- **Create Session**: Create learning sessions with date picker and time picker
- **Session Management**: Manage all created sessions
- **Booking Management**: View and manage student bookings
- **Timetable View**: Weekly calendar to view booking schedules
- **Profile Management**: Manage instructor profile

### 👨‍🎓 Student Features
- **Modern Dashboard**: Attractive UI with grid layout for course cards
- **Advanced Search**: Search by course name and learning topics
- **Category Filtering**: Filter by learning categories
- **Advanced Booking**: Complete booking system with payment simulation
- **Session Details**: Complete details of each session with bottom sheet modal
- **Profile Management**: Manage student profile

### 🔧 Technical Features
- **Provider State Management**: Using Provider for state management
- **Firebase Integration**: Firestore for database, Auth for authentication
- **Modern UI/UX**: Material 3 design with reusable components
- **Responsive Design**: Supports various screen sizes
- **Real-time Updates**: Real-time data updates

## 📁 Project Structure

```
skillswap/
├── lib/
│   ├── main.dart                 # Entry point with Provider setup
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
   - Create new Firebase project
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS
   - Place files in appropriate folders

4. **Run Application**
   ```bash
   flutter run
   ```

## 📱 Screenshots & Features

### Student Dashboard
- Modern grid layout with course cards
- Search and filter functionality
- Tabs for available courses and enrolled courses
- Bottom navigation with 4 main tabs

### Instructor Dashboard
- Feature cards for various functions
- Quick access to create session, bookings, timetable
- Modern gradient design
- Profile management

### Create Session Screen
- Complete form with validation
- Date picker and time picker
- Category selection
- Online/Offline session toggle
- Price and duration input

### Timetable Screen
- Weekly and daily view
- Booking cards with status indicators
- Action buttons for approve/reject
- Filter expired bookings

## 🔄 State Management

Project uses **Provider** pattern for state management:

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
- **CourseCard**: Modern card design to display sessions
- **SearchWithFilters**: Search bar with category filters
- **EmptyState**: Component for empty state with animation
- **ModernSearchBar**: Search bar with clear functionality

### Design System
- **Colors**: Consistent color palette with primary blue (#667eea)
- **Typography**: Material 3 typography scale
- **Spacing**: Consistent 8px grid system
- **Shadows**: Subtle shadows for depth

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
- Firebase configuration in `firebase_options.dart`
- API keys and secrets in environment variables

### Build Configuration
- Android: `android/app/build.gradle.kts`
- iOS: `ios/Runner.xcodeproj`

## 📝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

**SkillSwap** - Connecting knowledge seekers with expert instructors 🎓

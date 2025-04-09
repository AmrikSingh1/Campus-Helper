# Campus Helper

A futuristic, student-friendly Flutter application designed to help students manage their academic journey effectively.

## Models

This app includes the following data models:

### Calendar Event Model
- Represents academic calendar events such as lectures, exams, assignments, holidays, etc.
- Properties include:
  - Title, description
  - Start and end dates/times
  - Location
  - Event type (lecture, exam, assignment, holiday, etc.)
  - Color
  - Department and semester
  - All-day flag

### Assignment Model
- Represents homework, projects, and other assignments
- Properties include:
  - Title, description
  - Due date
  - Total marks
  - Subject ID
  - Status (active/expired)
  - File URL (for attachments)

### Submission Model
- Represents student submissions for assignments
- Properties include:
  - Assignment ID
  - Student ID
  - Submission date
  - File URL
  - Marks and feedback
  - Status (submitted, graded, late)

### Notification Model
- Represents system notifications and reminders
- Types include:
  - Event notifications
  - Assignment notifications
  - Announcements
  - Grade notifications
  - Reminders
  - System notifications
- Properties include:
  - Title, content
  - Timestamp
  - User ID
  - Related item ID
  - Read status

### Subject Model
- Represents academic subjects or courses
- Properties include:
  - Name, code
  - Department and semester
  - Credits
  - Description
  - Faculty ID

### Resource Model
- Represents study materials and resources for subjects
- Properties include:
  - Title, description
  - Type (notes, paper, book, etc.)
  - Subject ID
  - File URL
  - Tags

### Grade Model
- Represents student grades for subjects
- Properties include:
  - Student ID and Subject ID
  - Internal and external marks
  - Total marks and grade
  - Grade points
  - Academic year

### Faculty Model
- Represents teaching staff and professors
- Properties include:
  - Name, email
  - Department
  - Position (Professor, Assistant Professor, etc.)
  - Office location and hours
  - Phone number
  - List of subjects taught

### Student Model
- Represents student information
- Properties include:
  - User ID (for authentication)
  - Name, email
  - Roll number
  - Department and semester
  - Contact information
  - Academic information (CGPA, attendance, etc.)

## Features

- **Splash Screen**: Engaging splash screen with Lottie animations.
- **Onboarding Experience**: Smooth onboarding flow explaining app features.
- **Authentication**: Firebase-based authentication system with email and Google sign-in.
- **Dashboard**: Overview of academic progress, upcoming events, and recent activities.
- **Learning Resources**: Subject-wise resources including notes, e-books, past papers, and videos.
- **Assignment Tracker**: Track assignments with due dates, status updates, and submission features.
- **Profile Management**: Comprehensive profile with academic stats and personalization options.

## UI/UX Design

The app follows a modern, neumorphic design approach with:
- **Color Palette**:
  - Primary: #6946b2
  - Secondary: #aa96d9
  - Accent: #ff8e3b
  - Background: Light gradient between primary and secondary
  - Text: White (#ffffff) and dark purple (#2b234f)

- **UI Elements**:
  - Soft shadows
  - Rounded corners
  - Smooth animations
  - High contrast CTAs
  - Modern tab layouts

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/campus-helper.git
```

2. Navigate to the project directory:
```bash
cd campus-helper
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Firebase Setup

To enable authentication and database features:

1. Create a Firebase project on the [Firebase Console](https://console.firebase.google.com/)
2. Register your app with Firebase
3. Download the configuration files:
   - For Android: `google-services.json` to `android/app`
   - For iOS: `GoogleService-Info.plist` to `ios/Runner`
4. Enable Authentication services (Email and Google) in Firebase Console
5. Set up Firestore Database with appropriate security rules

## Dependencies

- **UI**: `lottie`, `google_fonts`, `flutter_svg`, `smooth_page_indicator`
- **State Management**: `provider`
- **Firebase**: `firebase_core`, `firebase_auth`, `cloud_firestore`
- **Utilities**: `shared_preferences`, `url_launcher`, `intl`
- **Charts**: `fl_chart`
- **Communication**: `socket_io_client`

## Project Structure

```
lib/
├── constants/         # App constants (colors, themes, etc.)
├── models/            # Data models
├── screens/           # App screens
│   ├── auth/          # Authentication screens
│   ├── tabs/          # Main tab screens
│   └── ...
├── services/          # Services (Firebase, API, etc.)
├── utils/             # Utility functions and helpers
├── widgets/           # Reusable widgets
└── main.dart          # App entry point
```

## Contributors

- Your Name (@yourusername)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

# 🚨 Dispatcher - Safety & Emergency Companion App

**Dispatcher** is a Flutter-based safety and security mobile application developed as our graduation project during the journey at **ITI - ICC Frontend & Cross-Platform Mobile Development Track**.

---

## 📱 App Overview

Dispatcher empowers users to report emergencies effectively using their smartphones. It provides **two main safety features**:

- **🔘 Alert Button** – For generic or non-extreme emergencies.
- **🆘 SOS Button** – For urgent, life-threatening situations requiring immediate autonomous response.

---

## 👥 Team

This app was developed by a team of four:

- **Yousef Khalaf**
- **Malak Haitham**
- **Alaa Ahmed**
- **Aya Essam**

---

## 🚀 Key Features

### 🔘 Alert Button

- Used for **less urgent emergencies** (e.g., fire, harassment, theft, missing pet).
- Users can:
  - Choose from **predefined tags** (or skip).
  - Proceed to a form for optional attachments:
    - Images
    - Description
    - GPS Location
    - Time of alert
    - User profile data
- Requires user to **assign guardians** before activation.
- Sends notifications and all attached data to selected **guardians** (who must be Dispatcher users).

---

### 🆘 SOS Button

- Designed for **extreme emergencies** (e.g., accidents, violence, serious injuries).
- Triggered by **triple-press gesture** for quick action.
- Autonomous data capture includes:
  - Front camera snapshot
  - Rear camera snapshot
  - 1-minute voice recording
  - GPS location, time, and optional tag
- Sends request to both:
  - **Guardians**
  - **Nearest authorities** (e.g., police, hospital, fire station)
- **Strong notification behavior** for recipients (e.g., vibration until response).
- Guardians can **Accept** or **Decline** the SOS request via the app.

---

## 🔐 Authentication

- **Phone number sign-in and sign-up** via **Firebase Authentication**.
- No passwords or usernames required.
- Onboarding and splash screen experience included.

---

## 📂 Technologies Used

- **Flutter** with **FVM** for version management
- **Firebase** (Authentication & Firestore)
- **Cloudinary** for media storage
- **goRouter** for navigation
- **Cubit** for state management
- **Shared Preferences** for local data
- **VS Code** for development
- **Trello** for task management and planning

---

## 🧍 Victim Profile Data

Users can pre-fill critical personal information such as:

```dart
String nid = '';
String passport = '';
String driverLicense = '';
String firstName = '';
String lastName = '';
String birthDate = '';
String bloodType = '';
bool wheelchair = false;
bool diabetes = false;
bool heartDisease = false;
String profileImage = '';
String height = '';
String weight = '';
String gender = '';
String tattoo = '';
String scar = '';
String nationality = '';
GeoPoint? homeLocation;
GeoPoint? workLocation;
String nativeLanguage = '';
String email = '';
List<String>? guardians;
````

This data is automatically attached to every emergency request for quick assistance.

---

## 🧭 App Flow

1. User signs in with phone number
2. Sets up profile & adds guardians
3. Uses:

   * Alert Button for minor emergencies
   * SOS Button for extreme cases
4. Guardian (also Dispatcher user) receives:

   * Normal notification for Alert
   * Strong, unmissable notification for SOS
5. Guardian can **Accept** or **Decline** request

---

## 📸 Screenshots

| Splash & Onboarding                         | Alert Flow                                  | SOS Flow                                |
| ------------------------------------------- | ------------------------------------------- | --------------------------------------- |
| ![Splash](https://github.com/user-attachments/assets/949de3ae-e5ea-4636-aff5-2c995330c548) | ![Alert](./screenshots/alert.png)           | ![SOS](./screenshots/sos.png)           |
| ![Onboarding](./screenshots/onboarding.png) | ![Alert Tags](./screenshots/alert-tags.png) | ![SOS Tags](./screenshots/sos-tags.png) |

---

## 🛠 Installation

```bash
flutter pub get
fvm use
flutter run
```

Make sure to configure your own Firebase project and Cloudinary keys before running.

---

## ✅ Future Improvements

* Real-time location tracking for guardians
* Panic shortcut via volume keys
* Multilingual support
* Accessibility options

---

## 📬 Contact

For any inquiries, suggestions, or bug reports, please contact \[your email or GitHub profile].

---

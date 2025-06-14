# 🚨 Mr. Defence - Safety & Emergency Companion App

**Mr. Defence** is a Flutter-based safety and security mobile application developed as our graduation project during the journey at **ITI - ICC Frontend & Cross-Platform Mobile Development Track**.

---

## 📱 App Overview

Mr. Defence empowers users to report emergencies effectively using their smartphones. It provides **two main safety features**:

- **🔘 Alert Button** – For generic or non-extreme emergencies.
- **🆘 SOS Button** – For urgent, life-threatening situations requiring immediate autonomous response.

---

## 👥 Team

This app was developed by a team of four:

- **Yousef Khalaf**
- **Malak Haitham**
- **Alaa Ahmed**

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
| ![Splash](https://github.com/user-attachments/assets/949de3ae-e5ea-4636-aff5-2c995330c548) | ![Alert](https://github.com/user-attachments/assets/eb39eace-58d6-4179-a3c3-dc7d2bd97d75) | ![SOS](https://github.com/user-attachments/assets/acf00117-5d2e-4f59-abb9-85161577d622) |
| ![Onboarding](https://github.com/user-attachments/assets/e8f25aae-9a4f-46d2-83db-6abf0677baa1) | ![Alert Tags](https://github.com/user-attachments/assets/98dbd1cf-921d-4346-8105-8fc447032c76) | ![SOS](https://github.com/user-attachments/assets/f66c2725-34a0-4fe7-9749-bdf119ce4d13) |
| ![Onboarding](https://github.com/user-attachments/assets/a0f1ae93-c32d-4fc6-be27-a98e9a6e0b7c) | ![Alert](https://github.com/user-attachments/assets/3bdde483-87f2-4c64-bf4b-79691b209909) | ![SOS](https://github.com/user-attachments/assets/e64e1fdf-89d9-4f1e-b909-29e0edc2c268) |
| ![Onboarding](https://github.com/user-attachments/assets/6f519990-0721-465b-80f8-b52680e3b75d) | ![Received Alert](https://github.com/user-attachments/assets/b5719765-7586-4c16-8425-6360d43a881a) | ![SOS](https://github.com/user-attachments/assets/2fb493ff-7ba2-4d41-a330-45d8b7867cf3) |
| ![Onboarding](https://github.com/user-attachments/assets/bb8a64fc-bb8c-44d7-afb2-9e0623608f69) | ![image](https://github.com/user-attachments/assets/1d38dd1d-ac98-4d09-a802-dc0c5ed7b38c) | ![Notifications](https://github.com/user-attachments/assets/ec04f778-81ad-4706-9585-5318ea4ffacd) |

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

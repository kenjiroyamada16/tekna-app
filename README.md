# Tekna Tasks

A **mobile task manager** built with **Flutter (3.29)** and **Supabase** (Auth, Postgres, Storage), using **BLoC** for state management and **Dart 3.7**.

Target platform: **Android** (iOS not required, only Android tested).

## 🚀 Features

- **User authentication** with Supabase Auth (email/password)
- **Persistent login**: user stays signed in across app restarts
- **CRUD tasks**: title, description, expiry date, category, status
- **Dynamic categories**: create, edit, delete
- **Media support**: user can attach a photo from the camera or gallery
- **Edit task**: replace or delete existing media
- **Search/filter tasks** by title, description, category, or status
- **Logout**

## 🧱 Stack

| Layer          | Technology            |
|----------------|------------------------|
| UI             | Flutter 3.29 |
| State          | BLoC        |
| Backend        | Supabase (Auth, Postgres, Storage) |
| Language       | Dart 3.7              |

## 🔧 Getting started

### 1. Clone the repo

```bash
- git clone git@github.com:kenjiroyamada16/tekna-app.git
or
- git clone https://github.com/kenjiroyamada16/tekna-app.git
- cd flutter_supabase_task_manager
```

### 2. Get the app dependencies

```bash
flutter clean
flutter pub get
```

### 3. Run the application

```bash
flutter run
```

- Alternatively, you can build an apk and run it on your physical device:

```bash
flutter build apk
```

## Be aware that this application needs all of its functionalities to be authenticated, so it is recommended to create an account so you can proceed.

### Alternativey, you can use this test account:
- Email: teste@email.com
- Password: secret123

---

## Thank you for reading and being part of this project!
- Check on my stuff: [LinkedIn](https://www.linkedin.com/in/nicolas-yamada/) | [Portfolio](https://nicyamada.com)
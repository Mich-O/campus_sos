# Campus SOS

Campus SOS is a Flutter app for reporting campus issues at ALU Kigali and following them through to resolution. Students can describe a problem, identify where it occurred, and attach a photo. Campus staff can review reports, record progress, and leave updates for students.

## Using the app

After creating an account and verifying an ALU email address, a student can submit a report under categories such as facilities, water, electricity, sanitation, furniture, or safety. Reports can be searched and filtered, and each report has a detail view with its current status, history, and staff updates. Students can also manage their profile and receive notifications when a report changes.

Staff accounts have access to report review tools. Staff can acknowledge a report, mark work as in progress, resolve it, and add a note for the student. The app checks the signed-in user's role before showing staff actions, while Firestore Security Rules enforce who may change report status.

## Project structure

Campus SOS uses Riverpod to connect the interface to application state and data services. Screens are in `lib/screens/`, shared interface components are in `lib/widgets/`, data models are in `lib/models/`, and authentication, Firestore, and media services are in `lib/data/`. Providers in `lib/state/providers.dart` make those services available to the screens.

Firebase Authentication manages accounts and sessions. Cloud Firestore stores user profiles, reports, report updates, and notifications. The main document layout is:

```text
users/{uid}
  notifications/{notificationId}
reports/{reportId}
  updates/{updateId}
```

Each report records its category, description, location, author, status, timestamps, and optional photo URL. Status changes are recorded as report updates so the progression remains visible over time.

## Accounts and permissions

New accounts must verify their email address. Student accounts use the `@alustudent.com` domain. Staff accounts use `@alueducation.com` and must have the staff role in their user profile. A designated test account is configured for staff workflow testing.

The rules in `firestore.rules` are the access-control boundary for Firestore data. They restrict status changes and staff update creation to authorized staff, including when a request is made outside the app interface. Deploy the rules from the project directory with:

```powershell
firebase deploy --only firestore:rules --project campus-sos-68cf5
```

## Photos

Profile and report photos are uploaded to Cloudinary. The app stores the resulting delivery URL in the corresponding Firestore document. The Cloudinary cloud name and unsigned upload preset are configured in `lib/data/cloudinary_config.dart`; these are public identifiers. An API secret must not be placed in the Flutter app.

The app accepts JPG, JPEG, PNG, and WebP images up to 5 MB. Cloudinary delivery URLs are public, so photos should not contain private or sensitive information.

## Run on Android

Install Flutter and Android Studio, connect an Android device with USB debugging enabled, then run these commands from the project directory:

```powershell
flutter pub get
.\run_on_device.ps1
```

The PowerShell helper uses the configured Android device ID `CPH2471` by default. To select another connected device, pass its ID:

```powershell
.\run_on_device.ps1 -DeviceId YOUR_DEVICE_ID
```

Firebase platform configuration is in `lib/firebase_options.dart`. The app also requires the Firebase Authentication email/password provider and deployed Firestore rules. Photo uploads require the cloud name and preset in `lib/data/cloudinary_config.dart` to match the Cloudinary account configuration.

## Verification

Run the automated checks from the project directory with:

```powershell
flutter test
```

The current tests cover password-policy validation, report category and status mappings, and status labels. On a device, the main flows to check are account verification and sign-in, report submission with and without a photo, search and filtering, report details, profile changes, staff updates, and the resulting student notifications.

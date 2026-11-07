# Campus SOS

Campus SOS is a Flutter mobile app for reporting and tracking campus incidents at ALU Kigali. Students can report issues such as damaged facilities, water or electricity outages, sanitation problems, and safety concerns. Authorized staff can review reports and post status updates for students.

## Main workflows

- Create an account or sign in with an ALU email; new accounts must verify their email.
- Submit a report with a category, description, campus location, and optional photo.
- Browse reports, search by text, and filter by owner, status, or category.
- Open a report to view its status history, staff notes, and attached photo.
- Receive notifications when staff update a report.
- Edit profile details or change the profile photo.
- Use the staff console to acknowledge, progress, or resolve reports.

## Architecture

The app uses Riverpod for application state. The screen layer is in `lib/screens/`, reusable UI in `lib/widgets/`, domain models in `lib/models/`, and Firebase/media access in `lib/data/`. `lib/state/providers.dart` wires the repositories and streams to the screens. Firebase Authentication handles accounts and sessions; Cloud Firestore stores profiles, reports, status history, and notifications.

### Firestore structure

```text
users/{uid}
  notifications/{notificationId}
reports/{reportId}
  updates/{updateId}
```

Reports store their author UID, category, description, location, status, timestamps, and optional Cloudinary photo URL. Status changes create an immutable update-history record and a notification for the reporting student.

## Roles and access control

- Verified `@alustudent.com` accounts can submit reports and read campus reports.
- Authorized staff use verified `@alueducation.com` accounts provisioned with the staff role. The explicitly configured test staff account is also supported.
- Firestore Security Rules enforce role and email checks. Students cannot change a report's status by calling Firestore directly; staff status updates and update-history writes are checked by the rules.

The Firebase rules are in `firestore.rules`. Deploy them with:

```powershell
firebase deploy --only firestore:rules --project campus-sos-68cf5
```

## Photo uploads

The instructor approved Cloudinary as the image service for this assignment. Firebase Authentication and Firestore remain in use; report and profile photos upload to Cloudinary, and their URLs are stored in Firestore. The app uses an unsigned image preset configured in `lib/data/cloudinary_config.dart`. Cloud name and preset name are public identifiers; never add a Cloudinary API secret to the Flutter app or repository.

The preset should restrict allowed formats to JPG, JPEG, PNG, and WebP. The app also checks for a maximum 5 MB file, although unsigned presets do not enforce that size limit on their own. Uploaded photos have public delivery URLs, so users should avoid attaching sensitive images.

## Run on an Android device

1. Install Flutter and Android Studio, and connect an Android device with USB debugging enabled.
2. From the project folder, run `flutter pub get`.
3. Deploy Firestore rules if they have changed using the command above.
4. Run the app with the provided PowerShell helper:

```powershell
.\run_on_device.ps1
```

The helper defaults to device `CPH2471`. To use another device ID, run `.\run_on_device.ps1 -DeviceId YOUR_DEVICE_ID` from PowerShell.

## Testing strategy

The test file covers the password policy, Firestore status/category value mapping, and the labels shown for report statuses. Run the automated checks with:

```powershell
flutter test
```

Manual end-to-end checks should cover registration and email verification, sign-in/out, report submission with and without a photo, search and filters, report details, staff status changes and notes, student notifications, profile save/cancel/photo changes, and rules rejecting a student's direct attempt to change report status. The app should be exercised on an Android device because browser-only execution does not meet the assignment requirement.

## Assignment deliverables

The final submission also requires a technical report in PDF format using APA or IEEE citations, a 7–10 minute demonstration video, and the GitHub repository link. The report should explain the architecture, Firestore model, role/security design, state management, UI decisions, tests, challenges, and lessons learned, with diagrams and workflow screenshots.

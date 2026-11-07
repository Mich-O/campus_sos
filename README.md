# Campus SOS — local preview

Campus SOS is a Flutter mobile app for reporting campus issues and following their progress. Reports and selected photos are saved in the app's private storage on this phone; they are not yet synced online.

## Current app structure

- `lib/screens/`: home, profile preview, new report, and report details.
- `lib/state/app_state.dart`: Provider state shared across screens.
- `lib/data/report_repository.dart`: local JSON persistence and photo-file storage.
- `lib/models/incident_report.dart`: report fields, categories, statuses, and JSON conversion.

## Current workflows

- Browse sample incidents, search by title/category/location, and filter by status.
- Submit a report with category, title, description, location, and an optional photo.
- Open a report and follow its submitted, in-progress, or resolved status.
- Reports and chosen photos persist after closing and reopening the app, but remain on this phone.

Authentication, online sync, staff roles, and cloud photo storage come later.

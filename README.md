# Campus SOS — local preview

Campus SOS is a Flutter mobile app for reporting campus issues and following their progress. This first runnable stage keeps reports in memory on the device; reports reset when the app restarts. It has no online accounts or backend yet.

## Current app structure

- `lib/screens/`: home, profile preview, new report, and report details.
- `lib/state/app_state.dart`: Provider state shared across screens.
- `lib/data/report_repository.dart`: local sample reports and in-memory changes.
- `lib/models/incident_report.dart`: report fields, categories, and status values.

## Current workflows

- Browse sample incidents, search by title/category/location, and filter by status.
- Submit a report with category, title, description, location, and an optional photo.
- Open a report and follow its submitted, in-progress, or resolved status.

Authentication, online persistence, staff roles, and online photo storage come later. The profile screen labels this as a local preview so demo data is not mistaken for saved or shared reports.

import 'package:flutter_test/flutter_test.dart';
import 'package:campus_sos/data/auth_service.dart';
import 'package:campus_sos/models/incident_report.dart';

void main() {
  group('PasswordPolicy', () {
    test('accepts a password that meets the full policy', () {
      expect(PasswordPolicy.validate('CampusSOS2026!'), isNull);
    });

    test('requires at least twelve characters', () {
      expect(PasswordPolicy.validate('Campus1!'), 'Use at least 12 characters.');
    });

    test('requires lowercase, uppercase, a number, and a symbol', () {
      expect(PasswordPolicy.validate('CAMPUSSOS2026!'), 'Add a lowercase letter.');
      expect(PasswordPolicy.validate('campussos2026!'), 'Add an uppercase letter.');
      expect(PasswordPolicy.validate('CampusSosStrong!'), 'Add a number.');
      expect(PasswordPolicy.validate('CampusSos2026A'), 'Add a symbol such as !, @, #, or _.');
    });
  });

  group('incident values', () {
    test('maps Firestore status values to the matching status', () {
      expect(IncidentStatusView.fromValue('acknowledged'), IncidentStatus.acknowledged);
      expect(IncidentStatusView.fromValue('inProgress'), IncidentStatus.inProgress);
      expect(IncidentStatusView.fromValue('resolved'), IncidentStatus.resolved);
    });

    test('falls back safely for an unknown category', () {
      expect(ReportCategory.fromValue('unknown'), ReportCategory.other);
    });
  });

  test('status exposes the student-facing label', () {
    expect(IncidentStatus.submitted.label, 'Submitted');
    expect(IncidentStatus.inProgress.label, 'In progress');
  });
}

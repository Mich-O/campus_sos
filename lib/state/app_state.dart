import 'package:flutter/foundation.dart';

import '../data/report_repository.dart';
import '../models/incident_report.dart';

class AppState extends ChangeNotifier {
  AppState({ReportRepository? repository})
    : _repository = repository ?? ReportRepository();

  final ReportRepository _repository;
  List<IncidentReport> get reports => _repository.reports;

  void createReport({
    required String title,
    required String description,
    required String category,
    required String location,
    String? photoPath,
  }) {
    _repository.add(
      IncidentReport(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title.trim(),
        description: description.trim(),
        category: category,
        location: location.trim(),
        status: IncidentStatus.submitted,
        reporterName: 'You',
        createdAt: DateTime.now(),
        photoPath: photoPath,
      ),
    );
    notifyListeners();
  }

  void updateStatus(String reportId, IncidentStatus status) {
    _repository.updateStatus(reportId, status);
    notifyListeners();
  }
}


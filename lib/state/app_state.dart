import 'package:flutter/foundation.dart';

import '../data/report_repository.dart';
import '../models/incident_report.dart';

class AppState extends ChangeNotifier {
  AppState({ReportRepository? repository})
    : _repository = repository ?? ReportRepository() {
    _reports = _repository.reports;
    _ready = _restoreReports();
  }

  final ReportRepository _repository;
  late List<IncidentReport> _reports;
  late final Future<void> _ready;
  String? _storageError;

  List<IncidentReport> get reports => List.unmodifiable(_reports);
  String? get storageError => _storageError;

  Future<void> _restoreReports() async {
    try {
      _reports = await _repository.load();
    } catch (error) {
      _storageError = error.toString();
    }
    notifyListeners();
  }

  Future<void> createReport({
    required String title,
    required String description,
    required String category,
    required String location,
    String? photoPath,
  }) async {
    await _ready;
    final report = IncidentReport(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      category: category,
      location: location.trim(),
      status: IncidentStatus.submitted,
      reporterName: 'You',
      createdAt: DateTime.now(),
      photoPath: photoPath,
    );
    await _repository.add(report);
    _reports = _repository.reports;
    notifyListeners();
  }

  Future<void> updateStatus(String reportId, IncidentStatus status) async {
    await _ready;
    await _repository.updateStatus(reportId, status);
    _reports = _repository.reports;
    notifyListeners();
  }
}

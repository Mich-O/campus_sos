import '../models/incident_report.dart';

class ReportRepository {
  final List<IncidentReport> _reports = [
    IncidentReport(
      id: 'sample-1',
      title: 'Water supply interruption',
      description: 'The taps on the second floor have had no running water since this morning.',
      category: 'Water',
      location: 'Student Residence · Block B',
      status: IncidentStatus.inProgress,
      reporterName: 'A. Student',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    IncidentReport(
      id: 'sample-2',
      title: 'Projector not working',
      description: 'The classroom projector does not turn on.',
      category: 'Facilities',
      location: 'Learning Centre · Room 204',
      status: IncidentStatus.submitted,
      reporterName: 'M. Student',
      createdAt: DateTime.now().subtract(const Duration(hours: 7)),
    ),
    IncidentReport(
      id: 'sample-3',
      title: 'Overflowing recycling bin',
      description: 'Please arrange a collection near the cafeteria entrance.',
      category: 'Sanitation',
      location: 'Main Cafeteria',
      status: IncidentStatus.resolved,
      reporterName: 'N. Student',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<IncidentReport> get reports => List.unmodifiable(_reports);

  void add(IncidentReport report) => _reports.insert(0, report);

  void updateStatus(String id, IncidentStatus status) {
    final index = _reports.indexWhere((report) => report.id == id);
    if (index < 0) return;
    final old = _reports[index];
    _reports[index] = IncidentReport(
      id: old.id,
      title: old.title,
      description: old.description,
      category: old.category,
      location: old.location,
      status: status,
      reporterName: old.reporterName,
      createdAt: old.createdAt,
    );
  }
}

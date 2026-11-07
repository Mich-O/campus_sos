import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

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

  Directory? _appDirectory;
  List<IncidentReport> get reports => List.unmodifiable(_reports);

  Future<List<IncidentReport>> load() async {
    final file = await _reportsFile();
    if (!await file.exists()) {
      await _save();
      return reports;
    }
    final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
    _reports
      ..clear()
      ..addAll(
        decoded.map(
          (entry) =>
              IncidentReport.fromJson(Map<String, dynamic>.from(entry as Map)),
        ),
      );
    return reports;
  }

  Future<void> add(IncidentReport report) async {
    var savedReport = report;
    final sourcePath = report.photoPath;
    if (sourcePath != null) {
      final source = File(sourcePath);
      if (!await source.exists()) {
        throw FileSystemException(
          'The selected photo could not be found.',
          sourcePath,
        );
      }
      final appDirectory = await _directory();
      final photosDirectory = Directory('${appDirectory.path}/report_photos');
      await photosDirectory.create(recursive: true);
      final extension = sourcePath.contains('.')
          ? '.${sourcePath.split('.').last}'
          : '.jpg';
      final destination = '${photosDirectory.path}/${report.id}$extension';
      final copiedPhoto = await source.copy(destination);
      savedReport = IncidentReport(
        id: report.id,
        title: report.title,
        description: report.description,
        category: report.category,
        location: report.location,
        status: report.status,
        reporterName: report.reporterName,
        createdAt: report.createdAt,
        photoPath: copiedPhoto.path,
      );
    }
    _reports.insert(0, savedReport);
    await _save();
  }

  Future<void> updateStatus(String id, IncidentStatus status) async {
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
      photoPath: old.photoPath,
    );
    await _save();
  }

  Future<Directory> _directory() async =>
      _appDirectory ??= await getApplicationDocumentsDirectory();

  Future<File> _reportsFile() async {
    final directory = await _directory();
    return File('${directory.path}/campus_sos_reports.json');
  }

  Future<void> _save() async {
    final file = await _reportsFile();
    await file.writeAsString(
      jsonEncode(_reports.map((report) => report.toJson()).toList()),
    );
  }
}

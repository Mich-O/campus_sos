import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum IncidentStatus { submitted, acknowledged, inProgress, resolved }
enum ReportScope { all, mine }
enum ReportCategory {
  facilities('Facilities', Icons.apartment_outlined, 'facilities'),
  water('Water', Icons.water_drop_outlined, 'water'),
  electricity('Electricity', Icons.bolt_outlined, 'electricity'),
  safety('Safety', Icons.shield_outlined, 'safety'),
  sanitation('Sanitation', Icons.delete_outline, 'sanitation'),
  furniture('Furniture', Icons.chair_outlined, 'furniture'),
  other('Other', Icons.more_horiz, 'other');
  const ReportCategory(this.label, this.icon, this.value);
  final String label; final IconData icon; final String value;
  static ReportCategory fromValue(String? value) => values.firstWhere((x) => x.value == value, orElse: () => ReportCategory.other);
}
extension IncidentStatusView on IncidentStatus {
  String get label => switch (this) { IncidentStatus.submitted => 'Submitted', IncidentStatus.acknowledged => 'Acknowledged', IncidentStatus.inProgress => 'In progress', IncidentStatus.resolved => 'Resolved' };
  String get value => switch (this) { IncidentStatus.submitted => 'submitted', IncidentStatus.acknowledged => 'acknowledged', IncidentStatus.inProgress => 'inProgress', IncidentStatus.resolved => 'resolved' };
  static IncidentStatus fromValue(String? value) => IncidentStatus.values.firstWhere((x) => x.value == value, orElse: () => IncidentStatus.submitted);
}
class IncidentReport {
  const IncidentReport({required this.id, required this.shortId, required this.title, required this.description, required this.category, required this.location, required this.status, required this.authorId, required this.createdAt, this.displayAuthor, this.hideName = false, this.photoUrl, this.upvoteCount = 0});
  final String id, shortId, title, description, category, location, authorId;
  final IncidentStatus status; final DateTime createdAt;
  final String? displayAuthor, photoUrl; final bool hideName; final int upvoteCount;
  factory IncidentReport.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final raw = d['createdAt']; final urls = d['photoUrls'] as List<dynamic>? ?? const [];
    final id = doc.id;
    return IncidentReport(id: id, shortId: d['shortId'] as String? ?? id.substring(0, id.length < 8 ? id.length : 8),
      title: d['title'] as String? ?? 'Untitled report', description: d['description'] as String? ?? '',
      category: d['category'] as String? ?? 'other', location: d['location'] as String? ?? 'Campus',
      status: IncidentStatusView.fromValue(d['status'] as String?), authorId: d['authorId'] as String? ?? '',
      createdAt: raw is Timestamp ? raw.toDate() : DateTime.now(), displayAuthor: d['displayAuthor'] as String?,
      hideName: d['hideName'] as bool? ?? false, photoUrl: urls.isEmpty ? null : urls.first as String?,
      upvoteCount: d['upvoteCount'] as int? ?? 0);
  }
}
class StatusUpdate {
  const StatusUpdate({required this.status, required this.note, required this.byName, required this.at});
  final IncidentStatus status; final String note, byName; final DateTime at;
  factory StatusUpdate.fromMap(Map<String, dynamic> d) => StatusUpdate(
    status: IncidentStatusView.fromValue(d['status'] as String?), note: d['note'] as String? ?? '',
    byName: d['byName'] as String? ?? 'Campus staff',
    at: d['at'] is Timestamp ? (d['at'] as Timestamp).toDate() : DateTime.now());
}
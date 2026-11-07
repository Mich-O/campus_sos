import 'package:cloud_firestore/cloud_firestore.dart';

class CampusNotification {
  const CampusNotification({
    required this.id,
    required this.reportId,
    required this.reportTitle,
    required this.shortId,
    required this.status,
    required this.note,
    required this.createdAt,
    required this.isRead,
  });
  final String id, reportId, reportTitle, shortId, status, note;
  final DateTime createdAt;
  final bool isRead;

  factory CampusNotification.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final timestamp = data['createdAt'];
    return CampusNotification(
      id: doc.id,
      reportId: data['reportId'] as String? ?? '',
      reportTitle: data['reportTitle'] as String? ?? 'Your report',
      shortId: data['shortId'] as String? ?? '',
      status: data['status'] as String? ?? 'submitted',
      note: data['note'] as String? ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      isRead: data['readAt'] != null,
    );
  }
}
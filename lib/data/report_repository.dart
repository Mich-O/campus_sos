import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/campus_notification.dart';
import '../models/incident_report.dart';
import 'cloudinary_media_repository.dart';

class ReportRepository {
  ReportRepository({FirebaseFirestore? firestore, required CloudinaryMediaRepository media})
      : _db = firestore ?? FirebaseFirestore.instance, _media = media;
  final FirebaseFirestore _db;
  final CloudinaryMediaRepository _media;

  Stream<List<IncidentReport>> watchReports() async* {
    final query = _db.collection('reports').orderBy('createdAt', descending: true);
    var transientRetries = 0;
    while (true) {
      try {
        await for (final snapshot in query.snapshots()) {
          yield snapshot.docs.map(IncidentReport.fromFirestore).toList();
        }
        return;
      } on FirebaseException catch (error) {
        const retryableCodes = {'unavailable', 'deadline-exceeded', 'unknown'};
        if (!retryableCodes.contains(error.code) || transientRetries >= 2) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 500 * (transientRetries + 1)));
        transientRetries++;
      }
    }
  }

  Stream<List<StatusUpdate>> watchUpdates(String id) => _db.collection('reports').doc(id)
      .collection('updates').orderBy('at').snapshots()
      .map((s) => s.docs.map((d) => StatusUpdate.fromMap(d.data())).toList());

  Stream<List<CampusNotification>> watchNotifications(String uid) => _db.collection('users').doc(uid)
      .collection('notifications').orderBy('createdAt', descending: true).limit(50)
      .snapshots().map((s) => s.docs.map(CampusNotification.fromFirestore).toList());

  Future<void> markNotificationRead(String uid, String notificationId) =>
      _db.collection('users').doc(uid).collection('notifications').doc(notificationId)
          .update({'readAt': FieldValue.serverTimestamp()});

  Future<IncidentReport?> getReport(String id) async {
    final doc = await _db.collection('reports').doc(id).get();
    return doc.exists ? IncidentReport.fromFirestore(doc) : null;
  }

  Future<void> createReport({
    required User user,
    required String name,
    required String title,
    required String description,
    required String category,
    required String location,
    required bool hideName,
    String? photoPath,
  }) async {
    final doc = _db.collection('reports').doc();
    var photoUrls = <String>[];
    if (photoPath != null) {
      final uploaded = await _media.uploadImage(filePath: photoPath, folder: 'campus-sos/reports/' + user.uid);
      photoUrls = [uploaded.url];
    }
    final batch = _db.batch();
    batch.set(doc, {
      'shortId': 'CSOS-' + doc.id.substring(0, 6).toUpperCase(),
      'title': title.trim(), 'description': description.trim(), 'category': category,
      'location': location, 'photoUrls': photoUrls, 'status': 'submitted',
      'authorId': user.uid, 'displayAuthor': hideName ? null : (name.isEmpty ? 'Student' : name),
      'hideName': hideName, 'upvoteCount': 0,
      'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(doc.collection('updates').doc(), {
      'status': 'submitted', 'note': 'Report submitted', 'byUid': user.uid,
      'byName': name.isEmpty ? 'Student' : name, 'at': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> updateStatus({
    required IncidentReport report,
    required IncidentStatus status,
    required String note,
    required User staff,
    required String staffName,
  }) async {
    final reportRef = _db.collection('reports').doc(report.id);
    final batch = _db.batch();
    batch.update(reportRef, {'status': status.value, 'updatedAt': FieldValue.serverTimestamp()});
    batch.set(reportRef.collection('updates').doc(), {
      'status': status.value, 'note': note.trim(), 'byUid': staff.uid,
      'byName': staffName, 'at': FieldValue.serverTimestamp(),
    });
    final notificationRef = _db.collection('users').doc(report.authorId).collection('notifications').doc();
    batch.set(notificationRef, {
      'reportId': report.id, 'reportTitle': report.title, 'shortId': report.shortId,
      'status': status.value, 'note': note.trim(), 'readAt': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<String> uploadProfilePhoto({required User user, required String filePath}) async {
    final uploaded = await _media.uploadImage(filePath: filePath, folder: 'campus-sos/profiles/' + user.uid);
    await _db.collection('users').doc(user.uid).update({'photoUrl': uploaded.url});
    await user.updatePhotoURL(uploaded.url);
    return uploaded.url;
  }

  Future<void> deleteReport(String id) => _db.collection('reports').doc(id).delete();
}

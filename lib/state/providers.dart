import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_service.dart';
import '../data/cloudinary_media_repository.dart';
import '../data/report_repository.dart';
import '../models/campus_notification.dart';
import '../models/incident_report.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final authServiceProvider = Provider<AuthService>((ref) => AuthService(
  auth: ref.watch(firebaseAuthProvider), firestore: ref.watch(firestoreProvider),
));
final cloudinaryMediaProvider = Provider<CloudinaryMediaRepository>((ref) {
  final media = CloudinaryMediaRepository();
  ref.onDispose(media.dispose);
  return media;
});
final reportRepositoryProvider = Provider<ReportRepository>((ref) => ReportRepository(
  firestore: ref.watch(firestoreProvider), media: ref.watch(cloudinaryMediaProvider),
));
final authStateProvider = StreamProvider<User?>((ref) => ref.watch(firebaseAuthProvider).userChanges());

final userProfileProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null || !user.emailVerified) return Stream.value(null);
  return ref.watch(authServiceProvider).watchProfile(user.uid).map((s) {
    final d = s.data();
    if (!s.exists || d == null) return null;
    return AppUser(
      uid: user.uid,
      displayName: d['displayName'] as String? ?? user.displayName ?? 'Student',
      email: d['email'] as String? ?? user.email ?? '',
      role: d['role'] as String? ?? 'student',
      program: d['program'] as String? ?? '',
      location: d['location'] as String? ?? '',
      photoUrl: d['photoUrl'] as String? ?? user.photoURL,
    );
  });
});

class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    this.program = '',
    this.location = '',
    this.photoUrl,
  });
  final String uid, displayName, email, role, program, location;
  final String? photoUrl;
  bool get isStaff => role == 'staff' &&
      (email.toLowerCase() == AuthService.staffEmailException || email.toLowerCase().endsWith('@alueducation.com'));
  bool get isStudent => role == 'student' && email.toLowerCase().endsWith('@alustudent.com');
  bool get canAccess => isStaff || isStudent;
}

final isStaffProvider = Provider<bool>((ref) => ref.watch(userProfileProvider).valueOrNull?.isStaff ?? false);
final allReportsProvider = StreamProvider<List<IncidentReport>>((ref) =>
    ref.watch(reportRepositoryProvider).watchReports());
final reportUpdatesProvider = StreamProvider.family<List<StatusUpdate>, String>((ref, reportId) =>
    ref.watch(reportRepositoryProvider).watchUpdates(reportId));
final notificationsProvider = StreamProvider<List<CampusNotification>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null || !user.emailVerified) return Stream.value(const <CampusNotification>[]);
  return ref.watch(reportRepositoryProvider).watchNotifications(user.uid);
});
final unreadNotificationCountProvider = Provider<int>((ref) =>
    ref.watch(notificationsProvider).valueOrNull?.where((n) => !n.isRead).length ?? 0);

final reportScopeProvider = StateProvider<ReportScope>((ref) => ReportScope.all);
final reportStatusFilterProvider = StateProvider<IncidentStatus?>((ref) => null);
final reportCategoryFilterProvider = StateProvider<String?>((ref) => null);
final reportSearchProvider = StateProvider<String>((ref) => '');

final filteredReportsProvider = Provider<AsyncValue<List<IncidentReport>>>((ref) {
  final items = ref.watch(allReportsProvider);
  final scope = ref.watch(reportScopeProvider);
  final status = ref.watch(reportStatusFilterProvider);
  final category = ref.watch(reportCategoryFilterProvider);
  final query = ref.watch(reportSearchProvider).trim().toLowerCase();
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  return items.whenData((reports) => reports.where((r) =>
    (scope == ReportScope.all || r.authorId == uid) &&
    (status == null || r.status == status) &&
    (category == null || r.category == category) &&
    (query.isEmpty || (r.title + ' ' + r.description + ' ' + r.location + ' ' + r.category + ' ' + r.shortId).toLowerCase().contains(query))).toList());
});

class CreateReportController extends AsyncNotifier<void> {
  @override Future<void> build() async {}
  Future<void> submit({required String title, required String description, required String category, required String location, required bool hideName, String? photoPath}) async {
    final user = ref.read(authStateProvider).valueOrNull;
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (user == null || !user.emailVerified || profile?.isStudent != true) throw StateError('A verified ALU student account is required to submit a report.');
    state = const AsyncLoading();
    try {
      await ref.read(reportRepositoryProvider).createReport(
        user: user, name: profile!.displayName, title: title, description: description,
        category: category, location: location, hideName: hideName, photoPath: photoPath,
      );
      state = const AsyncData(null);
    } catch (e, st) { state = AsyncError(e, st); rethrow; }
  }
}
final createReportControllerProvider = AsyncNotifierProvider<CreateReportController, void>(CreateReportController.new);

class UpdateStatusController extends AsyncNotifier<void> {
  @override Future<void> build() async {}
  Future<void> setStatus(IncidentReport report, IncidentStatus status, String note) async {
    final user = ref.read(authStateProvider).valueOrNull;
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (user == null || profile?.isStaff != true) throw StateError('Staff access is required.');
    state = const AsyncLoading();
    try {
      await ref.read(reportRepositoryProvider).updateStatus(
        report: report, status: status, note: note, staff: user, staffName: profile!.displayName,
      );
      state = const AsyncData(null);
    } catch (e, st) { state = AsyncError(e, st); rethrow; }
  }
}
final updateStatusControllerProvider = AsyncNotifierProvider<UpdateStatusController, void>(UpdateStatusController.new);
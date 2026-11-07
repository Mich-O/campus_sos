import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  static const allowedStudentDomains = {'alustudent.com'};
  static const staffEmailException = 'michaelokinyi19@gmail.com';

  User? get currentUser => _auth.currentUser;

  bool isStudentEmail(String email) {
    final parts = email.trim().toLowerCase().split('@');
    return parts.length == 2 && allowedStudentDomains.contains(parts.last);
  }

  bool isStaffEmail(String email) {
    final normalized = email.trim().toLowerCase();
    return normalized == staffEmailException || normalized.endsWith('@alueducation.com');
  }

  bool isAllowedRegistrationEmail(String email) =>
      isStudentEmail(email) || email.trim().toLowerCase() == staffEmailException;

  Future<void> register({required String name, required String email, required String password}) async {
    final normalized = email.trim().toLowerCase();
    if (!isAllowedRegistrationEmail(normalized)) {
      throw FirebaseAuthException(code: 'invalid-email', message: 'Use your ALU student email or the approved staff account.');
    }
    final role = normalized == staffEmailException ? 'staff' : 'student';
    final credential = await _auth.createUserWithEmailAndPassword(email: normalized, password: password);
    final user = credential.user!;
    await user.updateDisplayName(name.trim());
    await _db.collection('users').doc(user.uid).set({
      'displayName': name.trim(), 'email': normalized, 'role': role,
      'program': '', 'location': '', 'photoUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await user.sendEmailVerification();
    await user.reload();
  }

  Future<void> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final user = credential.user;
    if (user != null &&
        user.emailVerified &&
        user.email?.toLowerCase() == staffEmailException) {
      final profile = _db.collection('users').doc(user.uid);
      final snapshot = await profile.get();
      if (snapshot.exists && snapshot.data()?['role'] == 'student') {
        await profile.update({'role': 'staff'});
      }
    }
  }

  Future<void> resendVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in again to resend the verification email.');
    await user.sendEmailVerification();
  }

  Future<bool> refreshVerification() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> updateProfile({required String name, required String program, required String location}) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in to edit your profile.');
    await _db.collection('users').doc(user.uid).update({
      'displayName': name.trim(), 'program': program.trim(), 'location': location.trim(),
    });
    await user.updateDisplayName(name.trim());
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProfile(String uid) =>
      _db.collection('users').doc(uid).snapshots();

  Future<void> signOut() => _auth.signOut();
}

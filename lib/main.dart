import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: CampusSosApp()));
}
class CampusSosApp extends StatelessWidget {
  const CampusSosApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(title: 'Campus SOS', debugShowCheckedModeBanner: false, theme: buildTheme(), home: const AuthGate());
}
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    return auth.when(
      loading: () => const _LoadingScreen(),
      error: (_, __) => const _MessageScreen('Could not check your sign-in. Restart the app to retry.'),
      data: (user) {
        if (user == null) return const AuthScreen();
        if (!user.emailVerified) return VerifyEmailScreen(email: user.email ?? '');
        return ref.watch(userProfileProvider).when(
          loading: () => const _LoadingScreen(),
          error: (_, __) => const _MessageScreen('Could not load your account. Check your connection and retry.'),
          data: (profile) => profile == null ? const _MessageScreen('Your profile is missing. Sign out and register again.') : profile.canAccess ? const HomeScreen() : const _MessageScreen('This verified email is not authorized for Campus SOS.'),
        );
      });
  }
}
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.brand)));
}
class _MessageScreen extends ConsumerWidget {
  const _MessageScreen(this.message, {super.key});
  final String message;
  @override Widget build(BuildContext context, WidgetRef ref) => Scaffold(body: Center(child: Padding(
    padding: const EdgeInsets.all(AppSpacing.screen), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(message, textAlign: TextAlign.center, style: AppText.body),
      const SizedBox(height: 16),
      OutlinedButton(onPressed: () => ref.read(authServiceProvider).signOut(), child: const Text('Sign out')),
    ]))));
}
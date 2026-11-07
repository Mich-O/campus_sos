import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../state/providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override ConsumerState<AuthScreen> createState() => _AuthScreenState();
}
class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _email = TextEditingController(), _password = TextEditingController();
  bool _registering = false, _busy = false, _obscure = true;
  String? _error;
  @override void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      final service = ref.read(authServiceProvider);
      if (_registering) await service.register(name: _name.text, email: _email.text, password: _password.text);
      else await service.signIn(_email.text, _password.text);
    } on FirebaseAuthException catch (e) { setState(() => _error = _authMessage(e)); }
    catch (e) { setState(() => _error = e.toString().replaceFirst('Exception: ', '')); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  String _authMessage(FirebaseAuthException e) => switch (e.code) {
    'invalid-email' => e.message ?? 'Use your ALU student email or the approved staff account.',
    'user-not-found' || 'wrong-password' || 'invalid-credential' => 'Email or password is incorrect.',
    'email-already-in-use' => 'An account already exists for this email.',
    'weak-password' => 'Choose a password with at least 6 characters.',
    'network-request-failed' => 'Could not connect. Check your internet connection.',
    _ => e.message ?? 'Sign-in failed. Please try again.',
  };
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.ink,
    body: SafeArea(child: Stack(children: [
      Positioned(right: -90, top: -70, child: _Circle(color: AppColors.brand, size: 250)),
      Positioned(left: -105, bottom: -120, child: _Circle(color: AppColors.lime, size: 250)),
      SingleChildScrollView(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 50, AppSpacing.screen, 32), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CAMPUS SOS', style: AppText.mono.copyWith(color: AppColors.brandTint, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Text(_registering ? 'Join your campus.' : 'Own what you see.', style: AppText.h1.copyWith(color: AppColors.surface)),
          const SizedBox(height: 8),
          Text('Report campus issues and follow them through resolution.', style: AppText.body.copyWith(color: AppColors.surface)),
          const SizedBox(height: 28),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.hero)), child: Form(
            key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (_registering) ...[
                Text('Name', style: AppText.label), const SizedBox(height: 6),
                TextFormField(controller: _name, textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your name.' : null),
                const SizedBox(height: 14),
              ],
              Text('ALU email', style: AppText.label), const SizedBox(height: 6),
              TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, autocorrect: false,
                validator: (v) {
                  final value = (v ?? '').trim().toLowerCase();
                  if (!value.contains('@')) return 'Enter a valid email address.';
                  if (_registering && !ref.read(authServiceProvider).isAllowedRegistrationEmail(value)) return 'Use your ALU student email or the approved staff account.';
                  return null;
                }),
              const SizedBox(height: 14),
              Text('Password', style: AppText.label), const SizedBox(height: 6),
              TextFormField(controller: _password, obscureText: _obscure, textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(suffixIcon: IconButton(tooltip: _obscure ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
                validator: (v) => (v == null || v.length < 6) ? 'Use at least 6 characters.' : null),
              if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: AppText.secondary.copyWith(color: AppColors.error))],
              const SizedBox(height: 20),
              SizedBox(height: 56, child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _registering ? AppColors.brand : AppColors.lime, foregroundColor: _registering ? Colors.white : AppColors.ink, shape: const StadiumBorder()),
                onPressed: _busy ? null : _submit,
                child: _busy ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_registering ? 'Create account' : 'Sign in', style: AppText.button),
              )),
              const SizedBox(height: 12),
              TextButton(onPressed: _busy ? null : () => setState(() { _registering = !_registering; _error = null; }),
                child: Text(_registering ? 'Already have an account? Sign in' : 'Create an account', style: AppText.label.copyWith(color: AppColors.brand))),
            ]),
          )),
          const SizedBox(height: 20),
          Text('Verified ALU student accounts and authorized staff can access campus reports.', style: AppText.secondary.copyWith(color: AppColors.surface), textAlign: TextAlign.center),
        ],
      )),
    ])),
  );
}
class _Circle extends StatelessWidget {
  const _Circle({required this.color, required this.size});
  final Color color; final double size;
  @override Widget build(BuildContext context) => IgnorePointer(child: Container(width: size, height: size, decoration: BoxDecoration(color: color.withValues(alpha: .28), shape: BoxShape.circle)));
}
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({required this.email, super.key});
  final String email;
  @override ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}
class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _timer; int _seconds = 0; bool _busy = false; String? _message;
  @override void dispose() { _timer?.cancel(); super.dispose(); }
  void _startCooldown() {
    setState(() => _seconds = 30); _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) { timer.cancel(); if (mounted) setState(() => _seconds = 0); }
      else if (mounted) setState(() => _seconds--);
    });
  }
  Future<void> _resend() async {
    setState(() { _busy = true; _message = null; });
    try { await ref.read(authServiceProvider).resendVerification(); _startCooldown(); setState(() => _message = 'Verification link sent.'); }
    catch (e) { setState(() => _message = e.toString()); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  Future<void> _check() async {
    setState(() { _busy = true; _message = null; });
    try {
      final verified = await ref.read(authServiceProvider).refreshVerification();
      if (!verified) setState(() => _message = 'We have not received verification yet. Check your inbox, then try again.');
    } catch (e) { setState(() => _message = e.toString()); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.all(AppSpacing.screen), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Spacer(), const Icon(Icons.mark_email_unread_outlined, color: AppColors.brand, size: 52),
      const SizedBox(height: 24), Text('Check your inbox', style: AppText.h1), const SizedBox(height: 12),
      Text('We sent a verification link to ' + widget.email + '. Open it, then return here.', style: AppText.body),
      if (_message != null) ...[const SizedBox(height: 16), Text(_message!, style: AppText.secondary)],
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, height: 56, child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.brand, shape: const StadiumBorder()),
        onPressed: _busy ? null : _check,
        child: _busy ? const CircularProgressIndicator(color: Colors.white) : Text("I've verified", style: AppText.button.copyWith(color: Colors.white)))),
      Center(child: TextButton(onPressed: _busy || _seconds > 0 ? null : _resend, child: Text(_seconds > 0 ? 'Resend in ' + _seconds.toString() + 's' : 'Resend verification email'))),
      Center(child: TextButton(onPressed: () => ref.read(authServiceProvider).signOut(), child: const Text('Sign out'))),
      const Spacer(),
    ],
  ))));
}
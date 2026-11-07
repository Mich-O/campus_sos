import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/incident_report.dart';
import '../state/providers.dart';
import '../widgets/report_widgets.dart';
import 'staff_console_screen.dart';

class ReportDetailsScreen extends ConsumerWidget {
  const ReportDetailsScreen({required this.report, super.key});
  final IncidentReport report;
  @override Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(isStaffProvider);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final category = ReportCategory.fromValue(report.category);
    final updates = ref.watch(reportUpdatesProvider(report.id));
    return Scaffold(appBar: AppBar(title: const Text('Incident Details')), body: ListView(padding: const EdgeInsets.all(AppSpacing.screen), children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(category.icon, color: AppColors.brand, size: 38), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(report.title, style: AppText.title), Text(report.location, style: AppText.secondary), const SizedBox(height: 5), StatusPill(status: report.status)]))]),
          const Divider(height: 28),
          Text('Submitted ' + relativeTime(report.createdAt), style: AppText.secondary),
          Text('Reported by ' + (report.hideName && uid != report.authorId && !staff ? 'Anonymous' : (report.displayAuthor ?? 'Student')), style: AppText.secondary),
        ])),
      const SizedBox(height: 22), Text('Status Timeline', style: AppText.h2), const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.border)),
        child: Row(children: [StatusRing(filled: report.status.index + 1), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(report.status.label, style: AppText.h2), Text((report.status.index + 1).toString() + ' of 4 steps complete', style: AppText.secondary)])])),
      const SizedBox(height: 22), Text('Updates from campus staff', style: AppText.h2),
      const SizedBox(height: 8),
      updates.when(
        loading: () => const LinearProgressIndicator(),
        error: (error, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Could not load report updates: $error', style: AppText.secondary),
          TextButton(
            onPressed: () => ref.invalidate(reportUpdatesProvider(report.id)),
            child: const Text('Retry'),
          ),
        ]),
        data: (items) => items.isEmpty
          ? Text('No updates yet.', style: AppText.secondary)
          : Column(children: items.map((update) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.update, color: AppColors.brand),
              title: Text(update.status.label, style: AppText.bodyBold),
              subtitle: Text(update.note + (update.byName.isEmpty ? '' : ' · ' + update.byName), style: AppText.secondary),
              trailing: Text(relativeTime(update.at), style: AppText.mono),
            )).toList()),
      ),
      const SizedBox(height: 22), Text('Description', style: AppText.h2), const SizedBox(height: 8), Text(report.description, style: AppText.body),
      if (report.photoUrl != null) ...[const SizedBox(height: 20), Text('Attached Photo', style: AppText.h2), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(AppRadius.card), child: Image.network(report.photoUrl!, height: 180, fit: BoxFit.cover))],
      if (staff) ...[const SizedBox(height: 24), FilledButton(onPressed: () => showStatusUpdateSheet(context, report), child: const Text('Update status'))],
    ]));
  }
}

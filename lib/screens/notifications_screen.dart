import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/incident_report.dart';
import '../models/campus_notification.dart';
import '../state/providers.dart';
import '../widgets/report_widgets.dart';
import 'report_details_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _openNotification(BuildContext context, WidgetRef ref, CampusNotification notification) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    try {
      if (!notification.isRead) {
        await ref.read(reportRepositoryProvider).markNotificationRead(user.uid, notification.id);
      }
      final report = await ref.read(reportRepositoryProvider).getReport(notification.reportId);
      if (context.mounted && report != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ReportDetailsScreen(report: report)));
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('That report is no longer available.')));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open the notification: ' + e.toString())));
    }
  }

  @override Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return Scaffold(appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(child: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: TextButton(onPressed: () => ref.invalidate(notificationsProvider), child: const Text('Could not load notifications. Retry'))),
        data: (items) => items.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.screen), child: Text('You’re all caught up. Report updates will appear here.', textAlign: TextAlign.center, style: AppText.body)))
          : ListView.separated(padding: const EdgeInsets.all(AppSpacing.screen), itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                final status = IncidentStatusView.fromValue(item.status);
                return Material(color: item.isRead ? AppColors.surface : AppColors.brandTint,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: InkWell(borderRadius: BorderRadius.circular(AppRadius.card), onTap: () => _openNotification(context, ref, item),
                    child: Container(padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.border)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(item.reportTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.bodyBold)),
                          StatusPill(status: status),
                        ]),
                        const SizedBox(height: 6),
                        Text(item.shortId + ' · ' + relativeTime(item.createdAt), style: AppText.mono),
                        if (item.note.isNotEmpty) ...[const SizedBox(height: 8), Text(item.note, style: AppText.body)],
                        if (!item.isRead) ...[const SizedBox(height: 8), Text('NEW', style: AppText.mono.copyWith(color: AppColors.brand, fontWeight: FontWeight.w700))],
                      ]),
                    ),
                  ),
                );
              },
            ),
      )),
    );
  }
}
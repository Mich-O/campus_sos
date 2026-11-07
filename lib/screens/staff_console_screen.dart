import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/incident_report.dart';
import '../state/providers.dart';
import '../widgets/report_widgets.dart';

class StaffConsoleScreen extends ConsumerWidget {
  const StaffConsoleScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isStaffProvider)) return const Scaffold(body: Center(child: Text('Staff access is required.')));
    return Scaffold(appBar: AppBar(title: const Text('Staff Console')), body: ref.watch(allReportsProvider).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: TextButton(onPressed: () => ref.invalidate(allReportsProvider), child: const Text('Retry'))),
      data: (reports) => ListView(padding: const EdgeInsets.all(AppSpacing.screen), children: [
        Text('CAMPUS SERVICES', style: AppText.mono), const SizedBox(height: 8), Text('Triage', style: AppText.h1),
        Text(reports.where((r) => r.status == IncidentStatus.submitted).length.toString() + ' need acknowledging', style: AppText.secondary),
        const SizedBox(height: 16),
        ...reports.map((r) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ReportCard(report: r, onTap: () => showStatusUpdateSheet(context, r)))),
      ]),
    ));
  }
}
Future<void> showStatusUpdateSheet(BuildContext context, IncidentReport report) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _StatusUpdateSheet(report: report),
    );

class _StatusUpdateSheet extends ConsumerStatefulWidget {
  const _StatusUpdateSheet({required this.report});
  final IncidentReport report;

  @override
  ConsumerState<_StatusUpdateSheet> createState() => _StatusUpdateSheetState();
}

class _StatusUpdateSheetState extends ConsumerState<_StatusUpdateSheet> {
  late IncidentStatus _status;
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.report.status;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await ref.read(updateStatusControllerProvider.notifier).setStatus(
            widget.report,
            _status,
            _note.text,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not post update: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screen,
            20,
            AppSpacing.screen,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update ' + widget.report.shortId, style: AppText.h2),
              const SizedBox(height: 12),
              DropdownButtonFormField<IncidentStatus>(
                value: _status,
                items: IncidentStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: _saving ? null : (s) => setState(() => _status = s!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Note for the student'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Post update'),
                ),
              ),
            ],
          ),
        ),
      );
}

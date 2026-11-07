import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/auth_service.dart';
import '../models/incident_report.dart';
import '../state/providers.dart';
import '../widgets/report_widgets.dart';
import 'new_report_screen.dart';
import 'report_details_screen.dart';
import 'staff_console_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override ConsumerState<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;
  void _openReport(IncidentReport report) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportDetailsScreen(report: report)));
  Future<void> _newReport() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewReportScreen()));
    ref.invalidate(allReportsProvider);
  }
  @override Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    return Scaffold(
      body: IndexedStack(index: _tab, children: [
        _HomeTab(name: profile?.displayName ?? 'Student', photoUrl: profile?.photoUrl, onSeeAll: () => setState(() => _tab = 1), onNew: _newReport, onOpen: _openReport, onProfile: () => setState(() => _tab = 2)),
        _ReportsTab(onOpen: _openReport),
        const _ProfileTab(),
      ]),
      bottomNavigationBar: _CampusNav(selected: _tab, onSelect: (i) => setState(() => _tab = i), onReport: _newReport),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab({required this.name, required this.photoUrl, required this.onSeeAll, required this.onNew, required this.onOpen, required this.onProfile});
  final String name; final String? photoUrl; final VoidCallback onSeeAll, onNew, onProfile; final ValueChanged<IncidentReport> onOpen;
  @override Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(allReportsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final profilePhoto = photoUrl;
    final first = name.split(' ').first;
    return SafeArea(child: CustomScrollView(slivers: [
      SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 18, AppSpacing.screen, 8), sliver: SliverToBoxAdapter(
        child: Row(children: [
          Expanded(child: Text('ALU KIGALI · CAMPUS SOS', style: AppText.mono.copyWith(letterSpacing: 1.2))),
          IconButton(tooltip: 'Notifications', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), icon: Stack(clipBehavior: Clip.none, children: [const Icon(Icons.notifications_none, color: AppColors.ink), if (unread > 0) Positioned(right: -3, top: -3, child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle))) ])),
          Semantics(button: true, label: 'Open profile', child: InkWell(onTap: onProfile, borderRadius: BorderRadius.circular(30), child: CircleAvatar(backgroundColor: AppColors.ink, backgroundImage: profilePhoto == null || profilePhoto.isEmpty ? null : NetworkImage(profilePhoto), child: profilePhoto == null || profilePhoto.isEmpty ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'S', style: AppText.label.copyWith(color: AppColors.surface)) : null))),
        ]),
      )),
      SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 14, AppSpacing.screen, 0), sliver: SliverToBoxAdapter(
        child: Text('Muraho, ' + first + '.', style: AppText.h1),
      )),
      SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, AppSpacing.screen, 0), sliver: SliverToBoxAdapter(
        child: Text('Help make our campus safer. Report issues and track their resolution.', style: AppText.secondary),
      )),
      SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 18, AppSpacing.screen, 0), sliver: SliverToBoxAdapter(
        child: _HeroAction(onTap: onNew),
      )),
      SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 24, AppSpacing.screen, 0), sliver: SliverToBoxAdapter(
        child: SectionHeading('Your Summary', action: 'See all', onAction: onSeeAll),
      )),
      reports.when(
        loading: () => const SliverPadding(padding: EdgeInsets.all(AppSpacing.screen), sliver: SliverToBoxAdapter(child: LinearProgressIndicator())),
        error: (e, _) => SliverToBoxAdapter(child: _InlineError(error: e, onRetry: () => ref.invalidate(allReportsProvider))),
        data: (items) {
          final mine = items.where((r) => r.authorId == uid).toList();
          return SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, AppSpacing.screen, 0),
            sliver: SliverToBoxAdapter(child: Row(children: [
              _StatCard(value: mine.length.toString(), label: 'My Reports', tint: AppColors.brandTint),
              const SizedBox(width: 8), _StatCard(value: mine.where((r) => r.status == IncidentStatus.inProgress || r.status == IncidentStatus.acknowledged).length.toString(), label: 'In Progress', tint: AppColors.blueTint),
              const SizedBox(width: 8), _StatCard(value: mine.where((r) => r.status == IncidentStatus.resolved).length.toString(), label: 'Resolved', tint: AppColors.greenTint),
              const SizedBox(width: 8), _StatCard(value: mine.where((r) => r.status == IncidentStatus.submitted).length.toString(), label: 'Submitted', tint: AppColors.goldTint),
            ])),
          );
        },
      ),
      SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 24, AppSpacing.screen, 0), sliver: SliverToBoxAdapter(
        child: SectionHeading('Recent on Campus', action: 'See all', onAction: onSeeAll),
      )),
      reports.when(
        loading: () => const SliverPadding(padding: EdgeInsets.fromLTRB(AppSpacing.screen, 8, AppSpacing.screen, 100), sliver: SliverToBoxAdapter(child: _SkeletonRows())),
        error: (e, _) => SliverToBoxAdapter(child: _InlineError(error: e, onRetry: () => ref.invalidate(allReportsProvider))),
        data: (items) => items.isEmpty
          ? const SliverPadding(padding: EdgeInsets.fromLTRB(AppSpacing.screen, 20, AppSpacing.screen, 100), sliver: SliverToBoxAdapter(child: _EmptyReports()))
          : SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, AppSpacing.screen, 100), sliver: SliverList.separated(
              itemCount: items.take(3).length, separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => ReportCard(report: items[i], isMine: items[i].authorId == uid, onTap: () => onOpen(items[i])))),
      ),
    ]));
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab({required this.onOpen});
  final ValueChanged<IncidentReport> onOpen;
  @override Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(reportScopeProvider);
    final status = ref.watch(reportStatusFilterProvider);
    final filtered = ref.watch(filteredReportsProvider);
    final all = ref.watch(allReportsProvider).valueOrNull ?? const <IncidentReport>[];
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final mineCount = all.where((r) => r.authorId == uid).length;
    return SafeArea(child: CustomScrollView(slivers: [
      SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 22, AppSpacing.screen, 10), sliver: SliverToBoxAdapter(
        child: Row(children: [
          Expanded(child: Text('Reports', style: AppText.h1.copyWith(fontSize: 28))),
          IconButton(tooltip: 'Filter by category', onPressed: () => _showCategoryFilter(context, ref), icon: const Icon(Icons.tune, color: AppColors.ink)),
        ]),
      )),
      SliverPadding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen), sliver: SliverToBoxAdapter(
        child: TextField(onChanged: (v) => ref.read(reportSearchProvider.notifier).state = v,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search reports')),
      )),
      SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 12, AppSpacing.screen, 0), sliver: SliverToBoxAdapter(
        child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.segmentBg, borderRadius: BorderRadius.circular(24)),
          child: Row(children: [
            _Segment(label: 'All reports · ' + all.length.toString(), active: scope == ReportScope.all, onTap: () => ref.read(reportScopeProvider.notifier).state = ReportScope.all),
            _Segment(label: 'Mine · ' + mineCount.toString(), active: scope == ReportScope.mine, onTap: () => ref.read(reportScopeProvider.notifier).state = ReportScope.mine),
          ]),
        ),
      )),
      SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 12, AppSpacing.screen, 8), sliver: SliverToBoxAdapter(
        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          _FilterChip(label: 'All', selected: status == null, onTap: () => ref.read(reportStatusFilterProvider.notifier).state = null),
          for (final value in IncidentStatus.values) _FilterChip(label: value.label, selected: status == value, onTap: () => ref.read(reportStatusFilterProvider.notifier).state = value),
        ])),
      )),
      if (scope == ReportScope.mine)
        SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 2, AppSpacing.screen, 8), sliver: SliverToBoxAdapter(child: Row(children: [
          _StatCard(value: mineCount.toString(), label: 'Total', tint: AppColors.brandTint),
          const SizedBox(width: 8), _StatCard(value: all.where((r) => r.authorId == uid && r.status == IncidentStatus.inProgress).length.toString(), label: 'In Progress', tint: AppColors.blueTint),
          const SizedBox(width: 8), _StatCard(value: all.where((r) => r.authorId == uid && r.status == IncidentStatus.resolved).length.toString(), label: 'Resolved', tint: AppColors.greenTint),
        ]))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 2, AppSpacing.screen, 8), sliver: SliverToBoxAdapter(
        child: Text(scope == ReportScope.all ? 'SHOWING ' + all.length.toString() + ' CAMPUS REPORTS · ' + mineCount.toString() + ' ARE YOURS' : mineCount.toString() + ' OF YOUR REPORTS',
          style: AppText.mono),
      )),
      filtered.when(
        loading: () => const SliverPadding(padding: EdgeInsets.all(AppSpacing.screen), sliver: SliverToBoxAdapter(child: _SkeletonRows())),
        error: (e, _) => SliverToBoxAdapter(child: _InlineError(error: e, onRetry: () => ref.invalidate(allReportsProvider))),
        data: (items) => items.isEmpty
          ? SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 18, AppSpacing.screen, 100), sliver: SliverToBoxAdapter(child:
              Text(ref.read(reportSearchProvider).isNotEmpty ? 'No reports match. Try fewer filters.' : scope == ReportScope.mine ? 'Nothing broken on your watch.' : 'Nothing reported yet. Be the first to own it.', style: AppText.body)))
          : SliverPadding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, 100), sliver: SliverList.separated(
              itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => ReportCard(report: items[i], isMine: items[i].authorId == uid, onTap: () => onOpen(items[i])))),
      ),
    ]));
  }
  void _showCategoryFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(context: context, builder: (context) {
      final selected = ref.read(reportCategoryFilterProvider);
      return SafeArea(child: Padding(padding: const EdgeInsets.all(AppSpacing.screen), child: Wrap(spacing: 8, runSpacing: 8, children: [
        _FilterChip(label: 'Every category', selected: selected == null, onTap: () { ref.read(reportCategoryFilterProvider.notifier).state = null; Navigator.pop(context); }),
        for (final category in ReportCategory.values) _FilterChip(label: category.label, selected: selected == category.value,
          onTap: () { ref.read(reportCategoryFilterProvider.notifier).state = category.value; Navigator.pop(context); }),
      ])));
    });
  }
}
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();
  Future<void> _editProfile(BuildContext context, WidgetRef ref, AppUser profile) async {
    final name = TextEditingController(text: profile.displayName);
    final program = TextEditingController(text: profile.program);
    final location = TextEditingController(text: profile.location);
    try {
      final save = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profile'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: program, decoration: const InputDecoration(labelText: 'Program')),
          TextField(controller: location, decoration: const InputDecoration(labelText: 'Campus location')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save')),
        ],
      ));
      if (save == true) {
        await ref.read(authServiceProvider).updateProfile(name: name.text, program: program.text, location: location.text);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update profile: ' + e.toString())));
    } finally {
      name.dispose(); program.dispose(); location.dispose();
    }
  }
  Future<void> _changeProfilePhoto(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82, maxWidth: 1200);
      if (image == null) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading profile photo...')));
      await ref.read(reportRepositoryProvider).uploadProfilePhoto(user: user, filePath: image.path);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated.')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))));
    }
  }
  @override Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final staff = profile?.isStaff ?? false;
    final photoUrl = profile?.photoUrl ?? '';
    return SafeArea(child: ListView(padding: const EdgeInsets.all(AppSpacing.screen), children: [
      const SizedBox(height: 12), Row(children: [Expanded(child: Text('Profile', style: AppText.h1)), IconButton(tooltip: 'Edit profile details', onPressed: profile == null ? null : () => _editProfile(context, ref, profile), icon: const Icon(Icons.edit_outlined))]),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: AppColors.border)),
        child: Column(children: [
          CircleAvatar(radius: 32, backgroundColor: AppColors.ink, backgroundImage: photoUrl.isEmpty ? null : NetworkImage(photoUrl), child: photoUrl.isEmpty ? Text((profile?.displayName.isNotEmpty == true ? profile!.displayName[0] : 'S').toUpperCase(), style: AppText.h2.copyWith(color: AppColors.surface)) : null),
          const SizedBox(height: 12), Text(profile?.displayName ?? 'Student', style: AppText.h2),
          TextButton.icon(onPressed: () => _changeProfilePhoto(context, ref), icon: const Icon(Icons.camera_alt_outlined), label: const Text('Change photo')),
          const SizedBox(height: 6), StatusRoleBadge(label: staff ? 'Staff' : 'Student'),
          const SizedBox(height: 12), Text(profile?.program.isNotEmpty == true ? profile!.program : 'ALU Kigali', style: AppText.secondary),
          Text(profile?.location.isNotEmpty == true ? profile!.location : 'Kigali, Rwanda', style: AppText.secondary),
          const SizedBox(height: 12), Text(profile?.email ?? '', style: AppText.secondary),
        ]),
      ),
      const SizedBox(height: 16),
      if (staff) ListTile(
        leading: const Icon(Icons.assignment_outlined, color: AppColors.brand),
        title: Text('Staff console', style: AppText.bodyBold), trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffConsoleScreen())),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: () => ref.read(authServiceProvider).signOut(), icon: const Icon(Icons.logout), label: const Text('Sign out')),
    ]));
  }
}
class StatusRoleBadge extends StatelessWidget {
  const StatusRoleBadge({required this.label, super.key});
  final String label;
  @override Widget build(BuildContext context) => DecoratedBox(decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(16)),
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: Text(label, style: AppText.secondary.copyWith(color: AppColors.brand, fontWeight: FontWeight.w700))));
}

class _CampusNav extends StatelessWidget {
  const _CampusNav({required this.selected, required this.onSelect, required this.onReport});
  final int selected; final ValueChanged<int> onSelect; final VoidCallback onReport;
  @override Widget build(BuildContext context) => SafeArea(top: false, child: SizedBox(height: 84, child: Stack(clipBehavior: Clip.none, children: [
    Container(height: 84, decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(children: [
        _NavItem(icon: Icons.home_outlined, label: 'Home', active: selected == 0, onTap: () => onSelect(0)),
        _NavItem(icon: Icons.description_outlined, label: 'Reports', active: selected == 1, onTap: () => onSelect(1)),
        const Expanded(child: SizedBox.shrink()),
        _NavItem(icon: Icons.person_outline, label: 'Profile', active: selected == 2, onTap: () => onSelect(2)),
      ]),
    ),
    Positioned(left: MediaQuery.sizeOf(context).width * 5 / 8 - 30, top: -18, child: Column(children: [
      Container(width: 60, height: 60, padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.paper, shape: BoxShape.circle),
        child: DecoratedBox(decoration: const BoxDecoration(color: AppColors.lime, shape: BoxShape.circle),
          child: IconButton(tooltip: 'Report an issue', onPressed: onReport, icon: const Icon(Icons.add, color: AppColors.ink, size: 28)))),
      Text('Report', style: AppText.secondary.copyWith(color: AppColors.ink, fontWeight: FontWeight.w700)),
    ])),
  ])));
}
class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});
  final IconData icon; final String label; final bool active; final VoidCallback onTap;
  @override Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, color: active ? AppColors.brand : AppColors.grey),
    Text(label, style: AppText.secondary.copyWith(color: active ? AppColors.brand : AppColors.grey, fontWeight: FontWeight.w700)),
  ])));
}
class _HeroAction extends StatelessWidget {
  const _HeroAction({required this.onTap}); final VoidCallback onTap;
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadius.hero)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('See an issue on campus?', style: AppText.h2.copyWith(color: AppColors.surface)),
      const SizedBox(height: 6), Text('Own it. Report it. Help get it fixed.', style: AppText.secondary.copyWith(color: AppColors.surface)),
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, height: 54, child: FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: AppColors.lime, foregroundColor: AppColors.ink, shape: const StadiumBorder()),
        onPressed: onTap, icon: const Icon(Icons.add), label: Text('Report an issue', style: AppText.button))),
    ]),
  );
}
class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.tint});
  final String value, label; final Color tint;
  @override Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
    decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(16)),
    child: Column(children: [Text(value, style: AppText.stat), const SizedBox(height: 4), SizedBox(height: 18, child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1, style: AppText.secondary))))]),
  ));
}
class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.active, required this.onTap});
  final String label; final bool active; final VoidCallback onTap;
  @override Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: active ? AppColors.surface : Colors.transparent, borderRadius: BorderRadius.circular(22)),
    child: Text(label, textAlign: TextAlign.center, style: AppText.secondary.copyWith(color: AppColors.ink, fontWeight: active ? FontWeight.w700 : FontWeight.w500)))));
}
class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label; final bool selected; final VoidCallback onTap;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(right: 7), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppRadius.chip), child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(color: selected ? AppColors.brand : AppColors.segmentBg, borderRadius: BorderRadius.circular(AppRadius.chip)),
    child: Text(label, style: AppText.secondary.copyWith(color: selected ? Colors.white : AppColors.ink, fontWeight: FontWeight.w700)))));
}
class _InlineError extends StatelessWidget {
  const _InlineError({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(AppSpacing.screen), child: Column(children: [
    Text("Couldn't load reports: $error", style: AppText.body), TextButton(onPressed: onRetry, child: const Text('Retry')),
  ]));
}
class _EmptyReports extends StatelessWidget {
  const _EmptyReports();
  @override Widget build(BuildContext context) => Column(children: [
    const Icon(Icons.inbox_outlined, color: AppColors.brand, size: 40),
    const SizedBox(height: 8), Text('Nothing reported yet. Be the first to own it.', textAlign: TextAlign.center, style: AppText.body),
  ]);
}
class _SkeletonRows extends StatelessWidget {
  const _SkeletonRows();
  @override Widget build(BuildContext context) => Column(children: List.generate(3, (_) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Container(height: 82,
    decoration: BoxDecoration(color: AppColors.segmentBg, borderRadius: BorderRadius.circular(AppRadius.card))))));
}

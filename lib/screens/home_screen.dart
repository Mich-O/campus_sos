import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident_report.dart';
import '../state/app_state.dart';
import 'account_screen.dart';
import 'new_report_screen.dart';
import 'report_details_screen.dart';

const _violet = Color(0xFF6546E8);
const _ink = Color(0xFF17233D);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _filter = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final reports = app.reports.where((report) {
      final matchesStatus =
          _filter == 'All' || statusLabel(report.status) == _filter;
      final q = _query.toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          '${report.title} ${report.description} ${report.category} ${report.location}'
              .toLowerCase()
              .contains(q);
      return matchesStatus && matchesQuery;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: _tab == 2
            ? AccountScreen(onBack: () => setState(() => _tab = 0))
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _tab == 0 ? 'Campus SOS' : 'Campus reports',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: _ink,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _tab == 0
                                      ? 'A better campus starts with a report.'
                                      : 'See what needs attention on campus.',
                                  style: const TextStyle(
                                    color: Color(0xFF727C94),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: () => setState(() => _tab = 2),
                            icon: const Icon(Icons.person_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_tab == 0)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      sliver: SliverToBoxAdapter(
                        child: _ReportBanner(onTap: _openNewReport),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Report overview',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                              ),
                            ),
                          ),
                          Text(
                            '${app.reports.length} total',
                            style: const TextStyle(color: Color(0xFF777F95)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _SummaryRow(reports: app.reports),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Recent reports',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                              ),
                            ),
                          ),
                          if (_tab == 0)
                            TextButton(
                              onPressed: () => setState(() => _tab = 1),
                              child: const Text('Browse all'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: TextField(
                        onChanged: (value) => setState(() => _query = value),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Search reports or locations',
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final label in [
                              'All',
                              'Submitted',
                              'In progress',
                              'Resolved',
                            ])
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(label),
                                  selected: _filter == label,
                                  onSelected: (_) =>
                                      setState(() => _filter = label),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (reports.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(36),
                          child: Text(
                            'No reports match that search yet.',
                            style: TextStyle(color: Color(0xFF727C94)),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList.separated(
                        itemCount: _tab == 0
                            ? (reports.length < 4 ? reports.length : 4)
                            : reports.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => ReportCard(
                          report: reports[index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportDetailsScreen(
                                reportId: reports[index].id,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewReport,
        backgroundColor: _violet,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Report an issue',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab == 2 ? 0 : _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _openNewReport() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const NewReportScreen()),
  );
}

class _ReportBanner extends StatelessWidget {
  const _ReportBanner({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [_violet, Color(0xFF886EF5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'See something\nthat needs fixing?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Let campus staff know. You can follow its progress here.',
          style: TextStyle(color: Colors.white, height: 1.4),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _violet,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'Create a report',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.reports});
  final List<IncidentReport> reports;
  @override
  Widget build(BuildContext context) {
    final items = [
      ('${reports.length}', 'All reports', const Color(0xFFEDE8FF), _violet),
      (
        '${reports.where((r) => r.status == IncidentStatus.submitted || r.status == IncidentStatus.inProgress).length}',
        'In progress',
        const Color(0xFFEAF2FF),
        const Color(0xFF3674D9),
      ),
      (
        '${reports.where((r) => r.status == IncidentStatus.resolved).length}',
        'Resolved',
        const Color(0xFFE7F7F0),
        const Color(0xFF25835D),
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == items.length - 1 ? 0 : 9),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: items[i].$3,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      items[i].$1,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: items[i].$4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i].$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF667189),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report, required this.onTap});
  final IncidentReport report;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = switch (report.status) {
      IncidentStatus.submitted => const Color(0xFFB56A12),
      IncidentStatus.inProgress => const Color(0xFF365FC6),
      IncidentStatus.resolved => const Color(0xFF25835D),
    };
    final bg = switch (report.status) {
      IncidentStatus.submitted => const Color(0xFFFFF3DA),
      IncidentStatus.inProgress => const Color(0xFFEAF0FF),
      IncidentStatus.resolved => const Color(0xFFE7F7F0),
    };
    final icon = switch (report.category) {
      'Water' => Icons.water_drop_outlined,
      'Electricity' => Icons.bolt_rounded,
      'Safety' => Icons.shield_outlined,
      'Sanitation' => Icons.delete_outline_rounded,
      'Furniture' => Icons.chair_outlined,
      _ => Icons.build_outlined,
    };
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDFF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: report.photoPath == null
                    ? Icon(icon, color: _violet)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          File(report.photoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(icon, color: _violet),
                        ),
                      ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF727C94),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel(report.status),
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF929AAF)),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident_report.dart';
import '../state/app_state.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key, required this.reportId});
  final String reportId;

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<AppState>().reports;
    final matches = reports.where((report) => report.id == reportId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This report is no longer available.')),
      );
    }
    final report = matches.first;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.category.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF6546E8),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  report.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF17233D),
                    fontSize: 23,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: Color(0xFF727C94),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        report.location,
                        style: const TextStyle(color: Color(0xFF727C94)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Reported by ${report.reporterName} · ${_date(report.createdAt)}',
                  style: const TextStyle(
                    color: Color(0xFF929AAF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _StatusTimeline(status: report.status),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  report.description,
                  style: const TextStyle(
                    height: 1.55,
                    color: Color(0xFF505B73),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _date(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});
  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final current = status.index;
    final statuses = IncidentStatus.values;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (var index = 0; index < statuses.length; index++)
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (index > 0)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: index <= current
                                    ? const Color(0xFF6546E8)
                                    : const Color(0xFFE3E6EF),
                              ),
                            ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: index <= current
                                  ? const Color(0xFF6546E8)
                                  : const Color(0xFFE9EBF2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              index < current ? Icons.check : Icons.circle,
                              size: index < current ? 16 : 9,
                              color: index <= current
                                  ? Colors.white
                                  : const Color(0xFF9AA1B3),
                            ),
                          ),
                          if (index < statuses.length - 1)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: index < current
                                    ? const Color(0xFF6546E8)
                                    : const Color(0xFFE3E6EF),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        statusLabel(statuses[index]),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: index == current
                              ? const Color(0xFF6546E8)
                              : const Color(0xFF727C94),
                          fontWeight: index == current
                              ? FontWeight.w800
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

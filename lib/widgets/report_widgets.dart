import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import '../core/theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({required this.status, super.key});
  final IncidentStatus status;
  Color get _color => switch (status) {
    IncidentStatus.submitted => AppColors.gold,
    IncidentStatus.acknowledged => AppColors.blue,
    IncidentStatus.inProgress => AppColors.brand,
    IncidentStatus.resolved => AppColors.green,
  };
  Color get _tint => switch (status) {
    IncidentStatus.submitted => AppColors.goldTint,
    IncidentStatus.acknowledged => AppColors.blueTint,
    IncidentStatus.inProgress => AppColors.brandTint,
    IncidentStatus.resolved => AppColors.greenTint,
  };
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: _tint, borderRadius: BorderRadius.circular(16)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 7, height: 7, decoration: BoxDecoration(color: _color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(status.label, style: AppText.secondary.copyWith(color: AppColors.ink, fontWeight: FontWeight.w700)),
    ]),
  );
}
class ReportCard extends StatelessWidget {
  const ReportCard({required this.report, required this.onTap, this.isMine = false, super.key});
  final IncidentReport report; final VoidCallback onTap; final bool isMine;
  @override Widget build(BuildContext context) {
    final category = ReportCategory.fromValue(report.category);
    return Material(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(borderRadius: BorderRadius.circular(AppRadius.card), onTap: onTap,
        child: Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: isMine ? AppColors.brand : AppColors.border, width: isMine ? 1.5 : 1)),
          child: Row(children: [
            _ReportThumb(report: report, icon: category.icon, size: 56), const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(report.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.bodyBold)),
                if (isMine) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(12)),
                  child: Text('Yours', style: AppText.secondary.copyWith(color: AppColors.brand, fontWeight: FontWeight.w700)))],
              ]),
              const SizedBox(height: 4),
              Text(report.location + (isMine ? '' : ' · by ' + (report.hideName ? 'Anonymous' : (report.displayAuthor ?? 'Student'))),
                maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.secondary),
              const SizedBox(height: 5),
              Text(report.shortId + ' · ' + relativeTime(report.createdAt) + (report.upvoteCount > 0 ? ' · +' + report.upvoteCount.toString() : ''),
                maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.mono),
            ])),
            const SizedBox(width: 8),
            Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
              StatusPill(status: report.status), const SizedBox(height: 4),
              const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
            ]),
          ]),
        ),
      ),
    );
  }
}
class _ReportThumb extends StatelessWidget {
  const _ReportThumb({required this.report, required this.icon, required this.size});
  final IncidentReport report; final IconData icon; final double size;
  @override Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(14),
    child: SizedBox(width: size, height: size, child: report.photoUrl != null
      ? Image.network(report.photoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback())
      : _fallback()));
  Widget _fallback() => ColoredBox(color: AppColors.brandTint, child: Center(child: Icon(icon, color: AppColors.brand, size: size / 2.2)));
}
class StatusRing extends StatelessWidget {
  const StatusRing({required this.filled, this.size = 76, this.stroke = 8, this.color = AppColors.brand, super.key});
  final int filled; final double size, stroke; final Color color;
  @override Widget build(BuildContext context) => SizedBox.square(dimension: size, child: CustomPaint(painter: _RingPainter(filled, stroke, color)));
}
class _RingPainter extends CustomPainter {
  const _RingPainter(this.filled, this.stroke, this.color);
  final int filled; final double stroke; final Color color;
  @override void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    const quarter = 3.14159265 * 2 / 4, gap = .22;
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.butt;
    for (var i = 0; i < 4; i++) {
      p.color = i < filled ? color : AppColors.track;
      canvas.drawArc(rect, -3.14159265 / 2 + i * quarter + gap / 2, quarter - gap, false, p);
    }
  }
  @override bool shouldRepaint(_RingPainter old) => old.filled != filled || old.color != color;
}
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {this.action, this.onAction, super.key});
  final String title; final String? action; final VoidCallback? onAction;
  @override Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(title, style: AppText.h2)),
    if (action != null) TextButton(onPressed: onAction, child: Text(action!, style: AppText.label.copyWith(color: AppColors.brand))),
  ]);
}
String relativeTime(DateTime time) {
  final delta = DateTime.now().difference(time);
  if (delta.inMinutes < 1) return 'now';
  if (delta.inHours < 1) return delta.inMinutes.toString() + 'm ago';
  if (delta.inDays < 1) return delta.inHours.toString() + 'h ago';
  if (delta.inDays < 7) return delta.inDays.toString() + 'd ago';
  return time.day.toString() + '/' + time.month.toString() + '/' + time.year.toString();
}
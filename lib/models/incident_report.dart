enum IncidentStatus { submitted, inProgress, resolved }

class IncidentReport {
  const IncidentReport({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterName,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final IncidentStatus status;
  final String reporterName;
  final DateTime createdAt;
}

const incidentCategories = [
  'Facilities',
  'Water',
  'Electricity',
  'Furniture',
  'Sanitation',
  'Safety',
  'Other',
];

String statusLabel(IncidentStatus status) => switch (status) {
  IncidentStatus.submitted => 'Submitted',
  IncidentStatus.inProgress => 'In progress',
  IncidentStatus.resolved => 'Resolved',
};

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
    this.photoPath,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final IncidentStatus status;
  final String reporterName;
  final DateTime createdAt;
  final String? photoPath;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'location': location,
    'status': status.name,
    'reporterName': reporterName,
    'createdAt': createdAt.toIso8601String(),
    'photoPath': photoPath,
  };

  factory IncidentReport.fromJson(Map<String, dynamic> json) => IncidentReport(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    category: json['category'] as String,
    location: json['location'] as String,
    status: IncidentStatus.values.firstWhere(
      (status) => status.name == json['status'],
      orElse: () => IncidentStatus.submitted,
    ),
    reporterName: json['reporterName'] as String? ?? 'Student',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    photoPath: json['photoPath'] as String?,
  );
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

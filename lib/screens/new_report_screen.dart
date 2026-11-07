import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident_report.dart';
import '../state/app_state.dart';

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});
  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  String _category = incidentCategories.first;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'New report',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          const Text(
            'Help us understand the issue',
            style: TextStyle(color: Color(0xFF727C94)),
          ),
          const SizedBox(height: 22),
          const _Label('Category'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in incidentCategories)
                ChoiceChip(
                  label: Text(category),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const _Label('Short title'),
          TextFormField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 70,
            decoration: const InputDecoration(
              hintText: 'e.g. Water leak in Block B',
            ),
            validator: (value) => value == null || value.trim().length < 5
                ? 'Add a clear title of at least 5 characters.'
                : null,
          ),
          const SizedBox(height: 13),
          const _Label('What happened?'),
          TextFormField(
            controller: _description,
            minLines: 4,
            maxLines: 6,
            maxLength: 800,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Describe the issue and its effect on campus.',
            ),
            validator: (value) => value == null || value.trim().length < 10
                ? 'Please add a little more detail.'
                : null,
          ),
          const SizedBox(height: 13),
          const _Label('Where is it?'),
          TextFormField(
            controller: _location,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.place_outlined),
              hintText: 'Building, room, or nearby landmark',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Add the issue location.'
                : null,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              'Photo attachments will be added in a later step.',
              style: TextStyle(color: Color(0xFF727C94)),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.send_rounded),
            label: const Text('Submit report'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6546E8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    ),
  );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AppState>().createReport(
      title: _title.text,
      description: _description.text,
      category: _category,
      location: _location.text,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report added to this local preview.')),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
  );
}

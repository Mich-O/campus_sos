import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  XFile? _photo;

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
          const _Label('Photo (optional)'),
          InkWell(
            onTap: _choosePhoto,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 145,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDDE1EB)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _photo == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Color(0xFF6546E8),
                          size: 28,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to choose a photo',
                          style: TextStyle(color: Color(0xFF727C94)),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(File(_photo!.path), fit: BoxFit.cover),
                    ),
            ),
          ),
          if (_photo != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _photo = null),
                icon: const Icon(Icons.close),
                label: const Text('Remove photo'),
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

  Future<void> _choosePhoto() async {
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 78,
        maxWidth: 1600,
      );
      if (photo == null || !mounted) return;
      if (await photo.length() > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Choose a photo smaller than 5 MB.')),
          );
        }
        return;
      }
      setState(() => _photo = photo);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the photo picker.')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<AppState>().createReport(
        title: _title.text,
        description: _description.text,
        category: _category,
        location: _location.text,
        photoPath: _photo?.path,
      );
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Report saved on this phone.')),
      );
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Could not save report: $error')),
        );
      }
    }
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

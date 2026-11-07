import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_theme.dart';
import '../models/incident_report.dart';
import '../state/providers.dart';

const campusLocations = [
  'Social Commons', 'Learning Commons', 'Enterprise Commons', 'Leadership Centre',
  'Library', 'Main Cafeteria', 'Outdoor areas', 'Other campus location',
];

class NewReportScreen extends ConsumerStatefulWidget {
  const NewReportScreen({super.key});
  @override ConsumerState<NewReportScreen> createState() => _NewReportScreenState();
}
class _NewReportScreenState extends ConsumerState<NewReportScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(), _description = TextEditingController();
  String? _category, _photoPath;
  String _location = campusLocations.first;
  bool _hideName = false;
  final _picker = ImagePicker();
  @override void dispose() { _title.dispose(); _description.dispose(); super.dispose(); }

  Future<void> _choosePhoto() async {
    try {
      final photo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 82, maxWidth: 1600);
      if (photo != null && mounted) setState(() => _photoPath = photo.path);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open your photo gallery.')));
    }
  }
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_category == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose a category to continue.'))); return; }
    try {
      await ref.read(createReportControllerProvider.notifier).submit(
        title: _title.text, description: _description.text, category: _category!,
        location: _location, hideName: _hideName, photoPath: _photoPath,
      );
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted.'))); Navigator.pop(context); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))));
    }
  }
  @override Widget build(BuildContext context) {
    final submitting = ref.watch(createReportControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: SafeArea(child: Form(key: _form, child: ListView(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 12, AppSpacing.screen, 28), children: [
        Text('Select a category', style: AppText.label),
        const SizedBox(height: 10),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.25,
          children: ReportCategory.values.where((c) => c != ReportCategory.other).map((category) {
            final selected = _category == category.value;
            return InkWell(onTap: () => setState(() => _category = category.value), borderRadius: BorderRadius.circular(AppRadius.card),
              child: Container(decoration: BoxDecoration(color: selected ? AppColors.brand : AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: selected ? AppColors.brand : AppColors.border)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(category.icon, color: selected ? Colors.white : AppColors.brand),
                  const SizedBox(height: 4), Text(category.label, style: AppText.secondary.copyWith(color: selected ? Colors.white : AppColors.ink, fontWeight: FontWeight.w700)),
                ]),
              ));
          }).toList()),
        const SizedBox(height: 18),
        Text('Title', style: AppText.label), const SizedBox(height: 6),
        TextFormField(controller: _title, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(hintText: 'Briefly describe the issue...'),
          validator: (v) => (v == null || v.trim().length < 4) ? 'Enter at least 4 characters.' : null),
        const SizedBox(height: 14),
        Text('Description', style: AppText.label), const SizedBox(height: 6),
        TextFormField(controller: _description, minLines: 4, maxLines: 6, textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'What happened, when, and who is affected?'),
          validator: (v) => (v == null || v.trim().length < 10) ? 'Add at least 10 characters of detail.' : null),
        const SizedBox(height: 14),
        Text('Location', style: AppText.label), const SizedBox(height: 6),
        DropdownButtonFormField<String>(isExpanded: true,
          value: _location, decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined)),
          items: campusLocations.map((value) => DropdownMenuItem(value: value, child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (value) { if (value != null) setState(() => _location = value); },
        ),
        const SizedBox(height: 16),
        Text('Add a photo (optional)', style: AppText.label), const SizedBox(height: 6),
        InkWell(onTap: _choosePhoto, borderRadius: BorderRadius.circular(18), child: Container(height: 104,
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border, width: 1.5)),
          child: _photoPath == null
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.add_photo_alternate_outlined, color: AppColors.brand), const SizedBox(height: 4), Text('Tap to add a photo', style: AppText.secondary)])
            : Stack(fit: StackFit.expand, children: [
                ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(_photoPath!), fit: BoxFit.cover)),
                Positioned(right: 6, top: 6, child: IconButton(tooltip: 'Remove photo', onPressed: () => setState(() => _photoPath = null),
                  style: IconButton.styleFrom(backgroundColor: Colors.white), icon: const Icon(Icons.close))),
              ]),
        )),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hide my name from students', style: AppText.bodyBold),
              Text('Staff can still see who reported.', style: AppText.secondary),
            ])),
            Switch(value: _hideName, onChanged: (value) => setState(() => _hideName = value), activeColor: AppColors.brand),
          ]),
        ),
        const SizedBox(height: 24),
        SizedBox(height: 56, child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.brand, shape: const StadiumBorder()),
          onPressed: submitting ? null : _submit,
          child: submitting ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Submit Report', style: AppText.button.copyWith(color: Colors.white)),
        )),
      ]))),
    );
  }
}
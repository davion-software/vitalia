import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitalia/core/app_log.dart';
import 'package:vitalia/core/copy.dart';
import 'package:vitalia/core/format.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/features/medications/presentation/medications_notifier.dart';
import 'package:vitalia/features/medications/presentation/widgets/color_picker.dart';
import 'package:vitalia/features/medications/presentation/widgets/shape_picker.dart';
import 'package:vitalia/features/medications/presentation/widgets/weekday_picker.dart';
import 'package:vitalia/theme/palette.dart';

final class MedicationEditorScreen extends ConsumerStatefulWidget {
  const MedicationEditorScreen({super.key, this.medicationId});

  final String? medicationId;

  @override
  ConsumerState<MedicationEditorScreen> createState() =>
      _MedicationEditorScreenState();
}

final class _MedicationEditorScreenState
    extends ConsumerState<MedicationEditorScreen> {
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _notes = TextEditingController();
  final _quantity = TextEditingController();
  final _threshold = TextEditingController();

  // Subscribed once in initState and closed in dispose.
  late final ProviderSubscription<MedicationsFeedback> _feedbackSubscription;
  // Subscribed once in initState and closed in dispose.
  late final ProviderSubscription<AsyncValue<MedicationsState>>
  _medicationsSubscription;

  PillShape _shape = PillShape.capsule;
  PillColor _color = PillColor.sage;
  List<int> _times = [8 * 60];
  Set<int> _days = {};
  bool _trackPills = false;
  String? _hydratedId;
  String? _timeError;

  bool get _isEditing => widget.medicationId != null;

  @override
  void initState() {
    super.initState();
    _tryHydrate(ref.read(medicationsNotifierProvider).value);
    _medicationsSubscription = ref.listenManual(medicationsNotifierProvider, (
      previous,
      next,
    ) {
      final wasHydrated = _hydratedId;
      _tryHydrate(next.value);
      if (_hydratedId != wasHydrated && mounted) setState(() {});
    });
    _feedbackSubscription = ref.listenManual(medicationsFeedbackProvider, (
      previous,
      next,
    ) {
      if (!mounted) return;
      if (next.shouldPop && previous?.shouldPop != true) {
        ref.read(medicationsFeedbackProvider.notifier).clear();
        GoRouter.of(context).pop();
        return;
      }
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(storageFailureMessage(failure))));
        ref.read(medicationsFeedbackProvider.notifier).clear();
      }
    });
  }

  @override
  void dispose() {
    _feedbackSubscription.close();
    _medicationsSubscription.close();
    _name.dispose();
    _dosage.dispose();
    _notes.dispose();
    _quantity.dispose();
    _threshold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing && _hydratedId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Form(
      child: Builder(
        builder: (formContext) => Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit medication' : 'Add medication'),
            actions: [
              TextButton(
                onPressed: () => _save(formContext),
                child: const Text('Save'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Give it a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dosage,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: '10 mg',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Add a dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'with breakfast',
                ),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text('Shape', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ShapePicker(
                shape: _shape,
                color: _color,
                onChanged: (value) => setState(() => _shape = value),
              ),
              const SizedBox(height: 20),
              Text('Color', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ColorPicker(
                color: _color,
                onChanged: (value) => setState(() => _color = value),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Times',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addTime,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add time'),
                  ),
                ],
              ),
              if (_timeError case final message?)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final minutes in _times)
                    InputChip(
                      label: Text(formatMinutes(minutes)),
                      onDeleted: _times.length == 1
                          ? null
                          : () => setState(() => _times.remove(minutes)),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Days', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                'None selected means every day.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              WeekdayPicker(
                days: _days,
                onToggle: (weekday) {
                  setState(() {
                    if (_days.contains(weekday)) {
                      _days.remove(weekday);
                    } else {
                      _days.add(weekday);
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Track remaining pills'),
                value: _trackPills,
                onChanged: (value) => setState(() => _trackPills = value),
              ),
              if (_trackPills) ...[
                TextFormField(
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Pill count'),
                  validator: _wholeNumberValidator('Add a count'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _threshold,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Refill when at or below',
                  ),
                  validator: _wholeNumberValidator('Add a refill threshold'),
                ),
              ],
              if (_isEditing) ...[
                const SizedBox(height: 32),
                TextButton(
                  onPressed: _delete,
                  style: TextButton.styleFrom(
                    foregroundColor: VitaliaPalette.terracotta,
                  ),
                  child: const Text('Delete medication'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  FormFieldValidator<String> _wholeNumberValidator(String emptyMessage) {
    return (value) {
      if (!_trackPills) return null;
      if (value == null || value.isEmpty) return emptyMessage;
      if (int.tryParse(value) == null) return 'Enter a whole number';
      return null;
    };
  }

  void _addTime() {
    unawaited(
      _pickTime().catchError(
        unexpectedLogger('vitalia.medications', 'medication_editor.intent'),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;
    if (!mounted) return;
    final minutes = picked.hour * 60 + picked.minute;
    setState(() {
      if (!_times.contains(minutes)) {
        _times = [..._times, minutes]..sort();
      }
      _timeError = null;
    });
  }

  void _save(BuildContext formContext) {
    final valid = Form.of(formContext).validate();
    if (_times.isEmpty) {
      setState(() => _timeError = 'Add at least one time');
      return;
    }
    if (!valid) return;
    final quantity = _trackPills ? int.tryParse(_quantity.text) : null;
    final threshold = _trackPills ? int.tryParse(_threshold.text) : null;
    if (_trackPills && (quantity == null || threshold == null)) return;
    final notifier = ref.read(medicationsNotifierProvider.notifier);
    final medicationId = widget.medicationId;
    final existing = medicationId == null
        ? null
        : ref
              .read(medicationsNotifierProvider)
              .value
              ?.medicationById(medicationId);
    notifier.save(
      Medication(
        id: existing?.id ?? notifier.createId(),
        name: _name.text.trim(),
        dosage: _dosage.text.trim(),
        notes: _notes.text.trim(),
        shape: _shape,
        color: _color,
        timesMinutes: [..._times]..sort(),
        daysOfWeek: (_days.toList()..sort()),
        quantity: quantity,
        refillThreshold: threshold,
      ),
    );
  }

  void _delete() {
    unawaited(
      _confirmDelete().catchError(
        unexpectedLogger('vitalia.medications', 'medication_editor.intent'),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final medicationId = widget.medicationId;
    if (medicationId == null) return;
    final existing = ref
        .read(medicationsNotifierProvider)
        .value
        ?.medicationById(medicationId);
    if (existing == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove from the cabinet?'),
          content: Text('${existing.name} will leave today\'s list.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: VitaliaPalette.terracotta,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    ref.read(medicationsNotifierProvider.notifier).delete(existing.id);
  }

  void _tryHydrate(MedicationsState? state) {
    final medicationId = widget.medicationId;
    if (medicationId == null || state == null || _hydratedId == medicationId) {
      return;
    }
    final existing = state.medicationById(medicationId);
    if (existing == null) return;
    _hydrate(existing);
  }

  void _hydrate(Medication existing) {
    _hydratedId = existing.id;
    _name.text = existing.name;
    _dosage.text = existing.dosage;
    _notes.text = existing.notes;
    _shape = existing.shape;
    _color = existing.color;
    _times = [...existing.timesMinutes]..sort();
    _days = {...existing.daysOfWeek};
    _trackPills = existing.tracksPills;
    _quantity.text = existing.quantity?.toString() ?? '';
    _threshold.text = existing.refillThreshold?.toString() ?? '';
  }
}

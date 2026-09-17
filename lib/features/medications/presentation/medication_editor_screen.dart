import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitalia/core/format.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/features/medications/presentation/medications_notifier.dart';
import 'package:vitalia/theme/palette.dart';
import 'package:vitalia/theme/widgets/pill_glyph.dart';

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

  PillShape _shape = PillShape.capsule;
  PillColor _color = PillColor.sage;
  List<int> _times = [8 * 60];
  Set<int> _days = {};
  bool _trackPills = false;
  String? _hydratedId;
  String? _timeError;

  bool get _isEditing => widget.medicationId != null;

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    _notes.dispose();
    _quantity.dispose();
    _threshold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medications = ref.watch(medicationsNotifierProvider);
    final existing = widget.medicationId == null
        ? null
        : medications.value?.medicationById(widget.medicationId ?? '');
    if (_isEditing && existing == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (existing != null && _hydratedId != existing.id) {
      _hydrate(existing);
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
              Row(
                children: [
                  for (final shape in PillShape.values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _Choice(
                          selected: _shape == shape,
                          onTap: () => setState(() => _shape = shape),
                          child: Column(
                            children: [
                              PillGlyph(shape: shape, color: _color, size: 36),
                              const SizedBox(height: 6),
                              Text(pillShapeName(shape)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Color', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final color in PillColor.values)
                    Semantics(
                      label: pillColorName(color),
                      button: true,
                      child: GestureDetector(
                        onTap: () => setState(() => _color = color),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorFor(color),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _color == color
                                  ? VitaliaPalette.ink
                                  : Colors.transparent,
                              width: 2.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
              Row(
                children: [
                  for (var weekday = 1; weekday <= 7; weekday++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _DayChip(
                          label: const [
                            'Mo',
                            'Tu',
                            'We',
                            'Th',
                            'Fr',
                            'Sa',
                            'Su',
                          ][weekday - 1],
                          selected: _days.contains(weekday),
                          onTap: () {
                            setState(() {
                              if (_days.contains(weekday)) {
                                _days.remove(weekday);
                              } else {
                                _days.add(weekday);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                ],
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
                  validator: (value) {
                    if (!_trackPills) return null;
                    if (value == null || value.isEmpty) {
                      return 'Add a count';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _threshold,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Refill when at or below',
                  ),
                  validator: (value) {
                    if (!_trackPills) return null;
                    if (value == null || value.isEmpty) {
                      return 'Add a refill threshold';
                    }
                    return null;
                  },
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

  void _addTime() {
    unawaited(_pickTime().catchError(_reportUnexpected));
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
    final notifier = ref.read(medicationsNotifierProvider.notifier);
    final existing = widget.medicationId == null
        ? null
        : ref
              .read(medicationsNotifierProvider)
              .value
              ?.medicationById(widget.medicationId ?? '');
    final router = GoRouter.of(context);
    final medication = Medication(
      id: existing?.id ?? notifier.createId(),
      name: _name.text.trim(),
      dosage: _dosage.text.trim(),
      notes: _notes.text.trim(),
      shape: _shape,
      color: _color,
      timesMinutes: [..._times]..sort(),
      daysOfWeek: (_days.toList()..sort()),
      quantity: _trackPills ? int.parse(_quantity.text) : null,
      refillThreshold: _trackPills ? int.parse(_threshold.text) : null,
    );
    notifier.save(medication, router.pop);
  }

  void _delete() {
    unawaited(_confirmDelete().catchError(_reportUnexpected));
  }

  Future<void> _confirmDelete() async {
    final existing = widget.medicationId == null
        ? null
        : ref
              .read(medicationsNotifierProvider)
              .value
              ?.medicationById(widget.medicationId ?? '');
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
    final router = GoRouter.of(context);
    ref
        .read(medicationsNotifierProvider.notifier)
        .delete(existing.id, router.pop);
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

  void _reportUnexpected(Object error, StackTrace stack) {
    developer.log(
      'medication_editor.intent',
      name: 'vitalia.medications',
      error: error,
      stackTrace: stack,
    );
  }
}

final class _Choice extends StatelessWidget {
  const _Choice({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? VitaliaPalette.sageMist : VitaliaPalette.paperDeep,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? VitaliaPalette.sage : VitaliaPalette.line,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: child,
        ),
      ),
    );
  }
}

final class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? VitaliaPalette.sage : VitaliaPalette.paperDeep,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? VitaliaPalette.paper : VitaliaPalette.ink,
          ),
        ),
      ),
    );
  }
}

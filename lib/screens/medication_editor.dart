import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../format.dart';
import '../models/models.dart';
import '../theme/palette.dart';
import '../widgets/pill_glyph.dart';
import '../widgets/vitalia_scope.dart';

class MedicationEditor extends StatefulWidget {
  const MedicationEditor({super.key, this.existing});

  final Medication? existing;

  @override
  State<MedicationEditor> createState() => _MedicationEditorState();
}

class _MedicationEditorState extends State<MedicationEditor> {
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _notes = TextEditingController();
  final _quantity = TextEditingController();
  final _threshold = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late PillShape _shape;
  late PillColor _color;
  late List<int> _times;
  late Set<int> _days;
  late bool _trackPills;
  String? _timeError;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing == null) {
      _shape = PillShape.capsule;
      _color = PillColor.sage;
      _times = [8 * 60];
      _days = {};
      _trackPills = false;
    } else {
      _name.text = existing.name;
      _dosage.text = existing.dosage;
      _notes.text = existing.notes;
      _shape = existing.shape;
      _color = existing.color;
      _times = [...existing.timesMinutes]..sort();
      _days = {...existing.daysOfWeek};
      _trackPills = existing.tracksPills;
      if (existing.quantity != null) {
        _quantity.text = '${existing.quantity}';
      }
      if (existing.refillThreshold != null) {
        _threshold.text = '${existing.refillThreshold}';
      }
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit medication' : 'Add medication'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
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
            if (_timeError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _timeError!,
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
    );
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    setState(() {
      if (!_times.contains(minutes)) {
        _times = [..._times, minutes]..sort();
      }
      _timeError = null;
    });
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (_times.isEmpty) {
      setState(() => _timeError = 'Add at least one time');
      return;
    }
    if (!valid) return;
    final store = VitaliaScope.of(context);
    final existing = widget.existing;
    final medication = Medication(
      id: existing?.id ?? store.newMedicationId(),
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
    await store.upsertMedication(medication);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final existing = widget.existing;
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
    await VitaliaScope.of(context).deleteMedication(existing.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class _Choice extends StatelessWidget {
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

class _DayChip extends StatelessWidget {
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

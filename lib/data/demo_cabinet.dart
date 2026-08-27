import '../models/models.dart';

List<Medication> demoCabinet() {
  return const [
    Medication(
      id: 'demo-vitamin-d3',
      name: 'Vitamin D3',
      dosage: '2000 IU',
      notes: 'with breakfast',
      shape: PillShape.capsule,
      color: PillColor.sand,
      timesMinutes: [8 * 60],
      daysOfWeek: [],
      quantity: 8,
      refillThreshold: 10,
    ),
    Medication(
      id: 'demo-omega-3',
      name: 'Omega-3',
      dosage: '1000 mg',
      notes: 'with breakfast',
      shape: PillShape.softgel,
      color: PillColor.moss,
      timesMinutes: [8 * 60],
      daysOfWeek: [],
      quantity: 40,
      refillThreshold: 10,
    ),
    Medication(
      id: 'demo-lisinopril',
      name: 'Lisinopril',
      dosage: '10 mg',
      notes: 'same times each day',
      shape: PillShape.tablet,
      color: PillColor.terracotta,
      timesMinutes: [8 * 60, 20 * 60],
      daysOfWeek: [],
      quantity: 20,
      refillThreshold: 6,
    ),
    Medication(
      id: 'demo-magnesium',
      name: 'Magnesium',
      dosage: '400 mg',
      notes: 'before bed',
      shape: PillShape.capsule,
      color: PillColor.slate,
      timesMinutes: [21 * 60],
      daysOfWeek: [],
      quantity: 30,
      refillThreshold: 8,
    ),
  ];
}

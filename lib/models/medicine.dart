class Medicine {
  final String medicineName;
  final String commonUse;
  final String dosage;
  final String? precautions;
  final String? sideEffects;

  Medicine({
    required this.medicineName,
    required this.commonUse,
    required this.dosage,
    this.precautions,
    this.sideEffects,
  });
}
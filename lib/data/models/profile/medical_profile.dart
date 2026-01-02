/// Medical profile model
class MedicalProfile {
  final List<String>? allergies;
  final List<String>? chronicConditions;
  final List<String>? currentMedications;
  final List<String>? pastSurgeries;
  final String? familyHistory;
  final bool? isSmoker;
  final bool? drinksAlcohol;
  final String? exerciseFrequency;
  final String? dietType;

  MedicalProfile({
    this.allergies,
    this.chronicConditions,
    this.currentMedications,
    this.pastSurgeries,
    this.familyHistory,
    this.isSmoker,
    this.drinksAlcohol,
    this.exerciseFrequency,
    this.dietType,
  });

  /// Create from JSON
  factory MedicalProfile.fromJson(Map<String, dynamic> json) {
    return MedicalProfile(
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'] as List)
          : null,
      chronicConditions: json['chronic_conditions'] != null
          ? List<String>.from(json['chronic_conditions'] as List)
          : null,
      currentMedications: json['current_medications'] != null
          ? List<String>.from(json['current_medications'] as List)
          : null,
      pastSurgeries: json['past_surgeries'] != null
          ? List<String>.from(json['past_surgeries'] as List)
          : null,
      familyHistory: json['family_history'] as String?,
      isSmoker: json['is_smoker'] as bool?,
      drinksAlcohol: json['drinks_alcohol'] as bool?,
      exerciseFrequency: json['exercise_frequency'] as String?,
      dietType: json['diet_type'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (allergies != null) 'allergies': allergies,
      if (chronicConditions != null) 'chronic_conditions': chronicConditions,
      if (currentMedications != null) 'current_medications': currentMedications,
      if (pastSurgeries != null) 'past_surgeries': pastSurgeries,
      if (familyHistory != null) 'family_history': familyHistory,
      if (isSmoker != null) 'is_smoker': isSmoker,
      if (drinksAlcohol != null) 'drinks_alcohol': drinksAlcohol,
      if (exerciseFrequency != null) 'exercise_frequency': exerciseFrequency,
      if (dietType != null) 'diet_type': dietType,
    };
  }

  /// Check if profile is complete
  bool get isComplete {
    return allergies != null &&
        chronicConditions != null &&
        currentMedications != null;
  }

  /// Copy with modified fields
  MedicalProfile copyWith({
    List<String>? allergies,
    List<String>? chronicConditions,
    List<String>? currentMedications,
    List<String>? pastSurgeries,
    String? familyHistory,
    bool? isSmoker,
    bool? drinksAlcohol,
    String? exerciseFrequency,
    String? dietType,
  }) {
    return MedicalProfile(
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      pastSurgeries: pastSurgeries ?? this.pastSurgeries,
      familyHistory: familyHistory ?? this.familyHistory,
      isSmoker: isSmoker ?? this.isSmoker,
      drinksAlcohol: drinksAlcohol ?? this.drinksAlcohol,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      dietType: dietType ?? this.dietType,
    );
  }
}
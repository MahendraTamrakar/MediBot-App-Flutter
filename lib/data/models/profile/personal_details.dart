/// Personal details model
class PersonalDetails {
  final String? fullName;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? bloodType;
  final String? phone;
  final String? address;

  PersonalDetails({
    this.fullName,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.bloodType,
    this.phone,
    this.address,
  });

  /// Create from JSON
  factory PersonalDetails.fromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      fullName: json['full_name'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      height: json['height'] as double?,
      weight: json['weight'] as double?,
      bloodType: json['blood_type'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'full_name': fullName,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (bloodType != null) 'blood_type': bloodType,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
    };
  }

  /// Calculate BMI
  double? get bmi {
    if (height != null && weight != null && height! > 0) {
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  /// Copy with modified fields
  PersonalDetails copyWith({
    String? fullName,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? bloodType,
    String? phone,
    String? address,
  }) {
    return PersonalDetails(
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bloodType: bloodType ?? this.bloodType,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
class SchoolModel {
  final String id;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String? phoneNumber;
  final String? email;
  final String? website;

  SchoolModel({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.phoneNumber,
    this.email,
    this.website,
  });

  // Create a copy with updated fields
  SchoolModel copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? phoneNumber,
    String? email,
    String? website,
  }) {
    return SchoolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
    };
  }

  // From JSON
  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pincode: json['pincode'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      website: json['website'],
    );
  }
}

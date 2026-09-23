import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String title; // Home, Work, etc.
  final String details;
  final String city;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.title,
    required this.details,
    required this.city,
    this.isDefault = false,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AddressModel(
      id: documentId,
      title: map['title'] ?? '',
      details: map['details'] ?? '',
      city: map['city'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'details': details,
      'city': city,
      'isDefault': isDefault,
    };
  }
}

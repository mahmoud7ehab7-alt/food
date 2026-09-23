import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double shipping;
  final double total;
  final String addressTitle;
  final String addressDetails;
  final String paymentMethod;
  final String orderStatus; // pending, processing, shipped, delivered, cancelled
  final String paymentStatus; // pending, paid, failed
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.addressTitle,
    required this.addressDetails,
    required this.paymentMethod,
    this.orderStatus = 'pending',
    this.paymentStatus = 'pending',
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      userId: map['userId'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      shipping: (map['shipping'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      addressTitle: map['addressTitle'] ?? '',
      addressDetails: map['addressDetails'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      orderStatus: map['orderStatus'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
      'subtotal': subtotal,
      'shipping': shipping,
      'total': total,
      'addressTitle': addressTitle,
      'addressDetails': addressDetails,
      'paymentMethod': paymentMethod,
      'orderStatus': orderStatus,
      'paymentStatus': paymentStatus,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

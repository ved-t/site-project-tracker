import 'package:flutter/material.dart';

class ExpenseCategoryEntity {
  final String id;
  final String siteId;
  final String name;
  final IconData icon;
  final Color color;
  final DateTime createdAt;

  ExpenseCategoryEntity({
    required this.id,
    required this.siteId,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdAt,
  });
}

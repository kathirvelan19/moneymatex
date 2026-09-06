import 'package:flutter/material.dart';

/// Transaction Item entity used across Transactions and Dashboard screens
class TransactionItem {
  final String id;
  final String title;
  final String category;
  final double amount;
  final String wallet;
  final String paymentMethod;
  final DateTime date;
  final String? notes;
  final bool isExpense;
  final IconData icon;
  final List<String>? items;
  final String? receiptPath;
  final String source; // 'manual', 'ocr', 'automatic_tracking'
  final double? ocrConfidence;
  final bool needsConfirmation;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.wallet,
    required this.paymentMethod,
    required this.date,
    this.notes,
    this.isExpense = true,
    required this.icon,
    this.items,
    this.receiptPath,
    this.source = 'manual',
    this.ocrConfidence,
    this.needsConfirmation = false,
  });


  /// Formatted string representation for amount (e.g. ₹450)
  String get formattedAmount {
    final intVal = amount.toInt();
    final formatted = intVal.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '₹$formatted';
  }

  /// Formatted date string (e.g. 12 Aug 2026)
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Formatted timestamp string (e.g. 04:15 PM)
  String get formattedTime {
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }
}

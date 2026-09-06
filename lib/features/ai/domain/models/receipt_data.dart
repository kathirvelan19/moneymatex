/// Single item line extracted from a receipt
class ReceiptItem {
  final String name;
  final double? quantity;
  final double? price;
  final double? totalPrice;

  const ReceiptItem({
    required this.name,
    this.quantity,
    this.price,
    this.totalPrice,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: (json['name'] ?? '').toString().trim(),
      quantity: (json['quantity'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }
}

/// Structured receipt extraction data container
class ReceiptData {
  final String? merchantName;
  final DateTime? date;
  final String? dateString;
  final double? totalAmount;
  final double? taxAmount;
  final String? currency;
  final double? subtotal;
  final double? discount;
  final String? receiptNumber;
  final String? paymentMethod;
  final List<ReceiptItem> items;
  final String suggestedCategory;
  final String rawJsonText;
  final bool isSuccess;
  final String? errorMessage;
  final String? imageDataUrl;

  const ReceiptData({
    this.merchantName,
    this.date,
    this.dateString,
    this.totalAmount,
    this.taxAmount,
    this.currency = 'INR',
    this.subtotal,
    this.discount,
    this.receiptNumber,
    this.paymentMethod,
    this.items = const [],
    this.suggestedCategory = 'Uncategorized',
    this.rawJsonText = '',
    this.isSuccess = true,
    this.errorMessage,
    this.imageDataUrl,
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json, {String rawText = '', String? imageDataUrl}) {
    // Merchant Name
    final rawMerchant = json['merchantName'] ?? json['merchant'];
    final merchant = rawMerchant != null && rawMerchant.toString().trim().isNotEmpty && rawMerchant.toString().toLowerCase() != 'null'
        ? rawMerchant.toString().trim()
        : null;

    // Amounts
    final total = _parseAmount(json['totalAmount'] ?? json['amount']);
    final tax = _parseAmount(json['taxAmount'] ?? json['tax']);
    final sub = _parseAmount(json['subtotal']);
    final disc = _parseAmount(json['discount']);

    // Date
    final rawDate = (json['date'] ?? '').toString().trim();
    DateTime? parsedDate;
    String? formattedDateStr;
    if (rawDate.isNotEmpty && rawDate != 'null') {
      parsedDate = DateTime.tryParse(rawDate);
      formattedDateStr = rawDate;
    }

    // Currency
    final curr = json['currency']?.toString().trim() ?? 'INR';

    // Receipt Number
    final rawReceiptNo = json['receiptNumber'] ?? json['ticket_no'];
    final receiptNo = rawReceiptNo != null && rawReceiptNo.toString().trim().isNotEmpty && rawReceiptNo.toString().toLowerCase() != 'null'
        ? rawReceiptNo.toString().trim()
        : null;

    // Payment Method
    final rawPayMethod = json['paymentMethod'] ?? json['payment_method'];
    final payMethod = rawPayMethod != null && rawPayMethod.toString().trim().isNotEmpty && rawPayMethod.toString().toLowerCase() != 'null'
        ? rawPayMethod.toString().trim()
        : null;

    // Items
    final List<ReceiptItem> extractedItems = [];
    if (json['items'] is List) {
      for (final itemJson in json['items']) {
        if (itemJson is Map<String, dynamic>) {
          extractedItems.add(ReceiptItem.fromJson(itemJson));
        }
      }
    }

    // Category suggestion if provided by Gemini
    final category = (json['category'] ?? json['suggestedCategory'] ?? 'Uncategorized').toString().trim();

    return ReceiptData(
      merchantName: merchant,
      date: parsedDate,
      dateString: formattedDateStr,
      totalAmount: total,
      taxAmount: tax,
      currency: curr,
      subtotal: sub,
      discount: disc,
      receiptNumber: receiptNo,
      paymentMethod: payMethod,
      items: extractedItems,
      suggestedCategory: category,
      rawJsonText: rawText,
      isSuccess: true,
      imageDataUrl: imageDataUrl,
    );
  }

  factory ReceiptData.error(String message, {String? imageDataUrl}) {
    return ReceiptData(
      isSuccess: false,
      errorMessage: message,
      imageDataUrl: imageDataUrl,
    );
  }

  static double? _parseAmount(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    final str = val.toString().replaceAll('₹', '').replaceAll('\$', '').replaceAll(',', '').trim();
    if (str.isEmpty || str.toLowerCase() == 'null') return null;
    return double.tryParse(str);
  }

  Map<String, dynamic> toJson() {
    return {
      'merchantName': merchantName,
      'date': dateString ?? date?.toIso8601String(),
      'totalAmount': totalAmount,
      'taxAmount': taxAmount,
      'currency': currency,
      'subtotal': subtotal,
      'discount': discount,
      'receiptNumber': receiptNumber,
      'paymentMethod': paymentMethod,
      'items': items.map((i) => i.toJson()).toList(),
      'suggestedCategory': suggestedCategory,
    };
  }
}

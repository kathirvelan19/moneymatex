/// Structured UPI screenshot extraction data container
class ScannedUPI {
  final double? paidAmount;
  final String? receiverName;
  final DateTime? dateTime;
  final String? dateTimeString;
  final String? transactionId;
  final String suggestedCategory;
  final String rawJsonText;
  final bool isSuccess;
  final String? errorMessage;
  final String? imageDataUrl;

  const ScannedUPI({
    this.paidAmount,
    this.receiverName,
    this.dateTime,
    this.dateTimeString,
    this.transactionId,
    this.suggestedCategory = 'Uncategorized',
    this.rawJsonText = '',
    this.isSuccess = true,
    this.errorMessage,
    this.imageDataUrl,
  });

  factory ScannedUPI.fromJson(Map<String, dynamic> json, {String rawText = '', String? imageDataUrl}) {
    // Amount
    final rawAmount = json['paidAmount'] ?? json['amount'];
    final amount = _parseAmount(rawAmount);

    // Receiver Name
    final rawReceiver = json['receiverName'] ?? json['receiver'] ?? json['merchantName'] ?? json['merchant'];
    final receiver = rawReceiver != null && rawReceiver.toString().trim().isNotEmpty && rawReceiver.toString().toLowerCase() != 'null'
        ? rawReceiver.toString().trim()
        : null;

    // Date Time
    final rawDateTime = (json['dateTime'] ?? json['date'] ?? '').toString().trim();
    DateTime? parsedDate;
    String? formattedDateStr;
    if (rawDateTime.isNotEmpty && rawDateTime != 'null') {
      parsedDate = DateTime.tryParse(rawDateTime);
      formattedDateStr = rawDateTime;
    }

    // Transaction ID
    final rawTxId = json['transactionId'] ?? json['txnId'] ?? json['upiRefNo'];
    final txId = rawTxId != null && rawTxId.toString().trim().isNotEmpty && rawTxId.toString().toLowerCase() != 'null'
        ? rawTxId.toString().trim()
        : null;

    // Category
    final category = (json['category'] ?? json['suggestedCategory'] ?? 'Uncategorized').toString().trim();

    return ScannedUPI(
      paidAmount: amount,
      receiverName: receiver,
      dateTime: parsedDate,
      dateTimeString: formattedDateStr,
      transactionId: txId,
      suggestedCategory: category,
      rawJsonText: rawText,
      isSuccess: true,
      imageDataUrl: imageDataUrl,
    );
  }

  factory ScannedUPI.error(String message, {String? imageDataUrl}) {
    return ScannedUPI(
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
      'paidAmount': paidAmount,
      'receiverName': receiverName,
      'dateTime': dateTimeString ?? dateTime?.toIso8601String(),
      'transactionId': transactionId,
      'suggestedCategory': suggestedCategory,
    };
  }
}

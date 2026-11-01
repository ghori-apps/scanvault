/// Types of data encoded inside QR codes and barcodes.
enum CodeContentType {
  url,
  wifi,
  contact,
  email,
  sms,
  phone,
  geo,
  calendar,
  product,
  isbn,
  text,
  unknown;

  String get label {
    switch (this) {
      case CodeContentType.url:
        return 'Website Link';
      case CodeContentType.wifi:
        return 'Wi-Fi Network';
      case CodeContentType.contact:
        return 'Contact (vCard)';
      case CodeContentType.email:
        return 'Email';
      case CodeContentType.sms:
        return 'SMS Message';
      case CodeContentType.phone:
        return 'Phone Number';
      case CodeContentType.geo:
        return 'Location';
      case CodeContentType.calendar:
        return 'Calendar Event';
      case CodeContentType.product:
        return 'Product Barcode';
      case CodeContentType.isbn:
        return 'Book ISBN';
      case CodeContentType.text:
        return 'Plain Text';
      case CodeContentType.unknown:
        return 'Code Data';
    }
  }
}

enum ScanSource {
  camera,
  gallery,
  batch,
}

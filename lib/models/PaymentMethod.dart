class PaymentMethod {
  final String name;

  const PaymentMethod._(this.name);

  static const PaymentMethod CASH = PaymentMethod._('Cash');
  static const PaymentMethod ONLINE = PaymentMethod._('Card/UPI');
}
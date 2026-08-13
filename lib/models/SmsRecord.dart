/// Local SMS record model — decouples from telephony plugin types.
/// Allows unit testing without Android platform.
class SmsRecord {
  final String id;
  final String? sender;
  final String body;
  final DateTime date;

  const SmsRecord({
    required this.id,
    required this.sender,
    required this.body,
    required this.date,
  });
}

class Message {
  final String id;
  final String text;
  final String senderName;
  final bool isFromAdmin;
  final String timestamp;

  Message({
    required this.id,
    required this.text,
    required this.senderName,
    required this.isFromAdmin,
    required this.timestamp,
  });

  factory Message.create({
    required String text,
    required String senderName,
    bool isFromAdmin = false,
  }) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      senderName: senderName,
      isFromAdmin: isFromAdmin,
      timestamp: DateTime.now().toString(),
    );
  }
}

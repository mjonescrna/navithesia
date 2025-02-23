import '../models/message.dart';

class MessagingService {
  final List<Message> _messages = [];

  Future<List<Message>> getMessages() async {
    // In a real app, this would fetch from an API
    return _messages;
  }

  Future<void> sendMessage(String text) async {
    // In a real app, this would send to an API
    _messages.add(
      Message.create(text: text, senderName: 'User', isFromAdmin: false),
    );
  }
}

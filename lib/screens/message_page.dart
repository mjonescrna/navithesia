import 'package:flutter/cupertino.dart';
import '../models/message.dart';
import '../services/messaging_service.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final messages = await _messagingService.getMessages();
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Failed to load messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await _messagingService.sendMessage(text);
      _messageController.clear();
      await _loadMessages();
    } catch (e) {
      _showError('Failed to send message: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  Widget _buildMessageTile(Message message) {
    final isFromAdmin = message.isFromAdmin;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isFromAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isFromAdmin
                      ? CupertinoColors.systemGrey6.withOpacity(0.1)
                      : CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFromAdmin)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        color: CupertinoColors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Text(
                  message.text,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.timestamp,
                  style: TextStyle(
                    color: CupertinoColors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: Text(
          'Messages',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CupertinoActivityIndicator())
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        reverse: true,
                        itemCount: _messages.length,
                        itemBuilder:
                            (context, index) =>
                                _buildMessageTile(_messages[index]),
                      ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.withOpacity(0.1),
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey4.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _messageController,
                      placeholder: 'Type a message...',
                      style: const TextStyle(color: CupertinoColors.white),
                      placeholderStyle: TextStyle(
                        color: CupertinoColors.systemGrey.withOpacity(0.7),
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _isSending ? null : _sendMessage,
                    child:
                        _isSending
                            ? const CupertinoActivityIndicator()
                            : const Icon(
                              CupertinoIcons.arrow_up_circle_fill,
                              color: CupertinoColors.systemBlue,
                              size: 32,
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

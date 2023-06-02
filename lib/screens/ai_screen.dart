import 'package:flutter/material.dart';

import '../services/chat_bot_service.dart';

import '../widgets/message_bubble.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _messageController = TextEditingController();
  var messages = [];
  var replies = [];

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    ChatBot.askAi(enteredMessage);

    messages.add(enteredMessage);

    replies.add(await ChatBot.askAi(enteredMessage));

    FocusScope.of(context).unfocus();
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talk to AI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 40,
                  left: 13,
                  right: 13,
                ),
                itemCount: messages.length + replies.length,
                itemBuilder: (ctx, index) {
                  final chatMessageIndex = index ~/
                      2; // Divide index by 2 to get the corresponding chat message index

                  if (index % 2 == 0) {
                    // Even indices represent chat messages
                    final chatMessage = messages[chatMessageIndex];
                    return MessageBubble.next(
                      message: chatMessage,
                      isMe: true,
                    );
                  } else {
                    // Odd indices represent replies
                    final replyIndex = index ~/ 2;
                    final replyMessage = replies[replyIndex];
                    return MessageBubble.next(
                      message: replyMessage,
                      isMe: false,
                    );
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 14),
            child: Row(
              children: [
                const SizedBox(width: 5),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 30, 30, 36),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            cursorColor: const Color.fromARGB(255, 0, 122, 204),
                            textCapitalization: TextCapitalization.sentences,
                            autocorrect: true,
                            enableSuggestions: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              border: InputBorder.none,
                              hintText: 'Send a message...',
                              hintStyle: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Material(
                  color: const Color.fromARGB(255, 0, 122, 204),
                  shape: const CircleBorder(),
                  child: IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.send),
                      onPressed: _submitMessage),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

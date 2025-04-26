import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final String? avatarUrl;
  ChatMessage({required this.text, required this.isMe, required this.time, this.avatarUrl});
}

class GeminiChatPage extends StatefulWidget {
  const GeminiChatPage({super.key});
  @override
  State<GeminiChatPage> createState() => _GeminiChatPageState();
}

class _GeminiChatPageState extends State<GeminiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add initial messages
    messages.add(
      ChatMessage(
        text: "Are you coming?",
        isMe: true,
        time: "8:10 pm",
        avatarUrl: null,
      ),
    );
    messages.add(
      ChatMessage(
        text: "Hey, Congratulation for order",
        isMe: false,
        time: "8:11 pm",
        avatarUrl: "https://i.pravatar.cc/150?img=1",
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(
        text: text,
        isMe: true,
        time: TimeOfDay.now().format(context),
        avatarUrl: null,
      ));
      _controller.clear();
      _isTyping = true;
    });

    // Simulate AI response after a delay
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      messages.add(ChatMessage(
        text: "I'm Coming, just wait ...",
        isMe: false,
        time: TimeOfDay.now().format(context),
        avatarUrl: "https://i.pravatar.cc/150?img=1",
      ));
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=1"),
            ),
            const SizedBox(width: 8),
            const Text(
              'Robert Fox',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.isMe;
                return Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        msg.time,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: isMe ? TextAlign.right : TextAlign.left
                      ),
                    ),
                    Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe)
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: msg.avatarUrl != null ? NetworkImage(msg.avatarUrl!) : null,
                            child: msg.avatarUrl == null ? const Icon(Icons.person, color: Colors.deepPurple) : null,
                          ),
                        if (!isMe) const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFFFFA726) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: Radius.circular(isMe ? 18 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 18),
                              ),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        if (isMe) const SizedBox(width: 8),
                        if (isMe)
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.deepPurple.shade100,
                            child: const Icon(Icons.person, color: Colors.deepPurple),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=1"),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Row(
                            children: [
                              _TypingDot(),
                              _TypingDot(delay: 0.3),
                              _TypingDot(delay: 0.5),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_controller.text),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA726),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatelessWidget {
  final double delay;
  const _TypingDot({this.delay = 0.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
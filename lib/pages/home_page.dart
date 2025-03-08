// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_card.dart';
import '../widgets/chat_input.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade100,
        centerTitle: true,
        title: const Text('JoGem'),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Column(
            children: [
              Expanded(
                child:
                    chatProvider.messages.isEmpty
                        ? const Center(
                          child: Text('Write something to start...'),
                        )
                        : ListView.builder(
                          itemCount: chatProvider.messages.length,
                          itemBuilder: (context, index) {
                            final message = chatProvider.messages[index];
                            return MessageCard(
                              text: message.text,
                              isUser: message.isUser,
                              responseStreamController:
                                  message.responseStreamController,
                            );
                          },
                        ),
              ),
              ChatInput(onSend: (text) => chatProvider.sendMessage(text)),
            ],
          );
        },
      ),
    );
  }
}

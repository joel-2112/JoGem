// lib/models/message.dart
import 'dart:async';

class Message {
  final String text;
  final bool isUser; // True if from user, false if from AI
  final StreamController<String>? responseStreamController; // For streaming AI responses

  Message({
    required this.text,
    required this.isUser,
    this.responseStreamController,
  });
}
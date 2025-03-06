// lib/models/message.dart
class Message {
  final String text;
  final bool isUser; // True if from user, false if from AI

  Message({required this.text, required this.isUser});
}
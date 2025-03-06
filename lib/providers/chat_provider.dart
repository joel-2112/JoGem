// lib/providers/chat_provider.dart
import 'package:flutter/material.dart';
import 'package:jogem/models/chat_model.dart';
import 'package:jogem/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String prompt) async {
    _messages.add(Message(text: prompt, isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getGeminiResponse(prompt);
      _messages.add(Message(text: response, isUser: false));
    } catch (e) {
      _messages.add(Message(text: 'Error: $e', isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// lib/providers/chat_provider.dart

import 'package:flutter/material.dart';
import 'package:jogem/models/chat_model.dart';

import 'dart:async';

import 'package:jogem/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Message> _messages = [];
  bool _isLoading = false;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String prompt) async {
    // Add user message
    _messages.add(Message(text: prompt, isUser: true));
    notifyListeners();

    // Prepare for AI response with a StreamController
    final responseController = StreamController<String>.broadcast();
    _messages.add(Message(
      text: '',
      isUser: false,
      responseStreamController: responseController,
    ));
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch response from Gemini API via ApiService
      final response = await _apiService.getGeminiResponse(prompt);
      // Stream the response character by character for live effect
      for (int i = 0; i < response.length; i++) {
        await Future.delayed(const Duration(milliseconds: 30)); // Simulate streaming
        final chunk = response.substring(0, i + 1);
        responseController.add(chunk);
        _messages.last = Message(
          text: chunk,
          isUser: false,
          responseStreamController: responseController,
        );
        notifyListeners();
      }
      responseController.close();
    } catch (e) {
      final errorMessage = 'Error: $e';
      responseController.add(errorMessage);
      _messages.last = Message(
        text: errorMessage,
        isUser: false,
        responseStreamController: responseController,
      );
      notifyListeners();
      responseController.close();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
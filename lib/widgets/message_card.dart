// lib/widgets/message_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart'; // For code highlighting
import 'package:flutter_highlighter/themes/monokai-sublime.dart'; // Example theme

class MessageCard extends StatelessWidget {
  final String text;
  final bool isUser;

  const MessageCard({required this.text, required this.isUser, super.key});

  // Function to clean up unnecessary characters and detect code
  (String, bool) _processText(String rawText) {
    // Check if the text is a code block (wrapped in ```)
    if (rawText.trim().startsWith('```') && rawText.trim().endsWith('```')) {
      // Extract code content and remove the backticks
      String code =
          rawText.trim().substring(3, rawText.trim().length - 3).trim();
      // Optionally, remove language identifier (e.g., ```dart -> dart)
      if (code.contains('\n')) {
        code = code.split('\n').skip(1).join('\n');
      }
      return (code, true);
    }
    // Clean up regular text (remove asterisks, extra newlines, etc.)
    String cleanedText =
        rawText
            .replaceAll(
              RegExp(r'[\*#_]+'),
              '',
            ) // Remove Markdown-like characters
            .replaceAll(RegExp(r'\n\s*\n'), '\n') // Remove excessive newlines
            .trim();
    return (cleanedText, false);
  }

  @override
  Widget build(BuildContext context) {
    final (processedText, isCode) = _processText(text);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isUser ? Colors.blue : Colors.grey.shade100,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child:
            isCode
                ? _buildCodeBlock(processedText)
                : _buildNormalText(processedText),
      ),
    );
  }

  // Widget for normal text
  Widget _buildNormalText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: isUser ? Colors.blue : Colors.black87,
      ),
    );
  }

  // Widget for code block with syntax highlighting
  Widget _buildCodeBlock(String code) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: HighlightView(
        code,
        language:
            'plaintext', // Default; can be dynamic if language is specified
        theme: monokaiSublimeTheme, // Use Monokai theme for a colored code look
        padding: const EdgeInsets.all(8.0),
        textStyle: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
      ),
    );
  }
}

// lib/widgets/message_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter/services.dart';
import 'package:highlight/languages/all.dart' as highlight;
import 'package:share_plus/share_plus.dart';
import 'dart:async';

/// Enhanced MessageCard with Markdown, VS Code-themed code editor, and live response
class MessageCard extends StatelessWidget {
  final String text;
  final bool isUser;
  final StreamController<String>? responseStreamController; // Made nullable

  const MessageCard({
    required this.text,
    required this.isUser,
    this.responseStreamController, // Optional for user messages
    super.key,
  });

  /// Processes raw text to detect code blocks and clean regular text
  (String, bool, String) _processText(String rawText) {
    final trimmedText = rawText.trim();

    if (trimmedText.startsWith('```') && trimmedText.endsWith('```')) {
      final content = trimmedText.substring(3, trimmedText.length - 3).trim();
      final lines = content.split('\n');

      String language = '';
      String code = content;

      if (lines.isNotEmpty && lines.first.isNotEmpty && !lines.first.contains(RegExp(r'[^\w]'))) {
        language = lines.first.toLowerCase();
        code = lines.sublist(1).join('\n').trim();
      }

      return (code, true, language);
    }

    return (rawText, false, '');
  }

  @override
  Widget build(BuildContext context) {
    // Use StreamBuilder only for non-user messages with a stream controller
    if (!isUser && responseStreamController != null) {
      return StreamBuilder<String>(
        stream: responseStreamController!.stream,
        initialData: text, // Show initial text until stream updates
        builder: (context, snapshot) {
          final (processedText, isCode, language) = _processText(snapshot.data ?? '');
          return _buildCard(context, processedText, isCode, language);
        },
      );
    } else {
      // For user messages or no stream, use static text
      final (processedText, isCode, language) = _processText(text);
      return _buildCard(context, processedText, isCode, language);
    }
  }

  Widget _buildCard(BuildContext context, String processedText, bool isCode, String language) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue.withAlpha(38) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUser ? Colors.blue.withAlpha(102) : Colors.grey.shade200,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: isCode
                ? _buildEnhancedCodeEditor(context, processedText, language)
                : _buildMarkdownText(context, processedText),
          ),
        ),
      ),
    );
  }

  Widget _buildMarkdownText(BuildContext context, String text) {
    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          fontSize: 16.5,
          color: isUser ? Colors.blue.shade900 : Colors.black87,
          fontFamily: 'Inter',
          height: 1.5,
          letterSpacing: 0.4,
        ),
        code: TextStyle(
          fontSize: 14.5,
          fontFamily: 'JetBrains Mono',
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w500,
        ),
        h1: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        h2: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
        h3: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        blockquote: TextStyle(
          fontSize: 16,
          color: const Color.fromARGB(255, 240, 237, 237),
          fontStyle: FontStyle.italic,
          backgroundColor: Colors.grey.shade50,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: Colors.blueGrey, width: 4)),
        ),
        tableBorder: TableBorder.all(color: Colors.grey.shade300, width: 1),
        tableCellsPadding: const EdgeInsets.all(8),
        tableHeadAlign: TextAlign.center,
        listBullet: TextStyle(
          color: isUser ? Colors.blue.shade900 : Colors.black87,
        ),
      ),
      selectable: true,
      onTapLink: (text, href, title) {
        if (href != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening link: $href')),
          );
        }
      },
    );
  }

  Widget _buildEnhancedCodeEditor(
    BuildContext context,
    String code,
    String language,
  ) {
    final codeController = CodeController(
      text: code,
      language: highlight.allLanguages[language] ?? highlight.allLanguages['plaintext'],
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Pure black VS Code background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3C3C3C), // Subtle grey border
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with language and actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF252526), // VS Code header bar color
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language.isNotEmpty ? language.toUpperCase() : 'TEXT',
                  style: const TextStyle(
                    color: Color(0xFF9CDCFE), // VS Code blue for language
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.copy,
                      tooltip: 'Copy code',
                      iconColor: const Color(0xFF4EC9B0), // Teal for copy
                      backgroundColor: const Color(0xFF2D2D2D), // Darker button bg
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copied!')),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.share,
                      tooltip: 'Share code',
                      iconColor: const Color(0xFFFFC107), // Yellow for share
                      backgroundColor: const Color(0xFF2D2D2D), // Darker button bg
                      onTap: () => Share.share(code),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Code display
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: const Color(0xFF1E1E1E), // Solid black background
              child: CodeField(
                controller: codeController,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'JetBrains Mono',
                  color: Color(0xFFD4D4D4), // VS Code light grey for text
                  height: 1.4,
                ),
                background: const Color(0xFF1E1E1E), // Consistent black
                gutterStyle: GutterStyle(
                  textStyle: TextStyle(
                    color: const Color(0xFF858585), // VS Code gutter grey
                  ),
                ),
                readOnly: true,
                decoration: const BoxDecoration(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) 
  {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor, // Custom background for visibility
        borderRadius: BorderRadius.circular(6),
        elevation: 2, // Slight elevation for depth
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Increased padding
            child: Icon(
              icon,
              size: 22, // Larger icons for visibility
              color: iconColor, // Vibrant icon colors
            ),
          ),
        ),
      ),
    );
  }
}
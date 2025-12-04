import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'article_detail.dart'; 

class MentalHealthChatScreen extends StatefulWidget {
  const MentalHealthChatScreen({Key? key}) : super(key: key);

  @override
  State<MentalHealthChatScreen> createState() => _MentalHealthChatScreenState();
}

class _MentalHealthChatScreenState extends State<MentalHealthChatScreen> {
  // Same API Key
  static const _apiKey = 'AIzaSyD47dVtPaOMmOMxiJIk8N0-f0UkoOCydNU';
  
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  List<DocumentSnapshot> _articles = [];
  bool _isLoading = true; 
  bool _isSending = false;

  // Mental Health Specific Suggestions
  final List<String> _suggestions = [
    "I feel anxious",
    "How to manage stress?",
    "I'm having a panic attack",
    "Trouble sleeping"
  ];

  @override
  void initState() {
    super.initState();
    _initializeRAG();
  }

  Future<void> _initializeRAG() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('articles').get();
      _articles = querySnapshot.docs;

      StringBuffer knowledgeBase = StringBuffer();
      knowledgeBase.writeln("Here is your EXCLUSIVE medical knowledge base:");

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final title = data['title'] ?? 'No Title';
        final content = data['content'] ?? 'No Content';
        knowledgeBase.writeln("--- ARTICLE (ID: ${doc.id}) ---\nTitle: $title\nContent: $content\n");
      }

      // --- MENTAL HEALTH PERSONA ---
      final systemPrompt = """
        You are 'Serena', an empathetic and supportive mental health companion for the 'TeenHealth' app.
        
        RULES:
        1. Your primary goal is to LISTEN and VALIDATE feelings.
        2. Use a warm, gentle, and non-judgmental tone.
        3. Do NOT provide medical diagnoses.
        4. SAFETY CRITICAL: If the user mentions self-harm, suicide, or severe distress, IMMEDIATELY provide this helpline: 'Kiran Helpline: 1800-599-0019' and urge them to seek professional help.
        5. Use the Knowledge Base for coping strategies if available, but prioritize empathy over facts.
        
        CITATION RULE:
        If you use an article, add a link at the end: `\n\n[👉 Read: Article Title](article:DOC_ID)`
        $knowledgeBase
      """;

      _model = GenerativeModel(
        model: 'gemini-2.5-flash', 
        apiKey: _apiKey,
        systemInstruction: Content.system(systemPrompt),
      );
      
      _chat = _model.startChat();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.add(ChatMessage(
            text: "Hi, I'm Serena. I'm here to listen and support you. How are you feeling today?",
            isUser: false,
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.add(ChatMessage(text: "Error: $e", isUser: false, isError: true));
        });
      }
    }
  }

  Future<void> _sendMessage({String? text}) async {
    final message = text ?? _textController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _isSending = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final responseText = response.text;

      if (responseText != null) {
        setState(() {
          _messages.add(ChatMessage(text: responseText, isUser: false));
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Error: $e", isUser: false, isError: true));
        _isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleLinkTap(String? href) {
    if (href == null) return;
    if (href.startsWith('article:')) {
      final String docId = href.replaceFirst('article:', '');
      try {
        final doc = _articles.firstWhere((d) => d.id == docId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              articleData: doc.data() as Map<String, dynamic>,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Article not found.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- THEME CONSTANTS (UPDATED) ---
    const backgroundColor = Color(0xFF001219); // Deep dark teal/blue
    const surfaceColor = Color(0xFF003545);    // Dark teal surface
    const accentColor = Color(0xFF64FFDA);     // Soft Teal for Mental Health (Calming)

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Serena AI", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Mental Health Companion", style: GoogleFonts.poppins(color: accentColor, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length + (_isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isSending && index == _messages.length) {
                  return _buildTypingIndicator(surfaceColor, accentColor);
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg, surfaceColor, accentColor);
              },
            ),
          ),

          // Quick Suggestion Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 10),
                  child: ActionChip(
                    label: Text(_suggestions[index]),
                    labelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                    backgroundColor: surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: accentColor.withOpacity(0.5)),
                    ),
                    onPressed: () => _sendMessage(text: _suggestions[index]),
                  ),
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: backgroundColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Share your feelings...",
                        hintStyle: GoogleFonts.poppins(color: Colors.white38),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: accentColor,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward, color: backgroundColor), // Dark icon on bright accent
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, Color surfaceColor, Color accentColor) {
    final isUser = msg.isUser;
    
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutQuart,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)), 
            child: child,
          ),
        );
      },
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            color: isUser ? accentColor : surfaceColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
              bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isUser 
            ? Text(msg.text, style: GoogleFonts.poppins(color: const Color(0xFF001219), fontWeight: FontWeight.w500, fontSize: 14)) // Dark text on accent bubble
            : MarkdownBody(
                data: msg.text,
                onTapLink: (text, href, title) => _handleLinkTap(href),
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14),
                  strong: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                  a: GoogleFonts.poppins(color: accentColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline), // Link matches accent
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(Color surfaceColor, Color accentColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Opacity(opacity: value, child: child);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(accentColor),
              const SizedBox(width: 4),
              _buildDot(accentColor),
              const SizedBox(width: 4),
              _buildDot(accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  ChatMessage({required this.text, required this.isUser, this.isError = false});
}
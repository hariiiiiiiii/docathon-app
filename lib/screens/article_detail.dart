import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
// Import the local service
import '../services/bookmark_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> articleData;

  const ArticleDetailScreen({super.key, required this.articleData});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool isBookmarked = false;
  late String articleId;

  @override
  void initState() {
    super.initState();
    // Use 'id' if available, otherwise title (fallback)
    articleId = widget.articleData['id'] ?? widget.articleData['title'];
    _checkBookmarkStatus();
  }

  void _checkBookmarkStatus() async {
    bool status = await BookmarkService.isBookmarked(articleId);
    if (mounted) setState(() => isBookmarked = status);
  }

  void _toggleBookmark() async {
    await BookmarkService.toggleBookmark(widget.articleData);
    setState(() => isBookmarked = !isBookmarked);
    
    if (mounted) {
      // Updated SnackBar color to match new theme
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isBookmarked ? "Saved to bookmarks" : "Removed from bookmarks"),
          duration: const Duration(milliseconds: 800),
          backgroundColor: const Color(0xFF003545), // Dark teal surface
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.articleData['title'] as String? ?? 'No Title';
    final content = widget.articleData['content'] as String? ?? 'No content available.';
    final category = widget.articleData['category'] as String? ?? 'General';

    // --- THEME CONSTANTS (Teal/Blue) ---
    const backgroundColor = Color(0xFF001219); // Deep dark teal/blue
    const surfaceColor = Color(0xFF003545);    // Dark teal surface
    const accentColor = Color(0xFF00E5FF);     // Electric Cyan
    const textColor = Colors.white;
    const secondaryTextColor = Color(0xFFB0BEC5); // Blue-greyish white for text

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: surfaceColor, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: textColor),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // --- TOGGLE BUTTON ---
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: surfaceColor, shape: BoxShape.circle),
              child: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                size: 20,
                color: isBookmarked ? accentColor : textColor,
              ),
            ),
            onPressed: _toggleBookmark,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Text(
                category.toUpperCase(),
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: accentColor, letterSpacing: 1.0),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: textColor, height: 1.2)),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.verified, size: 16, color: accentColor),
                const SizedBox(width: 6),
                Text("Verified Medical Information", style: GoogleFonts.poppins(fontSize: 12, color: accentColor, fontWeight: FontWeight.w500)),
              ],
            ),
            const Divider(height: 40, color: Colors.white24),
            MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.poppins(fontSize: 16, height: 1.8, color: secondaryTextColor),
                h1: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: textColor, height: 2.0),
                h2: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: textColor, height: 1.8),
                h3: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textColor, height: 1.6),
                listBullet: GoogleFonts.poppins(fontSize: 16, color: accentColor),
                a: GoogleFonts.poppins(color: accentColor, decoration: TextDecoration.underline, decorationColor: accentColor, fontWeight: FontWeight.bold),
                strong: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: textColor),
                // Updated blockquote colors for teal theme
                blockquote: GoogleFonts.poppins(fontSize: 15, fontStyle: FontStyle.italic, color: const Color(0xFFE0F7FA), fontWeight: FontWeight.w500),
                blockquotePadding: const EdgeInsets.all(20),
                blockquoteDecoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border(left: BorderSide(color: accentColor, width: 4))),
                code: GoogleFonts.firaCode(backgroundColor: Colors.black26, color: textColor, fontSize: 14),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
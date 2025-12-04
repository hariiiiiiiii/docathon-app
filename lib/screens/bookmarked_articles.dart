import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/bookmark_service.dart';
import 'article_detail.dart';

class BookmarkedArticlesScreen extends StatefulWidget {
  const BookmarkedArticlesScreen({Key? key}) : super(key: key);

  @override
  State<BookmarkedArticlesScreen> createState() => _BookmarkedArticlesScreenState();
}

class _BookmarkedArticlesScreenState extends State<BookmarkedArticlesScreen> {
 
  final backgroundColor = const Color(0xFF001219); 
  final surfaceColor = const Color(0xFF003545);    
  final accentColor = const Color(0xFF00E5FF);     

  Future<List<Map<String, dynamic>>> _loadBookmarks() async {
    return await BookmarkService.getBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Saved Articles", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadBookmarks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 60, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text("No bookmarks yet.", style: GoogleFonts.poppins(color: Colors.white54)),
                ],
              ),
            );
          }

          final bookmarks = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final data = bookmarks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    data['title'] ?? 'Untitled',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.label, size: 14, color: accentColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            data['category'] ?? 'Saved',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white54),
                    onPressed: () async {
                      await BookmarkService.toggleBookmark(data);
                      setState(() {}); // Refresh list
                    },
                  ),
                  onTap: () {
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailScreen(articleData: data),
                      ),
                    ).then((_) => setState(() {})); // Refresh when returning
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
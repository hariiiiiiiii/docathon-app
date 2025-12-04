import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'article_detail.dart'; 
import 'bookmarked_articles.dart'; // Import the bookmarks screen

class ArticlesListScreen extends StatefulWidget {
  const ArticlesListScreen({Key? key}) : super(key: key);

  @override
  State<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends State<ArticlesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _selectedCategory; 

  final List<String> _categories = [
    "Menstrual Health",
    "Contraception",
    "Pregnancy",
    "Sexual Health",
    "Mental Health",
    "Medical Law & Ethics"
  ];

  final Map<String, String> _categoryToTagMap = {
    "Menstrual Health": "menstrual",
    "Contraception": "contraception",
    "Pregnancy": "pregnancy",
    "Sexual Health": "sexual",
    "Mental Health": "mental", 
    "Medical Law & Ethics": "legal"
  };

  Map<String, dynamic> _getCategoryStyle(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('menstrual') || name.contains('period')) {
      return {'icon': Icons.water_drop, 'color': Colors.amberAccent, 'bg': Colors.amber.withOpacity(0.15)};
    } else if (name.contains('contraception') || name.contains('safe')) {
      return {'icon': Icons.shield_outlined, 'color': Colors.tealAccent, 'bg': Colors.tealAccent.withOpacity(0.15)};
    } else if (name.contains('pregnancy') || name.contains('maternity')) {
      return {'icon': Icons.pregnant_woman, 'color': Colors.pinkAccent, 'bg': Colors.pinkAccent.withOpacity(0.15)};
    } else if (name.contains('sexual') || name.contains('intimacy')) {
      return {'icon': Icons.favorite, 'color': Colors.blueAccent, 'bg': Colors.blueAccent.withOpacity(0.15)};
    } else if (name.contains('mental') || name.contains('stress')) {
      return {'icon': Icons.psychology, 'color': Colors.orangeAccent, 'bg': Colors.orangeAccent.withOpacity(0.15)};
    } else if (name.contains('legal') || name.contains('law')) {
      return {'icon': Icons.gavel, 'color': Colors.deepPurpleAccent, 'bg': Colors.deepPurpleAccent.withOpacity(0.15)};
    }
    return {'icon': Icons.article, 'color': Colors.white70, 'bg': Colors.white10};
  }

  // --- NEW: Handle Back Button Logic ---
  Future<bool> _onWillPop() async {
    if (_selectedCategory != null) {
      // If a category is selected, go back to main category list
      setState(() {
        _selectedCategory = null;
      });
      return false; // Prevent popping the screen
    }
    if (_searchQuery.isNotEmpty) {
      // If searching, clear search first
      setState(() {
        _searchQuery = "";
        _searchController.clear();
      });
      return false; // Prevent popping the screen
    }
    return true; // If nothing selected, allow popping back to Main Page
  }

  @override
  Widget build(BuildContext context) {
    // --- THEME CONSTANTS (UPDATED) ---
    const backgroundColor = Color(0xFF001219); // Deep dark teal/blue
    const surfaceColor = Color(0xFF003545);    // Dark teal surface
    const accentColor = Color(0xFF00E5FF);     // Electric Cyan

    // Wrap Scaffold in WillPopScope to intercept system back button
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () {
              // Use the same logic for the App Bar back arrow
              _onWillPop().then((shouldPop) {
                if (shouldPop) {
                  Navigator.pop(context);
                }
              });
            },
          ),
          title: Text(
            "Information Hub",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            // --- Bookmark Button ---
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: Colors.white),
              tooltip: "Saved Articles",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookmarkedArticlesScreen()),
                );
              },
            ),
            
            // Clear Filter Button
            if (_selectedCategory != null && _searchQuery.isEmpty)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() => _selectedCategory = null);
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search health topics...",
                  hintStyle: GoogleFonts.poppins(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: accentColor),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _searchQuery.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                ),
              ),
  
              const SizedBox(height: 24),
  
              if (_searchQuery.isNotEmpty)
                _buildSearchResults(surfaceColor, accentColor)
              else 
                _buildBrowseContent(surfaceColor, accentColor),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(Color surfaceColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Search Results", 
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('articles').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: accentColor));
            }
            
            final docs = snapshot.data?.docs ?? [];
            final filteredDocs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final query = _searchQuery.toLowerCase();
              final title = (data['title'] ?? '').toString().toLowerCase();
              final category = (data['category'] ?? '').toString().toLowerCase();
              final tagsList = data['tags'] is List ? List<String>.from(data['tags']) : [];
              final hasMatchingTag = tagsList.any((tag) => tag.toString().toLowerCase().contains(query));
              return title.contains(query) || category.contains(query) || hasMatchingTag;
            }).toList();

            if (filteredDocs.isEmpty) {
              return Center(child: Text("No matches found.", style: GoogleFonts.poppins(color: Colors.white54)));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                return _buildArticleItem(filteredDocs[index], surfaceColor, accentColor);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBrowseContent(Color surfaceColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedCategory == null) ...[
          Text("Browse by Category", 
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final catName = _categories[index];
              final style = _getCategoryStyle(catName);

              return Material(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() => _selectedCategory = catName);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: style['bg'],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(style['icon'], color: style['color'], size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        catName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600, 
                          color: Colors.white
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
        ],

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedCategory != null ? "$_selectedCategory" : "Featured Articles", 
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_selectedCategory != null)
              TextButton(
                onPressed: () => setState(() => _selectedCategory = null),
                child: Text("Show All", style: TextStyle(color: accentColor)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        StreamBuilder<QuerySnapshot>(
          stream: _selectedCategory == null 
              ? FirebaseFirestore.instance.collection('articles').limit(5).snapshots()
              : FirebaseFirestore.instance
                  .collection('articles')
                  .where('tags', arrayContains: _categoryToTagMap[_selectedCategory]) 
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: accentColor));
            }
            
            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Text(
                  _selectedCategory == null 
                    ? "No articles found." 
                    : "No articles found for ${_categoryToTagMap[_selectedCategory]}.",
                  style: GoogleFonts.poppins(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                return _buildArticleItem(docs[index], surfaceColor, accentColor);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildArticleItem(DocumentSnapshot doc, Color surfaceColor, Color accentColor) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // Pass ID for bookmarks

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
                  (data['tags'] != null && (data['tags'] as List).isNotEmpty) 
                      ? (data['tags'] as List).take(3).join(", ") 
                      : (data['category'] ?? 'General'),
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ArticleDetailScreen(articleData: data),
            ),
          );
        },
      ),
    );
  }
}
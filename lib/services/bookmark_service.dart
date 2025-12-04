import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _key = 'teenhealth_bookmarks';

  /// Toggle Bookmark: Adds if missing, Removes if present
  static Future<void> toggleBookmark(Map<String, dynamic> article) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList(_key) ?? [];

    // Use ID if available, else fallback to Title (unique enough for this)
    String targetId = article['id'] ?? article['title'];

    // Check if already bookmarked
    int index = -1;
    for (int i = 0; i < savedList.length; i++) {
      final Map<String, dynamic> item = jsonDecode(savedList[i]);
      if ((item['id'] ?? item['title']) == targetId) {
        index = i;
        break;
      }
    }

    if (index != -1) {
      // Remove it
      savedList.removeAt(index);
    } else {
      // Add it (Save all data so we can read it offline!)
      savedList.add(jsonEncode(article));
    }

    await prefs.setStringList(_key, savedList);
  }

  /// Check status for the Icon
  static Future<bool> isBookmarked(String targetId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList(_key) ?? [];

    for (String s in savedList) {
      final Map<String, dynamic> item = jsonDecode(s);
      if ((item['id'] ?? item['title']) == targetId) return true;
    }
    return false;
  }

  /// Get all saved articles
  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList(_key) ?? [];
    
    // Decode JSON strings back to Maps
    return savedList.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }
}
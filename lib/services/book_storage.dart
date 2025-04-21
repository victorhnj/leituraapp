import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class BookStorage {
  static const String key = 'books';

  static Future<List<Book>> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => Book.fromJson(e)).toList();
    }
    return [];
  }

  static Future<void> saveBooks(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(books.map((b) => b.toJson()).toList());
    await prefs.setString(key, data);
  }
}

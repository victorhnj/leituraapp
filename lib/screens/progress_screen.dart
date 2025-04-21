import 'dart:io';
import 'package:flutter/material.dart';
import '../models/book.dart';

class ProgressScreen extends StatelessWidget {
  final List<Book> books;
  ProgressScreen({required this.books});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text('Status de Leitura'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: books.length,
        separatorBuilder: (_, __) => SizedBox(height: 10),
        itemBuilder: (context, index) {
          final book = books[index];
          final progress =
              book.totalPages > 0 ? book.pagesRead / book.totalPages : 0.0;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading:
                  book.coverPath != null
                      ? ClipOval(
                        child: Image.file(
                          File(book.coverPath!),
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                      : CircleAvatar(child: Icon(Icons.menu_book)),
              title: Text(
                book.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6),
                  LinearProgressIndicator(value: progress, minHeight: 8),
                  SizedBox(height: 6),
                  Text('${(progress * 100).toStringAsFixed(1)}% lido'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

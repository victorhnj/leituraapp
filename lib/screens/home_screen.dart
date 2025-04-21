import 'dart:io';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_storage.dart';

class HomeScreen extends StatefulWidget {
  final List<Book> books;
  HomeScreen({required this.books});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _editProgress(Book book, int index) {
    final controller = TextEditingController(text: book.pagesRead.toString());

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Atualizar leitura'),
            content: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Páginas lidas'),
            ),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text('Salvar'),
                onPressed: () {
                  final newPages = int.tryParse(controller.text);
                  if (newPages != null && newPages <= book.totalPages) {
                    setState(() {
                      widget.books[index].pagesRead = newPages;
                    });
                    BookStorage.saveBooks(widget.books);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Valor inválido')));
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = widget.books;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text('Meus Livros'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: books.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            final book = books[index];
            return GestureDetector(
              onTap: () => _editProgress(book, index),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blue[50],
                        ),
                        child:
                            book.coverPath != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(book.coverPath!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Icon(
                                  Icons.menu_book,
                                  size: 60,
                                  color: Colors.blueGrey,
                                ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        book.author,
                        style: TextStyle(color: Colors.grey[600]),
                        maxLines: 1,
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            book.status,
                            style: TextStyle(fontSize: 12, color: Colors.green),
                          ),
                          Text(
                            '${book.pagesRead}/${book.totalPages}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

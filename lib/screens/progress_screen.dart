// screens/progress_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class ProgressScreen extends StatefulWidget {
  final List<Book> books;
  ProgressScreen({required this.books});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _searchTerm = '';
  String _selectedStatus = 'Todos';
  int _metaLeitura = 5;

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _metaLeitura = prefs.getInt('meta_leitura') ?? 5;
    });
  }

  List<Book> get filteredBooks {
    return widget.books.where((book) {
      final matchesSearch = book.title.toLowerCase().contains(
        _searchTerm.toLowerCase(),
      );
      final matchesStatus =
          _selectedStatus == 'Todos' ||
          (_selectedStatus == 'A iniciar' && book.pagesRead == 0) ||
          (_selectedStatus == 'Em andamento' &&
              book.pagesRead > 0 &&
              book.pagesRead < book.totalPages) ||
          (_selectedStatus == 'Concluído' && book.pagesRead == book.totalPages);
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final livrosConcluidos =
        widget.books.where((b) => b.pagesRead == b.totalPages).length;
    final progressoMeta =
        _metaLeitura > 0 ? livrosConcluidos / _metaLeitura : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text('Status de Leitura'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meta de Leitura: $livrosConcluidos / $_metaLeitura'),
                SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progressoMeta > 1 ? 1 : progressoMeta,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ],
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 220,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Buscar título',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) => setState(() => _searchTerm = value),
                    ),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 160,
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items:
                          ['Todos', 'A iniciar', 'Em andamento', 'Concluído']
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => _selectedStatus = value!),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: filteredBooks.length,
                separatorBuilder: (_, __) => SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  final progress =
                      book.totalPages > 0
                          ? book.pagesRead / book.totalPages
                          : 0.0;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading:
                          !kIsWeb && book.coverPath != null
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
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                          ),
                          SizedBox(height: 6),
                          Text('${(progress * 100).toStringAsFixed(1)}% lido'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

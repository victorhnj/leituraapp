// screens/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../services/book_storage.dart';
import 'meta_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Book> books;
  HomeScreen({required this.books});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      appBar: AppBar(
        title: Text('Meus Livros'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.flag),
            tooltip: 'Definir Meta',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MetaScreen(onMetaUpdated: _loadMeta),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
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
              child: GridView.builder(
                itemCount: filteredBooks.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  final originalIndex = widget.books.indexOf(book);

                  return GestureDetector(
                    onTap: () => _editProgress(book, originalIndex),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  !kIsWeb && book.coverPath != null
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              book.author,
                              style: TextStyle(color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  book.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
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
          ],
        ),
      ),
    );
  }
}

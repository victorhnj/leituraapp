import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/book.dart';

class AddBookScreen extends StatefulWidget {
  final Function(Book) onAdd;
  AddBookScreen({required this.onAdd});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String author = '';
  int totalPages = 0;
  int pagesRead = 0;
  File? _coverImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _coverImage = File(picked.path));
    }
  }

  void saveBook() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newBook = Book(
        title: title,
        author: author,
        totalPages: totalPages,
        pagesRead: pagesRead,
        coverPath: _coverImage?.path,
      );
      widget.onAdd(newBook);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Livro salvo')));
      setState(() {
        title = '';
        author = '';
        totalPages = 0;
        pagesRead = 0;
        _coverImage = null;
      });
    }
  }

  InputDecoration customInput(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text('Cadastrar Livro'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      image:
                          _coverImage != null
                              ? DecorationImage(
                                image: FileImage(_coverImage!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        _coverImage == null
                            ? Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey[700],
                            )
                            : null,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: customInput('Título'),
                  onSaved: (value) => title = value!,
                  validator:
                      (value) => value!.isEmpty ? 'Informe o título' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  decoration: customInput('Autor'),
                  onSaved: (value) => author = value!,
                ),
                SizedBox(height: 12),
                TextFormField(
                  decoration: customInput('Total de Páginas'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => totalPages = int.parse(value!),
                ),
                SizedBox(height: 12),
                TextFormField(
                  decoration: customInput('Páginas Lidas'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => pagesRead = int.parse(value!),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('Salvar Livro'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: saveBook,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

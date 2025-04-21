// screens/add_book_screen.dart
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
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _totalPagesController = TextEditingController();
  final _pagesReadController = TextEditingController();

  File? _coverImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _coverImage = File(picked.path));
    }
  }

  void saveBook() {
    if (_formKey.currentState!.validate()) {
      final newBook = Book(
        title: _titleController.text,
        author: _authorController.text,
        totalPages: int.parse(_totalPagesController.text),
        pagesRead: int.parse(_pagesReadController.text),
        coverPath: _coverImage?.path,
      );
      widget.onAdd(newBook);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Livro salvo')));

      setState(() {
        _titleController.clear();
        _authorController.clear();
        _totalPagesController.clear();
        _pagesReadController.clear();
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
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _totalPagesController.dispose();
    _pagesReadController.dispose();
    super.dispose();
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
                  controller: _titleController,
                  decoration: customInput('Título'),
                  validator:
                      (value) => value!.isEmpty ? 'Informe o título' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _authorController,
                  decoration: customInput('Autor'),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _totalPagesController,
                  decoration: customInput('Total de Páginas'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _pagesReadController,
                  decoration: customInput('Páginas Lidas'),
                  keyboardType: TextInputType.number,
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

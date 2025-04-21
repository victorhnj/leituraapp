import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_book_screen.dart';
import 'progress_screen.dart';
import '../models/book.dart';
import '../services/book_storage.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  void loadBooks() async {
    final loadedBooks = await BookStorage.loadBooks();
    setState(() => books = loadedBooks);
  }

  void addBook(Book book) {
    setState(() {
      books.add(book);
    });
    BookStorage.saveBooks(books);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(books: books),
      AddBookScreen(onAdd: addBook),
      ProgressScreen(books: books),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[500],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Meus Livros',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Cadastro'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Status'),
        ],
      ),
    );
  }
}

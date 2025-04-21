class Book {
  String title;
  String author;
  int totalPages;
  int pagesRead;
  String? coverPath;

  Book({
    required this.title,
    required this.author,
    required this.totalPages,
    required this.pagesRead,
    this.coverPath,
  });

  String get status {
    if (pagesRead == 0) return 'Não iniciado';
    if (pagesRead < totalPages) return 'Em andamento';
    return 'Lido';
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'author': author,
    'totalPages': totalPages,
    'pagesRead': pagesRead,
    'coverPath': coverPath,
  };

  static Book fromJson(Map<String, dynamic> json) => Book(
    title: json['title'],
    author: json['author'],
    totalPages: json['totalPages'],
    pagesRead: json['pagesRead'],
    coverPath: json['coverPath'],
  );
}

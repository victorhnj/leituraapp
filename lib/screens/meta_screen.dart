// screens/meta_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MetaScreen extends StatefulWidget {
  final Function onMetaUpdated;
  const MetaScreen({required this.onMetaUpdated});

  @override
  State<MetaScreen> createState() => _MetaScreenState();
}

class _MetaScreenState extends State<MetaScreen> {
  final _metaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final meta = prefs.getInt('meta_leitura') ?? 5;
    _metaController.text = meta.toString();
  }

  Future<void> _saveMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final novaMeta = int.tryParse(_metaController.text);
    if (novaMeta != null && novaMeta > 0) {
      await prefs.setInt('meta_leitura', novaMeta);
      widget.onMetaUpdated();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Informe um valor válido!')));
    }
  }

  @override
  void dispose() {
    _metaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text('Definir Meta de Leitura')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _metaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Meta de livros a ler',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.check),
              label: Text('Salvar Meta'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveMeta,
            ),
          ],
        ),
      ),
    );
  }
}

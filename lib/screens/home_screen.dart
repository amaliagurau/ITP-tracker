import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authentication/screens/signin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Masina> masini = [
    Masina(
      numarInmatriculare: "B 123 ABC",
      dataITP: DateTime(2023, 1, 1),
      marca: "Marca1",
      model: "Model1",
    ),
    Masina(
      numarInmatriculare: "CJ 456 DEF",
      dataITP: DateTime(2023, 2, 15),
      marca: "Marca2",
      model: "Model2",
    ),
    Masina(
      numarInmatriculare: "GL 789 XYZ",
      dataITP: DateTime(2023, 3, 10),
      marca: "Marca3",
      model: "Model3",
    ),
  ];

  final TextEditingController _numarInmatriculareController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _dataITPController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Mașini', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Colors
                .white), 
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                print("Signed Out");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              });
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFCB2B93),
              Color(0xFF9546C4),
              Color(0xFF5E61F4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: masini.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _showDetailDialog(context, index),
              child: Card(
                color: Colors.transparent,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(masini[index].numarInmatriculare,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                      'Data ITP: ${masini[index].dataITP.day}/${masini[index].dataITP.month}/${masini[index].dataITP.year}',
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adăugare Mașină', style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _numarInmatriculareController,
                  decoration: const InputDecoration(
                      labelText: 'Nr. Inmatriculare',
                      labelStyle: TextStyle(color: Colors.black))),
              TextField(
                  controller: _marcaController,
                  decoration: const InputDecoration(
                      labelText: 'Marca',
                      labelStyle: TextStyle(color: Colors.black))),
              TextField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                      labelText: 'Model',
                      labelStyle: TextStyle(color: Colors.black))),
              TextField(
                  controller: _dataITPController,
                  decoration: const InputDecoration(
                      labelText: 'Data ITP (YYYY-MM-DD)',
                      labelStyle: TextStyle(color: Colors.black))),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  DateTime dataITP = DateTime.parse(_dataITPController.text);
                  masini.add(Masina(
                    numarInmatriculare: _numarInmatriculareController.text,
                    dataITP: dataITP,
                    marca: _marcaController.text,
                    model: _modelController.text,
                  ));
                });
                Navigator.of(context).pop();
              },
              child: const Text('Adaugă'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anulează'),
            ),
          ],
        );
      },
    );
  }

  void _showDetailDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalii Mașină', style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nr. Inmatriculare: ${masini[index].numarInmatriculare}',
                  style: const TextStyle(color: Colors.black)),
              Text('Marca: ${masini[index].marca}',
                  style: const TextStyle(color: Colors.black)),
              Text('Model: ${masini[index].model}',
                  style: const TextStyle(color: Colors.black)),
              Text(
                  'Data ITP: ${masini[index].dataITP.day}/${masini[index].dataITP.month}/${masini[index].dataITP.year}',
                  style: const TextStyle(color: Colors.black)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _showEditDialog(context, index);
              },
              child: const Text('Editează'),
            ),
            TextButton(
              onPressed: () {
                _showDeleteDialog(context, index);
              },
              child: const Text('Șterge'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Închide'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    _numarInmatriculareController.text = masini[index].numarInmatriculare;
    _marcaController.text = masini[index].marca;
    _modelController.text = masini[index].model;
    _dataITPController.text = masini[index].dataITP.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editare Mașină', style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _numarInmatriculareController,
                  decoration: const InputDecoration(
                      labelText: 'Nr. Inmatriculare',
                      labelStyle: TextStyle(color: Colors.black))),
              TextField(
                  controller: _marcaController,
                  decoration: const InputDecoration(
                      labelText: 'Marca',
                      labelStyle: TextStyle(color: Colors.black))),
              TextField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                      labelText: 'Model',
                      labelStyle: TextStyle(color: Colors.black))),
              TextField(
                  controller: _dataITPController,
                  decoration: const InputDecoration(
                      labelText: 'Data ITP (YYYY-MM-DD)',
                      labelStyle: TextStyle(color: Colors.black))),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  masini[index].numarInmatriculare =
                      _numarInmatriculareController.text;
                  masini[index].marca = _marcaController.text;
                  masini[index].model = _modelController.text;
                  masini[index].dataITP =
                      DateTime.parse(_dataITPController.text);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Salvează'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anulează'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ștergere Mașină', style: TextStyle(color: Colors.black)),
          content: const Text('Sunteți sigur că doriți să ștergeți această mașină?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  masini.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Șterge'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anulează'),
            ),
          ],
        );
      },
    );
  }
}

class Masina {
  late String numarInmatriculare;
  late DateTime dataITP;
  late String marca;
  late String model;

  Masina({
    required this.numarInmatriculare,
    required this.dataITP,
    required this.marca,
    required this.model,
  });
}

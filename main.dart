import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_sqlite/models/saham.dart';

void main() {
  runApp(MyApp());
}

class Saham {
  int? tickerId;
  String ticker;
  int? open;
  int? high;
  int? last;
  String change;

  Saham({
    this.tickerId,
    required this.ticker,
    this.open,
    this.high,
    this.last,
    required this.change,
  });

  Map<String, dynamic> toMap() {
    return {
      'tickerId': tickerId,
      'ticker': ticker,
      'open': open,
      'high': high,
      'last': last,
      'change': change,
    };
  }

  factory Saham.fromMap(Map<String, dynamic> map) {
    return Saham(
      tickerId: map['tickerId'],
      ticker: map['ticker'],
      open: map['open'],
      high: map['high'],
      last: map['last'],
      change: map['change'],
    );
  }
}

class DatabaseHandler {
  DatabaseHandler._();
  static final DatabaseHandler instance = DatabaseHandler._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'saham_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE saham(
        tickerId INTEGER PRIMARY KEY AUTOINCREMENT,
        ticker TEXT NOT NULL,
        open INTEGER,
        high INTEGER,
        last INTEGER,
        change TEXT
      )
    ''');
  }

  Future<int> insertSaham(Saham saham) async {
    final db = await database;
    return await db.insert('saham', saham.toMap());
  }

  Future<List<Saham>> getSahamList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('saham');
    return List.generate(maps.length, (i) {
      return Saham.fromMap(maps[i]);
    });
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Aplikasi Saham'),
        ),
        body: Center(
          child: Column(
            children: [
              SahamForm(),
              Expanded(
                child: SahamList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SahamForm extends StatefulWidget {
  @override
  _SahamFormState createState() => _SahamFormState();
}

class _SahamFormState extends State<SahamForm> {
  final TextEditingController tickerController = TextEditingController();
  final TextEditingController openController = TextEditingController();
  final TextEditingController highController = TextEditingController();
  final TextEditingController lastController = TextEditingController();
  final TextEditingController changeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: tickerController,
          decoration: InputDecoration(labelText: 'Ticker'),
        ),
        TextField(
          controller: openController,
          decoration: InputDecoration(labelText: 'Open'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: highController,
          decoration: InputDecoration(labelText: 'High'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: lastController,
          decoration: InputDecoration(labelText: 'Last'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: changeController,
          decoration: InputDecoration(labelText: 'Change'),
        ),
        ElevatedButton(
          onPressed: () async {
            final ticker = tickerController.text;
            final open = int.tryParse(openController.text);
            final high = int.tryParse(highController.text);
            final last = int.tryParse(lastController.text);
            final change = changeController.text;

            if (ticker.isNotEmpty && open != null && high != null && last != null) {
              final saham = Saham(
                ticker: ticker,
                open: open,
                high: high,
                last: last,
                change: change,
              );

              final handler = DatabaseHandler.instance;
              await handler.insertSaham(saham);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data saham berhasil disimpan'),
                ),
              );

              tickerController.clear();
              openController.clear();
              highController.clear();
              lastController.clear();
              changeController.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Harap isi semua field yang diperlukan'),
                ),
              );
            }
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}

class SahamList extends StatefulWidget {
  @override
  _SahamListState createState() => _SahamListState();
}

class _SahamListState extends State<SahamList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Saham>>(
      future: DatabaseHandler.instance.getSahamList(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('Tidak ada data saham.'),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final saham = snapshot.data![index];
              final changeValue = double.tryParse(saham.change) ?? 0.0;
              final isNegativeChange = changeValue < 0;

              return ListTile(
                title: Text('Ticker: ${saham.ticker}'),
                subtitle: Text('Open: ${saham.open}, High: ${saham.high}, Last: ${saham.last}, Change: ${saham.change}'),
                tileColor: isNegativeChange ? Colors.red : Colors.green,
              );
            },
          );
        }
      },
    );
  }
}

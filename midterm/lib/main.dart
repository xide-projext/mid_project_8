import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const BudgetApp());

class BudgetApp extends StatelessWidget {
  const BudgetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final double _showtotal = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('홈'),
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    '현재 자산',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '\u20A9${(_showtotal).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 36.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BudgetScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '내역 조회',
                        style: TextStyle(
                          fontSize: 24.0,
                          decoration: TextDecoration.none,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
        )));
  }
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  BudgetScreenState createState() => BudgetScreenState();
}

class BudgetScreenState extends State<BudgetScreen> {
  double _income = 0.0;
  double _expenses = 0.0;
  double _asset = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('budget_data');
    if (jsonData != null) {
      final data = json.decode(jsonData);
      setState(() {
        _income = data['income'];
        _expenses = data['expenses'];
        _asset = ExtraBudgetScreenState.totalAssets + _income - _expenses;
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json
        .encode({'income': _income, 'expenses': _expenses, 'asset': _asset});
    await prefs.setString('budget_data', jsonData);
  }

  @override
  void dispose() {
    _saveData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('내역 조회'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExtraBudgetScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '자산',
                      style: TextStyle(
                        fontSize: 24.0,
                        decoration: TextDecoration.none,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '\u20A9${(_asset).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 36.0, fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  '월 수익 대비 지출',
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                      begin: 0.0,
                      end: _income == 0.0 ? 0.0 : _expenses / _income),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '수익',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    Text(
                      '\u20A9${(_income).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24.0),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '월 수익 입력',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _income = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '지출',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    Text(
                      '\u20A9${(_expenses).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24.0),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '월 지출 입력',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _expenses = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class ExtraBudgetScreen extends StatefulWidget {
  const ExtraBudgetScreen({Key? key}) : super(key: key);

  @override
  ExtraBudgetScreenState createState() => ExtraBudgetScreenState();
}

class ExtraBudgetScreenState extends State<ExtraBudgetScreen> {
  static double _cash = 0.0;
  static double _stock = 0.0;
  static double _realestate = 0.0;
  static double _crypto = 0.0;
  static double _other = 0.0;
  static double get totalAssets =>
      _cash + _stock + _realestate + _crypto + _other;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('asset_data');
      if (jsonData != null) {
        final data = json.decode(jsonData);
        setState(() {
          _cash = data['cash'] ?? 0.0;
          _stock = data['stock'] ?? 0.0;
          _realestate = data['realestate'] ?? 0.0;
          _crypto = data['crypto'] ?? 0.0;
          _other = data['other'] ?? 0.0;
        });
      }
    } catch (e) {
      print('Failed to load data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode({
        'cash': _cash,
        'stock': _stock,
        'realestate': _realestate,
        'crypto': _crypto,
        'other': _other,
      });
      await prefs.setString('asset_data', jsonData);
    } catch (e) {
      print('Failed to save data: $e');
    }
  }

  @override
  void dispose() {
    _saveData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자산 상세 정보'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '현금',
                  style: TextStyle(fontSize: 24.0),
                ),
                Text(
                  '\u20A9${(_cash).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24.0),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '보유 현금 금액 입력',
              ),
              onChanged: (value) {
                setState(() {
                  _cash = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '주식',
                  style: TextStyle(fontSize: 24.0),
                ),
                Text(
                  '\u20A9${(_stock).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24.0),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '보유 주식 금액 입력',
              ),
              onChanged: (value) {
                setState(() {
                  _stock = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '부동산',
                  style: TextStyle(fontSize: 24.0),
                ),
                Text(
                  '\u20A9${(_realestate).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24.0),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '보유 부둥산 금액 입력',
              ),
              onChanged: (value) {
                setState(() {
                  _realestate = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '가상 화폐',
                  style: TextStyle(fontSize: 24.0),
                ),
                Text(
                  '\u20A9${(_crypto).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24.0),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '보유 가상화폐 금액 입력',
              ),
              onChanged: (value) {
                setState(() {
                  _crypto = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '이외 자산',
                  style: TextStyle(fontSize: 24.0),
                ),
                Text(
                  '\u20A9${(_other).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24.0),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '보유 이외 자산 금액 입력',
              ),
              onChanged: (value) {
                setState(() {
                  _other = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '총 자산',
              style: TextStyle(fontSize: 24.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '\u20A9${(totalAssets).toStringAsFixed(2)}',
              style:
                  const TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _saveData,
                child: const Text('저장'),
              )),
        ],
      ),
    );
  }
}

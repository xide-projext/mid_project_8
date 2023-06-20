import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;


import 'package:midterm/coinModel.dart';
import 'package:midterm/coinCard.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

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
      routes: {
        '/stock': (context) => const StockPage(),
      },
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

  int _currentIndex = 0;
  final List<Widget> _screens = [
    const MainPageContent(showTotal: 0.0),
    const StockPageContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0 ? const Text('홈') : const Text('투자'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: '투자',
          ),
        ],
      ),
    );
  }
}

class MainPageContent extends StatefulWidget {
  final double showTotal;

  const MainPageContent({Key? key, required this.showTotal}) : super(key: key);

  @override
  _MainPageContentState createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  DateTime _selectedDay = DateTime.now();

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });

    // Perform any additional actions based on the selected day
    // Here you can update the UI or navigate to a specific screen
    print("Selected day: $_selectedDay");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime(DateTime.now().year - 1),
            lastDay: DateTime(DateTime.now().year + 1),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    '현재 자산',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '\u20A9${(widget.showTotal).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BudgetScreen()),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  BudgetScreenState createState() => BudgetScreenState();
}

class BudgetScreenState extends State<BudgetScreen> {
  static double _income = 0.0;
  static double _expenses = 0.0;
  static double _asset = 0.0;

  final Map<String, double> _tempData = {
    'income': 0.0,
    'expenses': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('budget_data');
      if (jsonData != null) {
        final data = json.decode(jsonData);
        setState(() {
          _tempData['income'] = data['income'] ?? 0.0;
          _tempData['expenses'] = data['expenses'] ?? 0.0;
          _asset = ExtraBudgetScreenState.totalAssets +
              _tempData['income']! -
              _tempData['expenses']!;
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
        'income': _tempData['income'],
        'expenses': _tempData['expenses'],
        'asset': _asset,
      });
      await prefs.setString('budget_data', jsonData);

      setState(() {
        _income = _tempData['income']!;
        _expenses = _tempData['expenses']!;
        _asset = _asset;
      });
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
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
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
                      _tempData['income'] = double.tryParse(value) ?? 0.0;
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
                      _tempData['expenses'] = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _income = _tempData['income'] as double;
                      _expenses = _tempData['expenses'] as double;
                      _asset = _tempData['asset'] as double;
                    });
                    _saveData();
                  },
                  child: const Text('저장'),
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

  final Map<String, double> _tempData = {
    'cash': 0.0,
    'stock': 0.0,
    'realestate': 0.0,
    'crypto': 0.0,
    'other': 0.0,
  };

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
          _tempData['cash'] = data['cash'] ?? 0.0;
          _tempData['stock'] = data['stock'] ?? 0.0;
          _tempData['realestate'] = data['realestate'] ?? 0.0;
          _tempData['crypto'] = data['crypto'] ?? 0.0;
          _tempData['other'] = data['other'] ?? 0.0;
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
        'cash': _tempData['cash'],
        'stock': _tempData['stock'],
        'realestate': _tempData['realestate'],
        'crypto': _tempData['crypto'],
        'other': _tempData['other'],
      });
      await prefs.setString('asset_data', jsonData);
    } catch (e) {
      print('Failed to save data: $e');
    }
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
                  _tempData['cash'] = double.tryParse(value) ?? 0.0;
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
                  _tempData['stock'] = double.tryParse(value) ?? 0.0;
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
                  _tempData['realestate'] = double.tryParse(value) ?? 0.0;
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
                  _tempData['crypto'] = double.tryParse(value) ?? 0.0;
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
                  _tempData['other'] = double.tryParse(value) ?? 0.0;
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
              onPressed: () {
                setState(() {
                  _cash = _tempData['cash'] as double;
                  _stock = _tempData['stock'] as double;
                  _realestate = _tempData['realestate'] as double;
                  _crypto = _tempData['crypto'] as double;
                  _other = _tempData['other'] as double;
                });
                _saveData();
              },
              child: const Text('저장'),
            ),
          ),
        ],
      ),
    );
  }
}

class StockPageContent extends StatefulWidget {
  const StockPageContent({Key? key}) : super(key: key);


  @override
  _StockPageContentState createState() => _StockPageContentState();
}

class _StockPageContentState extends State<StockPageContent> {
  late List<Coin> coinList;

  Future<List<Coin>> fetchCoin() async {
    coinList = [];
    final response = await http.get(Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc'));

    if (response.statusCode == 200) {
      List<dynamic> values = [];
      values = json.decode(response.body);
      if (values.length > 0) {
        for (int i = 0; i < values.length; i++) {
          if (values[i] != null) {
            Map<String, dynamic> map = values[i];
            coinList.add(Coin.fromJson(map));
          }
        }
        setState(() {
          coinList;
        });
      }
      return coinList;
    } else {
      throw Exception('Failed to load coins');
    }
  }

  @override
  void initState() {
    fetchCoin();
    Timer.periodic(const Duration(seconds: 10), (timer) => fetchCoin());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: coinList.length,
        itemBuilder: (context, index) {
          return CoinCard(
            name: coinList[index].name,
            symbol: coinList[index].symbol,
            image: coinList[index].image,
            price: coinList[index].price.toDouble(),
            change: coinList[index].change.toDouble(),
            changePercentage: coinList[index].changePercentage.toDouble(),
          );
        },
      ),
    );
  }
}



class StockPage extends StatelessWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('투자'),
      ),
      body: const StockPageContent(),
    );
  }
}

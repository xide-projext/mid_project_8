import 'package:flutter/material.dart';

void main() => runApp(const BudgetApp());

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('현재 자산'),
      ),
      body: const Center(child: Text('This is a new page.')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BudgetScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  BudgetScreenState createState() => BudgetScreenState();
}

class BudgetScreenState extends State<BudgetScreen> {
  double _income = 0.0;
  double _expenses = 0.0;
  double _savingsGoal = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내역 조회'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '수익',
              style: TextStyle(fontSize: 24.0),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '지출',
              style: TextStyle(fontSize: 24.0),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Savings Goal',
              style: TextStyle(fontSize: 24.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter your savings goal',
              ),
              onChanged: (value) {
                setState(() {
                  _savingsGoal = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Total Remaining',
              style: TextStyle(fontSize: 24.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '\$${(_income - _expenses).toStringAsFixed(2)}',
              style:
                  const TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Savings Progress',
              style: TextStyle(fontSize: 24.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LinearProgressIndicator(
              value: _income == 0.0 ? 0.0 : _expenses / _income,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExtraBudgetScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ExtraBudgetScreen extends StatelessWidget {
  const ExtraBudgetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자산 상세 정보'),
      ),
      body: const Center(
        child: Text('금액'),
      ),
    );
  }
}

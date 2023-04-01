import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './widgets/chart.dart';
import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import 'models/transaction.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      home: const MyHomePage(),
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'OpenSans',
        textTheme: ThemeData.light().textTheme.copyWith(
              titleMedium: const TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              labelLarge: const TextStyle(color: Colors.white),
            ),
        appBarTheme: AppBarTheme(
          toolbarTextStyle: ThemeData.light()
              .textTheme
              .copyWith(
                titleMedium: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
              .bodyMedium,
          titleTextStyle: ThemeData.light()
              .textTheme
              .copyWith(
                titleMedium: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
              .titleLarge,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransaction = [];

  List<Transaction> get _recentTransactions {
    return _userTransaction.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  bool _showChart = false;

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
    );
    setState(() {
      _userTransaction.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: NewTransaction(_addNewTransaction),
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransaction.removeWhere((tx) => tx.id == id);
    });
  }

  // Widget _buildLandscapeContent(){
  //
  // }
  //
  // Widget _buildPortraitContent(){
  //
  // }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final landScape = mediaQuery.orientation == Orientation.landscape;
    final curScaleFactor = mediaQuery.textScaleFactor;
    final PreferredSizeWidget appBar = (Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text('Personal Expenses'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                    child: Icon(CupertinoIcons.add),
                    onTap: () => _startAddNewTransaction(context))
              ],
            ))
        : AppBar(
            title: Text('Personal Expenses'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              ),
            ],
          )) as PreferredSizeWidget;
    final txListWidget = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(_userTransaction, _deleteTransaction),
    );

    Container chartAboveList(double height) {
      return Container(
        height: (MediaQuery.of(context).size.height -
                appBar.preferredSize.height -
                MediaQuery.of(context).padding.top) *
            height,
        child: Chart(_recentTransactions),
      );
    }

    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (landScape)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('show Chart',style:Theme.of(context).textTheme.titleSmall),
                  Switch.adaptive(
                    activeColor: Colors.orange,
                    value: _showChart,
                    onChanged: (val) => setState(() {
                      _showChart = val;
                    }),
                  )
                ],
              ),
            if (!landScape) chartAboveList(0.3),
            if (!landScape) txListWidget,
            if (landScape) _showChart ? chartAboveList(0.7) : txListWidget
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar as ObstructingPreferredSizeWidget,
          )
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    onPressed: () => _startAddNewTransaction(context),
                    backgroundColor: Colors.amber,
                    child: const Icon(Icons.add),
                  ),
          );
  }
}
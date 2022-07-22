import 'package:bucker/models/transaction.dart';
import 'package:bucker/widgets/transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../boxes.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  static const _color = const Color(0xff008037);

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              backgroundColor: _color,
              title: Text("Bucker"),
              centerTitle: true,
            ),
            body: ValueListenableBuilder<Box<Transaction>>(
              valueListenable: Boxes.getTransactions().listenable(),
              builder: (context, box, _) {
                final _transactions = box.values.toList().cast<Transaction>();
                _transactions.sort(
                  (transaction1, transaction2) => transaction2.createdDate
                      .compareTo(transaction1.createdDate),
                );

                return _buildContents(_transactions);
              },
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: _color,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return TransactionDialog(
                      onClickedDone: _addTransaction,
                    );
                  },
                );
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContents(List<Transaction> transactions) {
    if (transactions.length == 0) {
      return Center(
        child: Text(
          "Bucker is Empty",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      final netExpense = transactions.fold<double>(
        0,
        (previousValue, transaction) => transaction.isExpense
            ? previousValue - transaction.amount
            : previousValue + transaction.amount,
      );

      final color = netExpense > 0 ? _color : Colors.red;
      return Padding(
        padding: EdgeInsets.only(top: 25),
        child: Column(
          children: <Widget>[
            Text(
              "Net Expenses : ₹ $netExpense",
              style: TextStyle(
                color: color,
                fontSize: 25,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];

                  return _buildTransactions(context, transaction);
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTransactions(BuildContext context, Transaction transaction) {
    final color = transaction.isExpense ? Colors.red : Colors.green;
    final date = DateFormat.yMMMd().format(transaction.createdDate);
    final amount = "₹ ${transaction.amount}";
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        color: Colors.white,
        child: ExpansionTile(
          title: Text(
            transaction.name,
            maxLines: 2,
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            date,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          trailing: Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          children: [
            _buildButtons(context, transaction),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, Transaction transaction) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextButton.icon(
            label: Text(
              'Edit',
              style: TextStyle(
                color: _color,
              ),
            ),
            icon: Icon(
              Icons.edit,
              color: _color,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return TransactionDialog(
                    transaction: transaction,
                    onClickedDone: (name, amount, isExpense) =>
                        _editTransaction(transaction, name, amount, isExpense),
                  );
                },
              );
            },
          ),
        ),
        Expanded(
          child: TextButton.icon(
            label: Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              _deleteTransaction(transaction);
            },
          ),
        ),
      ],
    );
  }

  Future _addTransaction(String name, double amount, bool isExpense) async {
    final transaction = Transaction()
      ..name = name
      ..amount = amount
      ..isExpense = isExpense
      ..createdDate = DateTime.now();

    final box = Boxes.getTransactions();
    box.add(transaction);
  }

  void _editTransaction(
    Transaction transaction,
    String name,
    double amount,
    bool isExpense,
  ) {
    transaction.name = name;
    transaction.amount = amount;
    transaction.createdDate = DateTime.now();
    transaction.isExpense = isExpense;

    // because we have extended Hive Object to model class
    transaction.save();
  }

  void _deleteTransaction(Transaction transaction) {
    // because we have extended Hive Object to model class
    transaction.delete();
  }
}

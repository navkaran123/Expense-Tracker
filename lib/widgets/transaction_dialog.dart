import 'package:bucker/models/transaction.dart';
import 'package:flutter/material.dart';

class TransactionDialog extends StatefulWidget {
  final Transaction? transaction;
  final Function(String name, double amount, bool isExpense) onClickedDone;

  const TransactionDialog({
    Key? key,
    this.transaction,
    required this.onClickedDone,
  }) : super(key: key);

  @override
  _TransactionDialogState createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  bool isExpense = true;

  static const _color = const Color(0xff008037);

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    final title = isEditing ? 'Edit Transaction' : 'Add Transaction';

    if (widget.transaction != null) {
      nameController.text = widget.transaction!.name;
      amountController.text = "${widget.transaction!.amount}";
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        title,
        style: TextStyle(color: _color),
      ),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _buildName(),
              SizedBox(height: 8),
              _buildAmount(),
              SizedBox(height: 8),
              _buildRadioButtons(),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        _buildCancelButton(context),
        _buildAddButton(context, isEditing: isEditing),
      ],
    );
  }

  Widget _buildName() {
    return TextFormField(
      controller: nameController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: _color,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: _color,
            width: 2.0,
          ),
        ),
        hintText: 'Enter Name',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a name';
        }
      },
    );
  }

  Widget _buildAmount() {
    return TextFormField(
      controller: amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: _color,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: _color,
            width: 2.0,
          ),
        ),
        hintText: 'Enter a amount',
      ),
      validator: (value) {
        if (value != null && double.tryParse(value) == null) {
          return 'Please enter a amount';
        }
      },
    );
  }

  Widget _buildRadioButtons() => Column(
        children: [
          RadioListTile<bool>(
            activeColor: _color,
            title: Text('Expense'),
            value: true,
            groupValue: isExpense,
            onChanged: (value) => setState(() => isExpense = value!),
          ),
          RadioListTile<bool>(
            activeColor: _color,
            title: Text('Income'),
            value: false,
            groupValue: isExpense,
            onChanged: (value) => setState(() => isExpense = value!),
          ),
        ],
      );

  Widget _buildCancelButton(BuildContext context) => TextButton(
        child: Text(
          'Cancel',
          style: TextStyle(
            color: _color,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      );

  Widget _buildAddButton(BuildContext context, {required bool isEditing}) {
    final text = isEditing ? 'Save' : 'Add';

    return TextButton(
      child: Text(
        text,
        style: TextStyle(
          color: _color,
        ),
      ),
      onPressed: () async {
        final isValid = formKey.currentState!.validate();

        if (isValid) {
          final name = nameController.text;
          final amount = double.tryParse(amountController.text) ?? 0;

          widget.onClickedDone(name, amount, isExpense);

          Navigator.of(context).pop();
        }
      },
    );
  }
}

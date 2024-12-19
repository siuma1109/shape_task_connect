import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class YearMonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstAllowedDay;
  final DateTime lastAllowedDay;

  const YearMonthPickerDialog({
    super.key,
    required this.initialDate,
    required this.firstAllowedDay,
    required this.lastAllowedDay,
  });

  @override
  State<YearMonthPickerDialog> createState() => _YearMonthPickerDialogState();
}

class _YearMonthPickerDialogState extends State<YearMonthPickerDialog> {
  late DateTime tempDate;

  @override
  void initState() {
    super.initState();
    tempDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Month & Year'),
      content: SizedBox(
        height: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                scrollController: FixedExtentScrollController(
                  initialItem: tempDate.year - widget.firstAllowedDay.year,
                ),
                onSelectedItemChanged: (int index) {
                  setState(() {
                    tempDate = DateTime(
                      widget.firstAllowedDay.year + index,
                      tempDate.month,
                    );
                  });
                },
                children: List<Widget>.generate(
                  widget.lastAllowedDay.year - widget.firstAllowedDay.year + 1,
                  (int index) => Center(
                    child: Text(
                      (widget.firstAllowedDay.year + index).toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                scrollController: FixedExtentScrollController(
                  initialItem: tempDate.month - 1,
                ),
                onSelectedItemChanged: (int index) {
                  setState(() {
                    tempDate = DateTime(tempDate.year, index + 1);
                  });
                },
                children: List<Widget>.generate(
                  12,
                  (int index) => Center(
                    child: Text(
                      DateFormat('MMMM').format(DateTime(2024, index + 1)),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, tempDate),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

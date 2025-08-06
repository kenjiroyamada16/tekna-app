import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    final digits = newText.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    var selectionIndex = newValue.selection.end;

    for (var i = 0; i < digits.length && i < 8; i++) {
      buffer.write(digits[i]);

      if (i == 3 || i == 5) {
        if (i == digits.length - 1) continue;

        buffer.write('/');

        if (i < selectionIndex) selectionIndex++;
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(
        offset: selectionIndex > buffer.length ? buffer.length : selectionIndex,
      ),
    );
  }
}

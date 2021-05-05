import 'package:flutter/material.dart';

enum _State {
  text,
  bracket,
  code
}
class AnsiParser {
 

  final bool dark;

  AnsiParser(this.dark);

  Color? _foreground;
  Color? _background;
  List<TextSpan>? _spans;
  List<TextSpan> get spans => _spans ?? <TextSpan>[];

  void parse(String s) {
    final spans = <TextSpan>[];
    _spans = spans;
    var state = _State.text;
    StringBuffer? buffer;
    final text = StringBuffer();
    var code = 0;
    List<int>? codes;
    for (final c in s.characters) {

      switch (state) {
        case _State.text:
          if (c == '\u001b') {
            state = _State.bracket;
            buffer = StringBuffer(c);
            code = 0;
            codes = <int>[];
          } else {
            text.write(c);
          }
          break;

        case _State.bracket:
          buffer!.write(c);
          if (c == '[') {
            state = _State.code;
          } else {
            state = _State.text;
            text.write(buffer);
          }
          break;

        case _State.code:
          buffer!.write(c);
          final codeUnit = c.codeUnitAt(0);
          if (codeUnit >= 48 && codeUnit <= 57) {
            code = code * 10 + codeUnit - 48;
            continue;
          } else if (c == ';') {
            codes!.add(code);
            code = 0;
            continue;
          } else {
            if (text.isNotEmpty) {
              spans.add(createSpan(text.toString()));
              text.clear();
            }
            state = _State.text;
            if (c == 'm') {
              codes!.add(code);
              handleCodes(codes);
            } else {
              text.write(buffer);
            }
          }

          break;
      }
    }

    spans.add(createSpan(text.toString()));
  }

  void handleCodes(List<int> codes) {
    if (codes.isEmpty) {
      codes.add(0);
    }

    switch (codes[0]) {
      case 0:
        _foreground = getColor(0, true);
        _background = getColor(0, false);
        break;
      case 38:
        _foreground = getColor(codes[2], true);
        break;
      case 39:
        _foreground = getColor(0, true);
        break;
      case 48:
        _background = getColor(codes[2], false);
        break;
      case 49:
        _background = getColor(0, false);
        break;
      default:
        break;
    }
  }

  Color? getColor(int colorCode, bool foreground) {
    switch (colorCode) {
      case 0:
        return foreground ? Colors.black : Colors.transparent;
      case 12:
        return dark ? Colors.lightBlue[300]! : Colors.indigo[700]!;
      case 208:
        return dark ? Colors.orange[300]! : Colors.orange[700]!;
      case 196:
        return dark ? Colors.red[300]! : Colors.red[700]!;
      case 199:
        return dark ? Colors.pink[300]! : Colors.pink[700]!;
      default:
        return null;
    }
  }

  TextSpan createSpan(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: _foreground,
        backgroundColor: _background,
      ),
    );
  }
}

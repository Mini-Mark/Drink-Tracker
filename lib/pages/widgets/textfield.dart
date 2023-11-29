import 'package:drinktracker/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final Color fillColor;
  final Color focusColor;
  final TextEditingController controller;
  final bool isNumber;
  final int? maxLength;
  final Function(String value)? onChange;
  final FocusNode? focusNode;

  const CustomTextField({
    Key? key,
    required this.labelText,
    required this.controller,
    this.fillColor = grey,
    this.focusColor = secondary,
    this.isNumber = false,
    this.maxLength,
    this.onChange,
    this.focusNode,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      onChanged: ((value) {
        setState(() {});
        if (widget.onChange != null) {
          widget.onChange!(value);
        }
      }),
      keyboardType: widget.isNumber ? TextInputType.number : null,
      inputFormatters:
          widget.isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: dark.withAlpha(150),
        ),
        suffixIcon: widget.controller.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    widget.controller.clear();
                  });
                  if (widget.onChange != null) {
                    widget.onChange!(widget.controller.text);
                  }
                },
                child: Icon(
                  Icons.close,
                  color: dark.withAlpha(150),
                  size: 20,
                ),
              )
            : null,
        fillColor: widget.fillColor,
        filled: true,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusColor: widget.focusColor,
        counterText: '',
        counterStyle: TextStyle(fontSize: 0, height: 0),
      ),
    );
  }
}

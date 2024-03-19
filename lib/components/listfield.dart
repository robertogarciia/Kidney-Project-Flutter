import 'package:flutter/material.dart';

class ListField extends StatefulWidget {
  final List<String> items;
  final String? value;
  final String hintText;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  const ListField({
    Key? key,
    required this.items,
    required this.value,
    required this.hintText,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  _ListFieldState createState() => _ListFieldState();
}

class _ListFieldState extends State<ListField> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: widget.value,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
      onChanged: widget.onChanged,
      validator: widget.validator,
      items: widget.items
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          })
          .toList(),
    );
  }
}

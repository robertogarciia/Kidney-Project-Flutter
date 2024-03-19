import 'package:flutter/material.dart';

class ListField extends StatefulWidget {
  final List<String> items;
  final String? value;
  final String hintText;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller; 

  const ListField({
    Key? key,
    required this.items,
    required this.value,
    required this.hintText,
    required this.onChanged,
    this.validator,
    this.controller,
  }) : super(key: key);

  @override
  _ListFieldState createState() => _ListFieldState();
}

class _ListFieldState extends State<ListField> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = widget.controller ?? TextEditingController();
    _textEditingController.text = widget.value ?? '';
  }

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
      onChanged: (newValue) {
        widget.onChanged(newValue);
        _textEditingController.text = newValue ?? '';
      },
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

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

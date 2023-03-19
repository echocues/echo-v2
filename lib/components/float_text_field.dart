import 'package:flutter/material.dart';

class FloatTextField extends StatefulWidget {
  final double value;
  final Function(double)? onChanged;
  final String label;

  const FloatTextField({super.key, required this.value, this.onChanged, required this.label});

  @override
  State<FloatTextField> createState() => _FloatTextFieldState();
}

class _FloatTextFieldState extends State<FloatTextField> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _controller.text = widget.value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: widget.label,
        ),
        onChanged: (value) {
          if (!_formKey.currentState!.validate()) {
            return;
          }
          if (widget.onChanged != null) {
            widget.onChanged!(double.tryParse(value) ?? 0.0);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid float value';
          }
          return null;
        },
      ),
    );
  }
}
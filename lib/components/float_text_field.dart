import 'package:flutter/material.dart';

typedef Validator<T> = T? Function(String);

class ValidatedTextField<T> extends StatefulWidget {
  
  final T value;
  final Function(T)? onChanged;
  final String label;
  final Validator<T> validator;

  const ValidatedTextField({super.key, required this.value, this.onChanged, required this.label, required this.validator});

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
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
            widget.onChanged!(widget.validator(value) ?? 0.0);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          if (widget.validator(value) == null) {
            return 'Please enter a valid float value';
          }
          return null;
        },
      ),
    );
  }
}
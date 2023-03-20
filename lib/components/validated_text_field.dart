import 'package:flutter/material.dart';

typedef Validator<T> = T? Function(String);
typedef OnChanged<T> = void Function(T);
typedef ToString<T> = String Function(T);

class ValidatedTextField<T> extends StatefulWidget {
  
  final T value;
  final T defaultValue;
  final OnChanged<T>? onChanged;
  final ToString<T>? convertToString;
  final String label;
  final Validator<T> validator;

  const ValidatedTextField({super.key, required this.value, this.onChanged, required this.label, required this.validator, required this.defaultValue, this.convertToString});

  @override
  State<ValidatedTextField<T>> createState() => _ValidatedTextFieldState<T>();
}

class _ValidatedTextFieldState<T> extends State<ValidatedTextField<T>> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    _controller.text = widget.convertToString == null ? widget.value.toString() : widget.convertToString!(widget.value);
    
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
            widget.onChanged!(widget.validator(value) ?? widget.defaultValue);
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
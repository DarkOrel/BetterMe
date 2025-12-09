import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Basic info step widget (age, height, weight)
class OnboardingBasicInfoStep extends StatelessWidget {
  final int? age;
  final double? height;
  final double? weight;
  final Function(int) onAgeChanged;
  final Function(double) onHeightChanged;
  final Function(double) onWeightChanged;

  const OnboardingBasicInfoStep({
    super.key,
    required this.age,
    required this.height,
    required this.weight,
    required this.onAgeChanged,
    required this.onHeightChanged,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Tell us about yourself',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _InfoField(
              label: 'Age',
              value: age?.toString() ?? '',
              unit: 'years',
              maxLength: 3,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) {
                    onAgeChanged(parsed);
                  }
                }
              },
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            _InfoField(
              label: 'Height',
              value: height?.toStringAsFixed(0) ?? '',
              unit: 'cm',
              maxLength: 3,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && parsed >= 100 && parsed <= 250) {
                    onHeightChanged(parsed.toDouble());
                  }
                }
              },
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            _InfoField(
              label: 'Weight',
              value: weight?.toStringAsFixed(0) ?? '',
              unit: 'kg',
              maxLength: 3,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && parsed >= 30 && parsed <= 300) {
                    onWeightChanged(parsed.toDouble());
                  }
                }
              },
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatefulWidget {
  final String label;
  final String value;
  final String unit;
  final Function(String) onChanged;
  final TextInputType keyboardType;
  final int maxLength;

  const _InfoField({
    required this.label,
    required this.value,
    required this.unit,
    required this.onChanged,
    required this.keyboardType,
    required this.maxLength,
  });

  @override
  State<_InfoField> createState() => _InfoFieldState();
}

class _InfoFieldState extends State<_InfoField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_InfoField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        suffixText: widget.unit,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}





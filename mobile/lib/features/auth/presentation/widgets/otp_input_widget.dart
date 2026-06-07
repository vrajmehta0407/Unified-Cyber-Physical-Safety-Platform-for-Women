import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class OtpInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onCompleted;

  const OtpInputWidget({super.key, required this.controller, this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      style: const TextStyle(fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.bold),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        counterText: '',
        hintText: '------',
        hintStyle: TextStyle(color: AppColors.border, letterSpacing: 12),
      ),
      onChanged: (value) {
        if (value.length == 6) onCompleted?.call(value);
      },
    );
  }
}

import 'package:flutter/material.dart';

class QuickResetDialog extends StatelessWidget {
  final String title;
  final String message;

  const QuickResetDialog({
    super.key,
    required this.title,
    required this.message,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => QuickResetDialog(title: title, message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final secondaryTextColor = isDark ? const Color(0xFFAEAEB2) : const Color(0xFF3A3A3C);
    final brandButtonBg = isDark ? const Color(0xFF0A84FF) : const Color(0xFF0C3866);

    return AlertDialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal', style: TextStyle(color: Color(0xFF8E8E93))),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: brandButtonBg,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Ya, Reset'),
        ),
      ],
    );
  }
}

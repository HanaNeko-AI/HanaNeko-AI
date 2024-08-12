import 'package:flutter/material.dart';

class TranslationInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final FocusNode textFieldFocusNode = FocusNode();

  TranslationInput({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside the TextField
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: controller,
                  focusNode: textFieldFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Enter translation',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 1,
                  onTap: () {
                    // Only request focus explicitly if needed
                    textFieldFocusNode.requestFocus();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                FocusScope.of(context).unfocus(); // Dismiss the keyboard
                onSubmit(); // Call the onSubmit callback
              },
              icon: const Icon(Icons.translate),
              label: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

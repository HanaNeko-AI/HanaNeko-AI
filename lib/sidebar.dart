import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Sidebar extends StatelessWidget {
  final String sourceLanguage;
  final String targetLanguage;
  final Function(String?) onSourceLanguageChanged;
  final Function(String?) onTargetLanguageChanged;
  final String inputMethod;
  final Function(String) onInputMethodChanged;

  const Sidebar({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onSourceLanguageChanged,
    required this.onTargetLanguageChanged,
    required this.inputMethod,
    required this.onInputMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[100],
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.mochiyPopOne(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Customize your learning experience',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildSettingsItem(
              'Source Language',
              DropdownButton<String>(
                value: sourceLanguage,
                onChanged: (value) {
                  onSourceLanguageChanged(value);
                },
                items: <String>['English', 'Japanese']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                style: const TextStyle(color: Colors.deepPurple, fontSize: 14),
                underline: Container(
                  height: 1,
                  color: Colors.deepPurpleAccent,
                ),
              ),
            ),
            _buildSettingsItem(
              'Target Language',
              DropdownButton<String>(
                value: targetLanguage,
                onChanged: (value) {
                  onTargetLanguageChanged(value);
                },
                items: <String>['English', 'Japanese']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                style: const TextStyle(color: Colors.deepPurple, fontSize: 14),
                underline: Container(
                  height: 1,
                  color: Colors.deepPurpleAccent,
                ),
              ),
            ),
            _buildToggleLanguagesButton(context),
            _buildSettingsItem(
              'Input Method',
              _buildInputMethodToggleButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, Widget trailing) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildToggleLanguagesButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 66.0, vertical: 20.0),
      child: ElevatedButton(
        onPressed: () {
          onSourceLanguageChanged(targetLanguage);
          onTargetLanguageChanged(sourceLanguage);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Icon(Icons.switch_right),
      ),
    );
  }

  Widget _buildInputMethodToggleButton() {
    return IconButton(
      color: Colors.white,
      highlightColor: Colors.white38,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
      ),
      icon: Icon(
        inputMethod == 'Audio' ? Icons.mic : Icons.keyboard,
        // color: Colors.deepPurple,
      ),
      onPressed: () {
        final newMethod = inputMethod == 'Audio' ? 'Text' : 'Audio';
        onInputMethodChanged(newMethod);
      },
      tooltip: 'Toggle Input Method',
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(),
      iconSize: 24,
    );
  }
}

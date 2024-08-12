import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'language_learning_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HanaNeko',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900],
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            color: Colors.blueGrey[800],
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
      home: const LanguageLearningPage(),
    );
  }
}

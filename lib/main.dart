import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mediquery/screens/home_screen.dart';
import 'package:mediquery/screens/dashboard_screen.dart';
import 'package:mediquery/screens/about_screen.dart';
import 'package:mediquery/screens/contact_screen.dart';

void main() {
  // Disable Impeller for emulators / software rendering
  if (!kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    // debugDisableImpeller = true; // Impeller safe mode
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediQuery',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/about': (context) => const AboutScreen(),
        '/contact': (context) => const ContactScreen(),
      },
    );
  }
}
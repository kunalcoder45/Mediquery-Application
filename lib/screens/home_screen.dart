import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _widthAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 0.85), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.85, end: 0.8), weight: 1),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onGetStartedPressed() {
    // Navigate to DashboardScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 450,
              width: double.infinity,
              child: Image.asset(
                'assets/images/doctor.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome To Mediquery!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Feeling Unwell? Talk to MediQuery.",
              style: TextStyle(
                fontSize: 24,
                color: isDark ? Colors.greenAccent : Colors.green[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(10), // yahan space define karo
              child: const Text(
                "Describe your symptoms and get instant medicine suggestions with nearby pharmacy info. "
                "MediQuery is your smart companion for quick health guidance.",
              style: TextStyle(
              fontSize: 22,
            ),
          ),
          ),

            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _widthAnim,
              builder: (context, child) {
                return GestureDetector(
                  onTap: _onGetStartedPressed,
                  child: Container(
                    width: MediaQuery.of(context).size.width * _widthAnim.value,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1C1C1C), Color(0xFF47A14A)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "GET STARTED",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

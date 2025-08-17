import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/navigation_dock.dart' show NavigationDock;

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Common card decoration
    BoxDecoration cardDecoration(Color? bgColor) => BoxDecoration(
      color: bgColor ?? (isDark ? Colors.grey[850] : Colors.green[50]),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
      ],
    );

    TextStyle headerStyle(Color color) =>
        TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color);

    TextStyle bodyStyle = TextStyle(
      fontSize: 16,
      height: 1.5,
      color: isDark ? Colors.white70 : Colors.black87,
    );

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Icon(
                  Icons.info_rounded,
                  size: 80,
                  color: isDark ? Colors.greenAccent : Colors.green[800],
                ),
                const SizedBox(height: 20),
                Text(
                  "About MediQuery",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.greenAccent : Colors.green[800],
                  ),
                ),
                const SizedBox(height: 16),
                // Sections
                _buildIconCard(
                  icon: Icons.lightbulb_outline,
                  title: "Our Mission",
                  text:
                      "MediQuery aims to provide accessible and preliminary health guidance by leveraging the power of artificial intelligence. We understand that feeling unwell can be stressful, and finding quick, understandable information is crucial. Our chatbot is designed to analyze your described symptoms and suggest potential over-the-counter remedies, along with helping you find nearby pharmacies.",
                  decoration: cardDecoration(null),
                  headerStyle: headerStyle(
                    isDark ? Colors.greenAccent : Colors.green[800]!,
                  ),
                  bodyStyle: bodyStyle,
                ),
                const SizedBox(height: 16),
                _buildIconCard(
                  icon: Icons.group_outlined,
                  title: "How It Works",
                  text:
                      "1. Describe Your Symptoms: Simply tell our chatbot how you're feeling in natural language.\n\n"
                      "2. AI Analysis: Our advanced AI model processes your input to identify patterns and potential concerns.\n\n"
                      "3. Medicine Suggestions: Based on the analysis, MediQuery suggests over-the-counter medicines, including dosage information and common uses.\n\n"
                      "4. Find Nearby Pharmacies: If you wish, MediQuery can help you locate pharmacies in your vicinity where you might find these medicines.",
                  decoration: cardDecoration(null),
                  headerStyle: headerStyle(
                    isDark ? Colors.greenAccent : Colors.green[800]!,
                  ),
                  bodyStyle: bodyStyle,
                ),
                const SizedBox(height: 16),
                _buildIconCard(
                  icon: Icons.info_outline,
                  title: "Responsible Usage & Disclaimer",
                  text:
                      "MediQuery is not a substitute for professional medical advice, diagnosis, or treatment.\n\n"
                      "The information provided by MediQuery is for informational purposes only.\n"
                      "Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.\n"
                      "Never disregard professional medical advice or delay in seeking it because of something you have read or heard from MediQuery.\n"
                      "If you think you may have a medical emergency, call your doctor or emergency services immediately.\n"
                      "Reliance on any information provided by MediQuery is solely at your own risk.",
                  decoration: cardDecoration(Colors.red[50]),
                  headerStyle: headerStyle(Colors.red),
                  bodyStyle: bodyStyle.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 16),
                _buildIconCard(
                  icon: Icons.security_rounded,
                  title: "Our Commitment",
                  text:
                      "We are committed to providing a helpful and user-friendly tool. We continuously work on improving our AI models and user experience. Your privacy is important to us; please review our Privacy Policy for details on how we handle your data.",
                  decoration: cardDecoration(null),
                  headerStyle: headerStyle(
                    isDark ? Colors.greenAccent : Colors.green[800]!,
                  ),
                  bodyStyle: bodyStyle,
                ),
                const SizedBox(height: 16),
                _buildDeveloperCard(context),
                const SizedBox(height: 120), // Space so dock doesn't cover
              ],
            ),
          ),
          // Bottom Dock
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: NavigationDock(
                  currentIndex: 1, // About active
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        Navigator.pushNamed(context, '/dashboard');
                        break;
                      case 1:
                        break;
                      case 2:
                        Navigator.pushNamed(context, '/contact');
                        break;
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconCard({
    required IconData icon,
    required String title,
    required String text,
    required BoxDecoration decoration,
    required TextStyle headerStyle,
    required TextStyle bodyStyle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: decoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: headerStyle.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: headerStyle),
                const SizedBox(height: 6),
                Text(text, style: bodyStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.green[50], // ← dark/light bg
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.computer,
            size: 28,
            color: isDark ? Colors.greenAccent : Colors.green[800],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Developer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.greenAccent : Colors.green[800],
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    const url = "https://kunalportfolio45.netlify.app";
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                  child: Text(
                    "Kunal Sharma",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

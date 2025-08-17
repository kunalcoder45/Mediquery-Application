import 'package:flutter/material.dart';
import '../widgets/navigation_dock.dart' show NavigationDock;
import 'chat_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                // Hero Section
                Container(
                  margin: const EdgeInsets.only(top: 32),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/hero.png',
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Feeling Unwell? Talk to MediQuery.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.greenAccent : Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Describe your symptoms and get instant medicine suggestions with nearby pharmacy info. MediQuery is your smart companion for quick health guidance.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.green[400] : Colors.green,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          "Go to Chat",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Features Section
                Column(
                  children: [
                    Text(
                      "How MediQuery Helps You",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.greenAccent : Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Get quick, AI-powered suggestions for your health concerns and find help nearby.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        FeatureCard(
                          icon: Icons.chat_bubble_outline,
                          title: "Symptom Analysis",
                          description:
                              "Describe your symptoms in plain language and our AI will provide potential insights.",
                        ),
                        const SizedBox(height: 12),
                        FeatureCard(
                          icon: Icons.location_on_outlined,
                          title: "Medicine Suggestions",
                          description:
                              "Receive suggestions for over-the-counter medications relevant to your symptoms.",
                        ),
                        const SizedBox(height: 12),
                        FeatureCard(
                          icon: Icons.medical_services_outlined,
                          title: "Nearby Pharmacies",
                          description:
                              "Locate pharmacies near you to quickly find the suggested medications.",
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // CTA Section
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 120, // Extra space for dock
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Ready to Get Started?",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.greenAccent : Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Click the button below to start a chat with MediQuery and find the guidance you need.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
                        label: const Text(
                          "Chat with MediQuery",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.green[400] : Colors.green,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Dock
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: NavigationDock(
                  currentIndex: 0, // Home is active
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        Navigator.pushNamed(context, '/dashboard');
                        break;
                      case 1:
                        // Navigate to About
                        Navigator.pushNamed(context, '/about');
                        break;
                      case 2:
                        // Navigate to Contact
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
}

// FeatureCard remains the same
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            size: 32, 
            color: isDark ? Colors.greenAccent : Colors.green
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14, 
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
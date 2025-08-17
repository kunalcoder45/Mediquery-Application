import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/navigation_dock.dart' show NavigationDock;

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  // TODO: Replace with your actual Web3Forms API key
  final String _apiKey = "408f0b49-e79f-47f0-ad3e-e11724ccc28a";
  
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final url = Uri.parse("https://api.web3forms.com/submit");
      
      // Create form data
      Map<String, dynamic> formData = {
        "access_key": _apiKey,
        "subject": "New Feedback from MediQuery App",
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "message": _messageController.text.trim(),
        "from_name": _nameController.text.trim(),
        "reply_to": _emailController.text.trim(),
      };

      print('Sending data: $formData'); // Debug log

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(formData),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (mounted) {
        setState(() => _isSubmitting = false);

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          
          if (responseData['success'] == true) {
            // Success
            Navigator.of(context).pop(); // Close dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Feedback submitted successfully!"),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            
            // Clear form
            _nameController.clear();
            _emailController.clear();
            _messageController.clear();
            _formKey.currentState!.reset();
          } else {
            // API returned error
            _showErrorSnackBar("Failed to submit: ${responseData['message'] ?? 'Unknown error'}");
          }
        } else if (response.statusCode == 422) {
          // Validation error
          final responseData = json.decode(response.body);
          _showErrorSnackBar("Validation error: ${responseData['message'] ?? 'Invalid data'}");
        } else if (response.statusCode == 429) {
          // Rate limit
          _showErrorSnackBar("Rate limit exceeded. Please try again later.");
        } else {
          // Other errors
          _showErrorSnackBar("Failed to submit feedback. Status: ${response.statusCode}");
        }
      }
    } catch (e) {
      print('Error submitting form: $e'); // Debug log
      
      if (mounted) {
        setState(() => _isSubmitting = false);
        
        String errorMessage = "Failed to submit feedback. ";
        if (e.toString().contains('timeout')) {
          errorMessage += "Request timed out. Check your internet connection.";
        } else if (e.toString().contains('SocketException')) {
          errorMessage += "No internet connection.";
        } else {
          errorMessage += "Please try again.";
        }
        
        _showErrorSnackBar(errorMessage);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _openFeedbackForm() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during submission
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              backgroundColor: isDark ? Colors.grey[900] : Colors.green[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Send Feedback",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.greenAccent : Colors.green[800],
                            ),
                          ),
                          if (!_isSubmitting)
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.close,
                                color: isDark ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        enabled: !_isSubmitting,
                        decoration: InputDecoration(
                          labelText: "Name *",
                          hintText: "Enter your full name",
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your name";
                          }
                          if (value.trim().length < 2) {
                            return "Name must be at least 2 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        enabled: !_isSubmitting,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email *",
                          hintText: "Enter your email address",
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your email";
                          }
                          final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _messageController,
                        enabled: !_isSubmitting,
                        decoration: InputDecoration(
                          labelText: "Message *",
                          hintText: "Enter your feedback or message",
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.message),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.white,
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        maxLength: 500,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your message";
                          }
                          if (value.trim().length < 10) {
                            return "Message must be at least 10 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.green[400] : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: _isSubmitting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text("Submitting..."),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.send),
                                    SizedBox(width: 8),
                                    Text(
                                      "Submit Feedback",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (_isSubmitting)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            "Please wait while we submit your feedback...",
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Icon(
                  Icons.contact_mail_rounded,
                  size: 80,
                  color: isDark ? Colors.greenAccent : Colors.green[800],
                ),
                const SizedBox(height: 20),
                Text(
                  "Contact Us",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.greenAccent : Colors.green[800],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Have questions or feedback? We'd love to hear from you!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),

                _buildContactCard(
                  icon: Icons.email_rounded,
                  title: "Email",
                  subtitle: "support@mediquery.com",
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildContactCard(
                  icon: Icons.phone_rounded,
                  title: "Phone",
                  subtitle: "+1 (555) 123-4567",
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildContactCard(
                  icon: Icons.location_on_rounded,
                  title: "Address",
                  subtitle: "123 Health Street, Medical City, MC 12345",
                  isDark: isDark,
                ),
                const SizedBox(height: 40),

                ElevatedButton.icon(
                  onPressed: _openFeedbackForm,
                  icon: const Icon(Icons.feedback_rounded, color: Colors.white),
                  label: const Text(
                    "Send Feedback",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.green[400] : Colors.green,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 28,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
                  ),
                ),
                const SizedBox(height: 240), // bottom padding for dock
              ],
            ),
          ),

          // Dock like Dashboard
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: NavigationDock(
                  currentIndex: 2, // Contact active
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        Navigator.pushNamed(context, '/dashboard');
                        break;
                      case 1:
                        Navigator.pushNamed(context, '/about');
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

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green[600]),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
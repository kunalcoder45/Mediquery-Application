import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../models/medicine.dart';
import '../widgets/medicine_card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatMessage {
  final String id;
  final String type; // 'user' or 'bot'
  final String? text;
  final List<Medicine>? medicines;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.type,
    this.text,
    this.medicines,
    required this.timestamp,
  });
}

class ChatInterface extends StatefulWidget {
  const ChatInterface({Key? key}) : super(key: key);

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  String? _errorMessage;

  GeminiService? service;

  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      
      if (apiKey == null || apiKey.isEmpty) {
        setState(() {
          _errorMessage = "API Key not found. Please add GEMINI_API_KEY to your .env file.";
          messages = [
            ChatMessage(
              id: '1',
              type: 'bot',
              text: "❌ Configuration Error: API Key not found.\n\nPlease:\n1. Create a .env file in your project root\n2. Add: GEMINI_API_KEY=your_api_key\n3. Restart the app",
              timestamp: DateTime.now(),
            ),
          ];
        });
        return;
      }

      service = GeminiService(apiKey: apiKey);
      
      setState(() {
        messages = [
          ChatMessage(
            id: '1',
            type: 'bot',
            text:
                "Hi! I'm your Medicine Assistant. Describe your symptoms and I'll recommend suitable medicines.\nPlease note: Always consult a qualified doctor before taking any medication.",
            timestamp: DateTime.now(),
          ),
        ];
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to initialize: ${e.toString()}";
        messages = [
          ChatMessage(
            id: '1',
            type: 'bot',
            text: "❌ Initialization Error: ${e.toString()}",
            timestamp: DateTime.now(),
          ),
        ];
      });
    }
  }

  void sendMessage() async {
    if (service == null) {
      _showErrorSnackbar("Service not initialized. Please check your configuration.");
      return;
    }

    final inputText = _controller.text.trim();
    if (inputText.isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'user',
      text: inputText,
      timestamp: DateTime.now(),
    );

    setState(() {
      messages.add(userMessage);
      _controller.clear();
      _loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    try {
      final apiMedicines = await service!.fetchMedicines(inputText);

      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'bot',
        text:
            "Based on your symptoms \"$inputText\", here are my medicine recommendations:",
        medicines: apiMedicines,
        timestamp: DateTime.now(),
      );

      setState(() {
        messages.add(botMessage);
        _loading = false;
      });
    } catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'bot',
        text: "Sorry, I couldn't fetch medicines. Error: ${e.toString()}",
        timestamp: DateTime.now(),
      );
      setState(() {
        messages.add(errorMessage);
        _loading = false;
      });
    }

    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          color: isDark ? Colors.black : Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.medical_services,
                color: _errorMessage != null 
                  ? Colors.red 
                  : (isDark ? Colors.greenAccent : Colors.green),
              ),
              const SizedBox(width: 8),
              Text(
                "MediQuery Assistant",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Config Error",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...messages.map((message) {
                  final isUser = message.type == 'user';
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment:
                          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: !isUser && !isDark
                                ? Border.all(color: Colors.blue, width: 1.5)
                                : null,
                          ),
                          child: message.text != null
                              ? (message.text!.contains("Please note:")
                                  ? RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: message.text!.split(
                                              "Please note:",
                                            )[0],
                                            style: TextStyle(
                                              color: isUser
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "Please note:",
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: message.text!.split(
                                              "Please note:",
                                            )[1],
                                            style: TextStyle(
                                              color: isUser
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Text(
                                      message.text!,
                                      style: TextStyle(
                                        color:
                                            isUser ? Colors.white : Colors.black87,
                                      ),
                                    ))
                              : const SizedBox.shrink(),
                        ),
                        if (message.medicines != null)
                          ...message.medicines!.map(
                            (med) => MedicineCard(medicine: med),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                if (_loading)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(width: 8),
                      Text("Analyzing symptoms..."),
                    ],
                  ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: isDark ? Colors.black : Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 3,
                  minLines: 1,
                  enabled: service != null, // Disable if service not initialized
                  decoration: InputDecoration(
                    hintText: service != null 
                      ? "Describe your symptoms..."
                      : "Service not available - check configuration",
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: (_loading || service == null) ? null : sendMessage,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: (service == null) ? Colors.grey : Colors.blue,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
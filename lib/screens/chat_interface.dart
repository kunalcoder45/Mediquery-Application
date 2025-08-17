import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../models/medicine.dart';
import '../widgets/medicine_card.dart';

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

  final GeminiService service = GeminiService(
    apiKey: 'AIzaSyD6mfPDsrLh2pB3LbXNR91BB_zOexma88g',
  );

  List<ChatMessage> messages = [
    ChatMessage(
      id: '1',
      type: 'bot',
      text:
          "Hi! I'm your Medicine Assistant. Describe your symptoms and I'll recommend suitable medicines.\nPlease note: Always consult a qualified doctor before taking any medication.",
      timestamp: DateTime.now(),
    ),
  ];

  void sendMessage() async {
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

    // Scroll to bottom
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    try {
      final apiMedicines = await service.fetchMedicines(inputText);

      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'bot',
        text:
            "Based on your symptoms \"$inputText\", here are my medicine recommendations:",
        medicines: apiMedicines, // No need to cast anymore
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

    // Scroll again
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header
        Container(
          color: isDark ? Colors.black : Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.medical_services,
                color: isDark ? Colors.greenAccent : Colors.green,
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
            ],
          ),
        ),

        // Messages
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
                          isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                !isUser && !isDark
                                    ? Border.all(color: Colors.blue, width: 1.5)
                                    : null,
                          ),
                          // child: Text(
                          //   message.text ?? '',
                          //   style: TextStyle(
                          //     color: isUser ? Colors.white : Colors.black87,
                          //   ),
                          // ),
                          child:
                              message.text != null
                                  ? (message.text!.contains("Please note:")
                                      ? RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  message.text!.split(
                                                    "Please note:",
                                                  )[0],
                                              style: TextStyle(
                                                color:
                                                    isUser
                                                        ? Colors.white
                                                        : Colors.black87,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "Please note:",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  message.text!.split(
                                                    "Please note:",
                                                  )[1],
                                              style: TextStyle(
                                                color:
                                                    isUser
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
                                              isUser
                                                  ? Colors.white
                                                  : Colors.black87,
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

        // Input
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
                  decoration: InputDecoration(
                    hintText: "Describe your symptoms...",
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
                onTap: _loading ? null : sendMessage,
                child: CircleAvatar(
                  radius: 24,
                  // backgroundColor:
                  //     _controller.text.trim().isEmpty || _loading
                  //         ? Colors.grey
                  //         : Colors.blue,
                  backgroundColor: Colors.blue,
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

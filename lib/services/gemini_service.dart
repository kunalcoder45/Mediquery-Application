import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine.dart';

class GeminiService {
  final String apiKey;

  GeminiService({required this.apiKey});

  Future<List<Medicine>> fetchMedicines(String symptoms) async {
    final prompt = '''
You are a medical assistant. Based on these symptoms: "$symptoms", recommend 4-6 over-the-counter medicines.

Return ONLY a JSON array in this exact format (no extra text):
[
  {
    "medicineName": "Cold Relief Tablet",
    "commonUse": "Relieves nasal congestion, runny nose, sneezing, and cough due to common cold",
    "dosage": "Adults and children 12+: 2 tablets every 4-6 hours, max 8 in 24h. Children 6-12: 1 tablet every 4-6 hours, max 4 in 24h",
    "precautions": "Not for children under 6. Avoid if allergic to ingredients",
    "sideEffects": "Drowsiness, dry mouth"
  }
]
''';

    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['candidates'][0]['content']['parts'][0]['text'] ?? '';

      final jsonMatch = RegExp(r'\[[\s\S]*?\]').firstMatch(content);
      if (jsonMatch != null) {
        final List<dynamic> jsonList = jsonDecode(jsonMatch.group(0)!);
        return jsonList.map((item) => Medicine(
          medicineName: item['medicineName'] ?? 'Unknown',
          commonUse: item['commonUse'] ?? 'Not specified',
          dosage: item['dosage'] ?? 'Consult doctor',
          precautions: item['precautions'],
          sideEffects: item['sideEffects'],
        )).toList();
      } else {
        throw Exception("No valid JSON found");
      }
    } else {
      throw Exception("API Error: ${response.statusCode}");
    }
  }
}

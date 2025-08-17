import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/medicine.dart';
import 'store_search_modal.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineCard({Key? key, required this.medicine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final FlutterTts tts = FlutterTts();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  medicine.medicineName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.volume_up,
                  color: isDark ? Colors.blueAccent : Colors.blue,
                  size: 24,
                ),
                onPressed: () async {
                  final tts = FlutterTts();
                  await tts.setLanguage("en-US");
                  await tts.setPitch(1.0);
                  await tts.setSpeechRate(0.4);
                  await tts.speak(medicine.medicineName);
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            medicine.commonUse,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Recommended Dosage: ${medicine.dosage}",
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          if (medicine.precautions != null &&
              medicine.precautions!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              "Precautions: ${medicine.precautions}",
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
          if (medicine.sideEffects != null &&
              medicine.sideEffects!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              "Side Effects: ${medicine.sideEffects}",
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
          // --- Add this new section ---
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.store),
            label: const Text(
              'Find Nearby Stores',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return const StoreSearchModal();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

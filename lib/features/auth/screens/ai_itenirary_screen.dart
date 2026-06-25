import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/ai_service.dart';

class AIItineraryScreen extends StatefulWidget {
  const AIItineraryScreen({super.key});

  @override
  State<AIItineraryScreen> createState() => _AIItineraryScreenState();
}

class _AIItineraryScreenState extends State<AIItineraryScreen> {
  final TextEditingController destinationController =
  TextEditingController();

  final TextEditingController daysController =
  TextEditingController();

  final TextEditingController budgetController =
  TextEditingController();

  final AIService aiService = AIService();

  String travelStyle = "Adventure";
  String generatedItinerary = "";
  bool isLoading = false;

  Future<void> generateItinerary() async {
    if (destinationController.text.isEmpty ||
        daysController.text.isEmpty ||
        budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final itinerary = await aiService.generateItinerary(
        destination: destinationController.text.trim(),
        days: int.parse(daysController.text.trim()),
        budget: budgetController.text.trim(),
        travelStyle: travelStyle,
      );

      setState(() {
        generatedItinerary = itinerary;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveItinerary() async {
    await FirebaseFirestore.instance
        .collection('itineraries')
        .add({
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'destination': destinationController.text.trim(),
      'days': daysController.text.trim(),
      'budget': budgetController.text.trim(),
      'travelStyle': travelStyle,
      'itinerary': generatedItinerary,
      'createdAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Itinerary saved successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Itinerary Generator"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: destinationController,
              decoration: const InputDecoration(
                labelText: "Destination",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Number of Days",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Budget (₹)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: travelStyle,
              decoration: const InputDecoration(
                labelText: "Travel Style",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Adventure",
                  child: Text("Adventure"),
                ),
                DropdownMenuItem(
                  value: "Luxury",
                  child: Text("Luxury"),
                ),
                DropdownMenuItem(
                  value: "Family",
                  child: Text("Family"),
                ),
                DropdownMenuItem(
                  value: "Budget",
                  child: Text("Budget"),
                ),
                DropdownMenuItem(
                  value: "Solo",
                  child: Text("Solo"),
                ),
                DropdownMenuItem(
                  value: "Romantic",
                  child: Text("Romantic"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  travelStyle = value!;
                });
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : generateItinerary,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                  "Generate Itinerary",
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (generatedItinerary.isNotEmpty)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    generatedItinerary,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            if (generatedItinerary.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Itinerary"),
                  onPressed: saveItinerary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
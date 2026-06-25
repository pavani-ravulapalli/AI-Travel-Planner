import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddHotelScreen extends StatefulWidget {
  const AddHotelScreen({super.key});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final hotelNameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  bool loading = false;

  Future<void> addHotel() async {
    try {
      setState(() => loading = true);

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('hotels')
          .add({
        'ownerId': uid,
        'hotelName': hotelNameController.text.trim(),
        'location': locationController.text.trim(),
        'description': descriptionController.text.trim(),
        'pricePerNight':
        double.tryParse(priceController.text) ?? 0,
        'imageUrl': '',
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hotel Added Successfully"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Hotel"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: hotelNameController,
              decoration: const InputDecoration(
                labelText: "Hotel Name",
              ),
            ),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Location",
              ),
            ),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price Per Night",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : addHotel,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Add Hotel"),
            ),
          ],
        ),
      ),
    );
  }
}
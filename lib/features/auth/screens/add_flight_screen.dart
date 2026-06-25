import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFlightScreen extends StatefulWidget {
  const AddFlightScreen({super.key});

  @override
  State<AddFlightScreen> createState() =>
      _AddFlightScreenState();
}

class _AddFlightScreenState
    extends State<AddFlightScreen> {

  final airlineController = TextEditingController();
  final sourceController = TextEditingController();
  final destinationController = TextEditingController();
  final departureController = TextEditingController();
  final arrivalController = TextEditingController();
  final priceController = TextEditingController();

  bool loading = false;

  Future<void> addFlight() async {
    try {
      setState(() => loading = true);

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('flights')
          .add({
        'ownerId': uid,
        'airlineName': airlineController.text.trim(),
        'source': sourceController.text.trim(),
        'destination':
        destinationController.text.trim(),
        'departureTime':
        departureController.text.trim(),
        'arrivalTime':
        arrivalController.text.trim(),
        'price':
        double.tryParse(priceController.text) ?? 0,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Flight Added Successfully"),
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
        title: const Text("Add Flight"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [

              TextField(
                controller: airlineController,
                decoration: const InputDecoration(
                  labelText: "Airline Name",
                ),
              ),

              TextField(
                controller: sourceController,
                decoration: const InputDecoration(
                  labelText: "Source",
                ),
              ),

              TextField(
                controller: destinationController,
                decoration: const InputDecoration(
                  labelText: "Destination",
                ),
              ),

              TextField(
                controller: departureController,
                decoration: const InputDecoration(
                  labelText: "Departure Time",
                ),
              ),

              TextField(
                controller: arrivalController,
                decoration: const InputDecoration(
                  labelText: "Arrival Time",
                ),
              ),

              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : addFlight,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Add Flight"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
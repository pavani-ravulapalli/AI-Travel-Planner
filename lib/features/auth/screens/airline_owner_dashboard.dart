import 'package:flutter/material.dart';
import 'add_flight_screen.dart';

class AirlineOwnerDashboard extends StatelessWidget {
  const AirlineOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Airline Owner Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _buildCard(
              icon: Icons.add,
              title: "Add Flight",
              onTap: () {
                // Navigate to Add Flight Screen
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddFlightScreen(),
                    ),
                  );
                };
              },
            ),
            _buildCard(
              icon: Icons.flight,
              title: "My Flights",
              onTap: () {
                // Navigate to Flight List
              },
            ),
            _buildCard(
              icon: Icons.people,
              title: "Passengers",
              onTap: () {
                // Navigate to Passenger List
              },
            ),
            _buildCard(
              icon: Icons.analytics,
              title: "Analytics",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
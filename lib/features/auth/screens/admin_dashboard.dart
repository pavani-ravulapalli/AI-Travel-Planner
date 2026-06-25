import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [

            _dashboardCard(
              context,
              icon: Icons.people,
              title: "Users",
              onTap: () {
                // Navigate to Users Screen
              },
            ),

            _dashboardCard(
              context,
              icon: Icons.notifications,
              title: "Notifications",
              onTap: () {
                // Navigate to Notification Management
              },
            ),

            _dashboardCard(
              context,
              icon: Icons.hotel,
              title: "Hotels",
              onTap: () {
                // Navigate to Hotel Management
              },
            ),

            _dashboardCard(
              context,
              icon: Icons.flight,
              title: "Flights",
              onTap: () {
                // Navigate to Flight Management
              },
            ),

            _dashboardCard(
              context,
              icon: Icons.analytics,
              title: "Reports",
              onTap: () {},
            ),

            _dashboardCard(
              context,
              icon: Icons.settings,
              title: "Settings",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 45,
              color: Colors.blue,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
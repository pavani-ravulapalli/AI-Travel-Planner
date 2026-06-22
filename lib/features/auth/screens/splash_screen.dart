import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Stack(
    fit: StackFit.expand,
    children: [
    // Background Image
    Image.asset(
    'assets/images/splash.jpg',
    fit: BoxFit.cover,
    ),

    // Optional dark overlay for better text visibility
    Container(
    color: Colors.black.withOpacity(0.5),
    ),

    // Bottom Content
    Positioned(
    left: 24,
    right: 24,
    bottom: 80,
    child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Explore the World',
    style: TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    ),
    ),
    SizedBox(height: 12),
    Text(
    'Discover amazing destinations, plan your trips effortlessly, and create unforgettable memories.',
    style: TextStyle(
    color: Colors.white70,
    fontSize: 16,
    height: 1.5,
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    );
    }
    }



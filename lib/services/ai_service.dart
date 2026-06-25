import 'package:firebase_ai/firebase_ai.dart';

class AIService {
  final model = FirebaseAI.vertexAI(
    location: 'global',
  ).generativeModel(
    model: 'gemini-3.5-flash',
  );

  Future<String> generateItinerary({
    required String destination,
    required int days,
    required String budget,
    required String travelStyle,
  }) async {
    final prompt = '''
Create a detailed travel itinerary.

Destination: $destination
Days: $days
Budget: $budget
Travel Style: $travelStyle

Include:
- Day-wise plan
- Tourist attractions
- Food recommendations
- Transport suggestions
- Estimated daily cost
''';

    final response = await model.generateContent([
      Content.text(prompt),
    ]);

    return response.text ?? "No itinerary generated";
  }


  Future<String> askTravelAssistant(String question) async {
    final response = await model.generateContent([
      Content.text(
        '''
You are Tripzy AI, an expert travel assistant.

Answer the user's travel-related question clearly and concisely.
Help users with:
- Travel planning
- Destinations
- Hotels 
- Flights
- Budget travel
- Transportation
- Tourist Attractions
- Local food recommendations

Question:
$question
''',
      ),
    ]);

    return response.text ?? "Sorry, I couldn't generate a response.";
  }
}
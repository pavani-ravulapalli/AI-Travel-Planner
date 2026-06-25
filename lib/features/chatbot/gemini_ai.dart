/*import 'package:flutter/material.dart';
import 'package:travel_planner_app/features/chatbot/model.dart';
import 'package:intl/intl.dart';
import 'package:firebase_ai/firebase_ai.dart';

class GeminiChatBot extends StatefulWidget {
  const GeminiChatBot({super.key});

  @override
  State<GeminiChatBot> createState() => _GeminiChatBotState();
}

class _GeminiChatBotState extends State<GeminiChatBot> {
  TextEditingController promptController = TextEditingController();
  final model =
  FirebaseAI.vertexAI(location: 'global').generativeModel(model: 'gemini-3.5-flash');


  final List<ModelMessage> prompt = [];

  Future<void> sendMessage() async {
    final message = promptController.text;
    if(message.trim().isEmpty)return;
    //for prompt
    setState(() {
      promptController.clear();
      prompt.add(ModelMessage(isPrompt: true, message: message, time: DateTime.now(),
      ),
      );
    }
    );
    //for respond
    print("button clicked");
    try{
      print("sending:$message");
    final content = [Content.text(message)];
    final response = await model.generateContent(content);
    print("response received");
    print("response.text");
    print("gemini response:${response.text}");
    setState(() {
      prompt.add(ModelMessage(isPrompt: false,
        message: response.text ?? "no response", time: DateTime.now(),
      ),
      );
    }
    );
  }
  catch(e){
    print("gemini error:$e");
  }}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
    appBar: AppBar(
      elevation: 3,
      backgroundColor: Colors.blue[100],
      title: const Text("AI ChatBot"),
    ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: prompt.length,
              itemBuilder: (context,index) {
                final message = prompt[index];
                return UserPrompt(isPrompt: message.isPrompt, message: message.message, date: DateFormat('hh:mm a').format(message.time,
                ),);
              }
              )
          ),
          Padding(padding: EdgeInsets.all(25),
          child: Row(
            children: [
              Expanded(
                flex: 20,
                  child: TextField(
                    controller: promptController,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      hintText: "Enter a prompt here"
                    ),
                  )
              ),
              const Spacer(),
              GestureDetector(onTap: () {
                 sendMessage();
              },
              child: CircleAvatar(
                radius: 29,
                backgroundColor: Colors.green,
                child: Icon(Icons.send,
                color: Colors.white,
                  size: 32,
                ),
              ),
              )
            ],
          ),
          )
        ],
      ),

    );
  }

  Container UserPrompt({
  required final bool isPrompt,
    required String message,
    required String date
  }) {
    return Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.symmetric(vertical: 15).copyWith(left: isPrompt ? 80:15,right: isPrompt?15:80),
                decoration: BoxDecoration(color: isPrompt
                    ?Colors.green
                    :Colors.grey,borderRadius: BorderRadius.only(topLeft: const Radius.circular(20),topRight: const Radius.circular(20),
                bottomLeft: isPrompt?const Radius.circular(20):Radius.zero,
                  bottomRight: isPrompt?Radius.zero:const Radius.circular(20),
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //for prompt and respond
                    Text(message, style: TextStyle(
                        fontWeight: isPrompt
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 18,
                        color: isPrompt
                            ? Colors.white
                            : Colors.black
                    ),
                    ),
                    //for prompt and respond time
                    Text(
                      date,
                      style: TextStyle(

                        fontSize: 18,
                        color: isPrompt
                            ? Colors.white
                            : Colors.black
                    ),
                    )
                  ],
                ),
              );
  }
}*/

import 'package:flutter/material.dart';
import '../../../services/ai_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController messageController =
  TextEditingController();

  final ScrollController scrollController =
  ScrollController();

  final AIService aiService = AIService();

  List<Map<String, dynamic>> messages = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    messages.add({
      'text':
      '👋 Hi! I am Tripzy AI.\n\nAsk me about destinations, itineraries, hotels, flights, budgets, travel tips, and more.',
      'isUser': false,
    });
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    String userMessage = messageController.text.trim();

    setState(() {
      messages.add({
        'text': userMessage,
        'isUser': true,
      });
      isLoading = true;
    });

    messageController.clear();
    scrollToBottom();

    try {
      final aiReply =
      await aiService.askTravelAssistant(userMessage);

      setState(() {
        messages.add({
          'text': aiReply,
          'isUser': false,
        });
      });
    } catch (e) {
      setState(() {
        messages.add({
          'text': 'Error: $e',
          'isUser': false,
        });
      });
    }

    setState(() {
      isLoading = false;
    });

    scrollToBottom();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tripzy AI Assistant"),
        centerTitle: true,
      ),
      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return Align(
                  alignment: message['isUser']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth:
                      MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: message['isUser']
                          ? Colors.blue
                          : Colors.grey.shade300,
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: message['isUser']
                            ? Colors.white
                            : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller: messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText:
                        "Ask about trips, hotels, flights...",
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(25),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  CircleAvatar(
                    radius: 25,
                    child: IconButton(
                      onPressed: isLoading
                          ? null
                          : sendMessage,
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

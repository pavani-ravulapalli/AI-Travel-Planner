import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:travel_planner_app/features/chatbot/model.dart';
import 'package:intl/intl.dart';

class GeminiChatBot extends StatefulWidget {
  const GeminiChatBot({super.key});

  @override
  State<GeminiChatBot> createState() => _GeminiChatBotState();
}

class _GeminiChatBotState extends State<GeminiChatBot> {
  TextEditingController promptController = TextEditingController();
  static const apiKey = "chatbot-key";
  final model = GenerativeModel(model:"gemini-2.5-flash", apiKey:apiKey,);

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
}

import 'package:flutter/material.dart';
import 'package:scribbl_clone/paint_screen.dart';
import 'package:scribbl_clone/widgets/text_field.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController roomName = TextEditingController();

  void joinRoom() {
    if (name.text.isNotEmpty && roomName.text.isNotEmpty) {
      Map<String, dynamic> data = {"nickname": name.text, "name": roomName.text};
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaintScreen(data: data, screenFrom: 'joinRoom'),
        ),
      );
    }
  }

  String? selectedValue;
  String? roomSize;
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Join Room To Play A MindBlowing Game",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 20),
            TextFields(textOnTextField: name, hintText: 'Enter Your Name'),
            SizedBox(height: 20),
            TextFields(textOnTextField: roomName, hintText: 'Enter Room name'),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                ),
                onPressed: joinRoom,
                child: Text(
                  "Join",
                  style: TextStyle(fontSize: 25, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

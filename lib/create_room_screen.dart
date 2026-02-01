import 'package:flutter/material.dart';
import 'package:scribbl_clone/paint_screen.dart';
import 'package:scribbl_clone/widgets/text_field.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController roomName = TextEditingController();

  String? maxRound;
  String? roomSize;
  void createRoom() {
    if (name.text.isNotEmpty &&
        roomName.text.isNotEmpty &&
        maxRound != null &&
        roomSize != null) {
      Map<String, dynamic> data = {
        "nickname": name.text,
        "name": roomName.text,
        "occupancy": ?roomSize,
        "maxRound": ?maxRound,
      };
      Navigator.push(context, MaterialPageRoute(builder: (context) => PaintScreen(data: data, screenFrom: "createRoom")));
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Create Room To Play A MindBlowing Game",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 20),
            TextFields(textOnTextField: name, hintText: 'Enter Your Name'),
            SizedBox(height: 20),
            TextFields(textOnTextField: roomName, hintText: 'Enter Room name'),
            SizedBox(height: 20),
            DropdownButton<String>(
              value:
                  maxRound, // You need a variable to hold the current choice
              items: <String>["2", "5", "10", "15"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value, // The actual data
                  child: Text(value), // What the user sees
                );
              }).toList(), // CRITICAL: Convert Iterable to List
              onChanged: (newValue) {
                setState(() {
                  maxRound = newValue; // Update your state here
                });
              },
              hint: Text(
                "Select the Max Round",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            DropdownButton<String>(
              value: roomSize,
              items: <String>["2", "3", "4", "5", "6", "7"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  roomSize = newValue;
                });
              },
              hint: Text(
                "Select Room Size",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
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
                onPressed: createRoom,
                child: Text(
                  "Create",
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

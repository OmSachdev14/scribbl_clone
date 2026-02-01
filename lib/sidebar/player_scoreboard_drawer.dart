import 'package:flutter/material.dart';

class PlayerScore extends StatelessWidget {
  final List<Map> userData;
  const PlayerScore({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.builder(
        itemCount: userData.length,
        itemBuilder: (context, index) {
          var data = userData[index];
          return ListTile(
            title: Text(
              data['username'].toString(),
              style: TextStyle(color: Colors.black, fontSize: 23),
            ),
            trailing: Text(
              data['points'].toString(),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
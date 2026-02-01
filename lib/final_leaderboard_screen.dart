import 'package:flutter/material.dart';

class FinalLeaderboard extends StatelessWidget {
  final scoreboard;
  final String winner;
  const FinalLeaderboard({
    super.key,
    required this.scoreboard,
    required this.winner,
  });

  @override
  Widget build(BuildContext context) {
    print(scoreboard);
    return Center(
      child: Container(
        padding: EdgeInsets.all(8),
        height: double.maxFinite,
        child: Column(
          children: [
            Text(
              'Final Leaderboard',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Container(color: Colors.green,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '$winner has won the game!',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: scoreboard.length,
                itemBuilder: (context, index) {
                  var data = scoreboard[index];
                  print(data);
                  return ListTile(
                    leading: Text(
                      '${index + 1}.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    title: Text(
                      data['username'], // Changed: direct access
                      style: TextStyle(color: Colors.black, fontSize: 23),
                    ),
                    trailing: Text(
                      data['points'].toString(), // Changed: direct access
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

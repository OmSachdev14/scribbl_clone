import 'dart:async';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:scribbl_clone/final_leaderboard_screen.dart';
import 'package:scribbl_clone/models/my_custom_paiter.dart';
import 'package:flutter/material.dart';
import 'package:scribbl_clone/models/touch_point.dart';
import 'package:scribbl_clone/sidebar/player_scoreboard_drawer.dart';
import 'package:scribbl_clone/waiting_lobby_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String screenFrom;
  const PaintScreen({super.key, required this.data, required this.screenFrom});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;
  Map<String, dynamic>? dataOfRoom;
  List<TouchPoint> points = [];
  StrokeCap stroketype = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  List<Widget> textBlankWidget = [];
  final ScrollController _scrollController = ScrollController();
  List<Map> messages = [];
  TextEditingController messageController = TextEditingController();
  int guessedUserCtr = 0;
  int _start = 60;
  late Timer _timer;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map> scoreboard = [];
  bool isTextInputReadOnly = false;
  int maxPoints = 0;
  String winner = "";
  bool isShowFinalLeaderboard = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connect();
    print(widget.data);
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer time) {
      if (_start == 0) {
        _socket.emit('change-turn', dataOfRoom?['name']);
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(const Text("_", style: TextStyle(fontSize: 30)));
    }
  }

  // Socjet to client connection
  void connect() {
    _socket = IO.io('http://127.0.0.1:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoconnect': false,
    });

    _socket.connect();

    if (widget.screenFrom == "createRoom") {
      _socket.emit('create-game', widget.data);
    } else {
      _socket.emit('join-game', widget.data);
    }
    //we listento socket here
    _socket.on('updateRoom', (roomData) {
      setState(() {
        renderTextBlank(roomData['word']);
        print(roomData['word']);
        dataOfRoom = roomData;
      });
      if (roomData['isJoin'] != true) {
        startTimer();
      }
      scoreboard.clear();
      for (int i = 0; i < roomData['players'].length; i++) {
        setState(() {
          scoreboard.add({
            'username':
                roomData['players'][i]['nickname'], // Fixed: access nickname
            'points': roomData['players'][i]['points']
                .toString(), // Added: points
          });
        });
      }
    });

    _socket.on('points', (point) {
      if (point['details'] != null) {
        setState(() {
          points.add(
            TouchPoint(
              paint: Paint()
                ..strokeCap = stroketype
                ..isAntiAlias = true
                ..color = selectedColor.withOpacity(opacity)
                ..strokeWidth = strokeWidth,
              points: Offset(
                (point['details']['dx']).toDouble(),
                (point['details']['dy']).toDouble(),
              ),
            ),
          );
        });
      }
    });

    _socket.on('color-change', (colorstring) {
      // Ensure we parse as a hex integer
      print(colorstring);
      int value = int.parse(colorstring, radix: 16);
      print(value);
      setState(() {
        // Color expects a 32-bit integer, radix 16 handles the hex conversion
        selectedColor = Color(value);
      });
    });

    _socket.on('stroke-width', (value) {
      setState(() {
        strokeWidth = value;
      });
    });

    _socket.on('clear-all', (clearPoints) {
      setState(() {
        points = [];
      });
    });

    _socket.on('msg-data', (data) {
      setState(() {
        messages.add(data);
        guessedUserCtr = data['guessedUserCtr'];
      });
      if (guessedUserCtr == dataOfRoom!['players'].length - 1) {
        _socket.emit('change-turn', dataOfRoom?['name']);
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 400.00,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });

    _socket.on('updateScore', (roomData) {
      print(roomData);
      scoreboard.clear();
      for (int i = 0; i < roomData['players'].length; i++) {
        setState(() {
          scoreboard.add({
            'username': roomData['players'][i]['nickname'],
            'points': roomData['players'][i]['points'].toString(),
          });
        });
      }
      print('Scoreboard after updateRoom: $scoreboard');
    });

    _socket.on('show-leaderboard', (roomPlayers) {
      scoreboard.clear();
      for (int i = 0; i < roomPlayers.length; i++) {
        setState(() {
          scoreboard.add({
            'username': roomPlayers[i]['nickname'],
            'points': roomPlayers[i]['points'].toString(),
          });
        });
        if (maxPoints < int.parse(scoreboard[i]['points'])) {
          winner = scoreboard[i]['username'];
          maxPoints = int.parse(scoreboard[i]['points']);
        }
      }
      setState(() {
        _timer.cancel();
        isShowFinalLeaderboard = true;
      });
    });

    _socket.on('change-turn', (data) {
      print('=== CHANGE TURN DATA ===');
      print('Full data: $data');
      print('Players: ${data['players']}');
      print('Players type: ${data['players'].runtimeType}');
      if (data['players'] != null && data['players'].length > 0) {
        print('First player: ${data['players'][0]}');
        print('First player type: ${data['players'][0].runtimeType}');
      }
      print('========================');

      String oldWord = dataOfRoom?['word'];
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop();
            setState(() {
              dataOfRoom = data;
              renderTextBlank(data['word']);
              guessedUserCtr = 0;
              points.clear();
              _start = 60;
              isTextInputReadOnly = false;

              // Update scoreboard with new turn data
              scoreboard.clear();
              for (int i = 0; i < data['players'].length; i++) {
                print('Processing player $i: ${data['players'][i]}');
                scoreboard.add({
                  'username': data['players'][i]['nickname'],
                  'points': data['players'][i]['points'].toString(),
                });
              }
              print('Scoreboard after change-turn: $scoreboard');
            });
            _timer.cancel();
            startTimer();
          });
          return AlertDialog(title: Center(child: Text('Word was $oldWord')));
        },
      );
    });

    _socket.on('closeInput', (_) {
      _socket.emit('updateScore', widget.data['name']);
      setState(() {
        isTextInputReadOnly = true;
      });
    });
  }
  @override
  void dispose() {
    _socket.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? width = MediaQuery.of(context).size.width;
    double? height = MediaQuery.of(context).size.height;

    void selectColor() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Choose Color"),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                // Directly get the integer value and convert to Hex String
                String valueString = color.value.toRadixString(16);

                print("Sending Color Hex: $valueString");

                Map map = {
                  'color': valueString,
                  'roomName':
                      dataOfRoom?['name'] ??
                      widget.data['name'], // Fallback to widget data
                };
                _socket.emit("color-change", map);

                // Also update locally so the picker reflects the change immediately
                // setState(() {
                //   selectedColor = color;
                // });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('close'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      drawer: PlayerScore(userData: scoreboard),
      backgroundColor: Colors.white,
      body: dataOfRoom != null
          ? (dataOfRoom?['isJoin'] != true)
                ? !isShowFinalLeaderboard
                      ? Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: width,
                                  height: height * 0.55,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      print(
                                        "continous watching ${details.localPosition.dx}",
                                      );
                                      _socket.emit('paint', {
                                        'details': {
                                          'dx': details.localPosition.dx,
                                          'dy': details.localPosition.dy,
                                        },
                                        'roomName': widget.data['name'],
                                      });
                                    },
                                    onPanStart: (details) {
                                      print(
                                        "start ${details.localPosition.dx}",
                                      );
                                      _socket.emit('paint', {
                                        'details': {
                                          'dx': details.localPosition.dx,
                                          'dy': details.localPosition.dy,
                                        },
                                        'roomName': widget.data['name'],
                                      });
                                    },
                                    onPanEnd: (details) {
                                      print("end ${details.localPosition.dx}");
                                      _socket.emit('paint', {
                                        'details': null,
                                        'roomName': widget.data['name'],
                                      });
                                    },
                                    child: SizedBox.expand(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: RepaintBoundary(
                                          child: CustomPaint(
                                            size: Size.infinite,
                                            painter: MyCustomPaiter(
                                              pointslist: points,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        selectColor();
                                      },
                                      icon: Icon(
                                        Icons.color_lens,
                                        color: selectedColor,
                                      ),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        min: 1.0,
                                        max: 10,
                                        label: "$strokeWidth",
                                        activeColor: selectedColor,
                                        value: strokeWidth,
                                        onChanged: (double value) {
                                          Map map = {
                                            'value': value,
                                            'roomName': dataOfRoom?['name'],
                                          };
                                          _socket.emit('stroke-width', map);
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Map map = {
                                          'points': [],
                                          'roomName': dataOfRoom!['name'],
                                        };
                                        _socket.emit('clear-all', map);
                                      },
                                      icon: Icon(
                                        Icons.layers_clear,
                                        color: selectedColor,
                                      ),
                                    ),
                                  ],
                                ),
                                (dataOfRoom != null &&
                                        dataOfRoom?['turn'] != null &&
                                        dataOfRoom?['turn']['nickname'] !=
                                            widget.data['nickname'])
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: textBlankWidget,
                                      )
                                    : Center(
                                        child: Text(
                                          dataOfRoom?['word'],
                                          style: TextStyle(fontSize: 30),
                                        ),
                                      ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,

                                  child: ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      var msg = messages[index].values;
                                      return ListTile(
                                        title: Text(
                                          '${msg.elementAt(0)},',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${msg.elementAt(1)}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            (dataOfRoom != null &&
                                    dataOfRoom?['turn'] != null &&
                                    dataOfRoom?['turn']['nickname'] !=
                                        widget.data['nickname'])
                                ? // dataOfRoom?['turn']['nickname'] != widget.data['nickname']?
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: TextField(
                                        readOnly: isTextInputReadOnly,
                                        controller: messageController,
                                        autocorrect: false,
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (value) {
                                          if (value.trim().isNotEmpty) {
                                            Map map = {
                                              'username':
                                                  widget.data['nickname'],

                                              'msg': value.trim(),
                                              'roomName': dataOfRoom?['name'],
                                              'word': dataOfRoom?['word'],
                                              'guessedUserCtr': guessedUserCtr,
                                              'totalTime': 60,
                                              'timeTaken': 60 - _start,
                                            };
                                            print(map);
                                            _socket.emit('msg-data', map);
                                            messageController.clear();
                                          }
                                        },
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: const Color.fromARGB(
                                                255,
                                                17,
                                                0,
                                                0,
                                              ),
                                              width: 1.5,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          hintText: 'Your Guess',
                                          hintStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            SafeArea(
                              child: IconButton(
                                onPressed: () =>
                                    scaffoldKey.currentState!.openDrawer(),
                                icon: Icon(Icons.menu, color: Colors.black),
                              ),
                            ),
                          ],
                        )
                      : FinalLeaderboard(scoreboard: scoreboard, winner: winner,)
                : (WaitingLobbyScreen(
                    occupancy: dataOfRoom?['occupancy'],
                    noOfPlayers: dataOfRoom?['players'].length,
                    lobbyName: dataOfRoom?['name'],
                    players: dataOfRoom?['players'],
                  ))
          : (Center(child: CircularProgressIndicator())),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 7,
          backgroundColor: Colors.white,
          child: Text(
            '$_start',
            style: TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
      ),
    );
  }
}

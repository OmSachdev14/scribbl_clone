import express from "express"
import http from "http"
import mongoose from "mongoose";
import { Server } from "socket.io";
import { Room } from "./src/models/room.model.js";
import getWord from "./api/get_word.js";
import dotenv from "dotenv";

dotenv.config();
const app = express()
const port = process.env.PORT || 5000;
var httpserver = http.createServer(app)

const io = new Server(httpserver, {
    cors: {
        origin: "*", // Allows connections from any origin (useful for development)
    }
});

// we use middleware now and you know for middleware we use "app.use()"

app.use(express.json());

const DB = process.env.MONGODB_URL

mongoose.connect(DB).then(() => {
    console.log("Connection Successful!");

}).catch((e) => {
    console.log(e);
})

io.on('connection', (socket) => {
    console.log('connected');
    // in down async we are removing everything in the object by short syntax in js

    // create room call back
    socket.on('create-game', async ({ nickname, name, occupancy, maxRound }) => {
        try {
            const existingRoom = await Room.findOne({ name });
            if (existingRoom) {
                return socket.emit('notCorrectGame', 'Room with that name already exists!');
            }

            // Since you are using SUBDOCUMENTS, you don't necessarily need to 
            // save the player to its own collection first.
            let room = new Room({
                word: getWord(),
                name,
                occupancy,
                maxRound,
                players: [{
                    nickname,
                    socketID: socket.id,
                    isPartyLeader: true
                }]
            });

            // Set the turn to the first player object
            room.turn = room.players[0];

            room = await room.save();
            socket.join(name);
            io.to(name).emit('updateRoom', room);
        } catch (error) {
            console.log("Create Error:", error);
        }
    });


    // join room call back
    socket.on('join-game', async ({ nickname, name }) => {
        try {
            console.log(`Attempting to join room: ${name} with nickname: ${nickname}`);

            let room = await Room.findOne({ name });

            if (!room) {
                console.log("Join Error: Room not found");
                return socket.emit('notCorrectGame', 'Please enter a valid room name');
            }

            if (room.isJoin) {
                let player = {
                    nickname,
                    socketID: socket.id,
                    isPartyLeader: false
                };

                room.players.push(player);

                // Logic check: if room is full, close it
                if (room.players.length >= room.occupancy) {
                    room.isJoin = false;
                }

                // Important: If you don't have a 'turn' yet, set it now
                if (!room.turn) {
                    room.turn = room.players[0];
                }

                room = await room.save();

                // Join the socket room string
                socket.join(name);

                // Emit the FULL updated room object to everyone
                io.to(name).emit('updateRoom', room);
                console.log(`Player ${nickname} joined successfully. Array length: ${room.players.length}`);

            } else {
                console.log("Join Error: Room isJoin is false");
                socket.emit('notCorrectGame', 'The game is already in progress');
            }
        } catch (error) {
            console.error("Critical Join Error:", error);
        }
    });

    socket.on('paint', ({ details, roomName }) => {
        io.to(roomName).emit('points', { details: details });  // instead of doing details: details we can directly write details it is a property of js that if both have same name then just write name i will understand
    });

    socket.on('color-change', ({ color, roomName }) => {
        console.log(color);

        io.to(roomName).emit('color-change', color);
    });

    socket.on('stroke-width', ({ value, roomName }) => {
        io.to(roomName).emit('stroke-width', value);
    });

    socket.on('clear-all', ({ points, roomName }) => {
        io.to(roomName).emit('clear-all', points);
    });

    socket.on('msg-data', async (data) => {
        try {
            if (data.msg == data.word) {
                let room = await Room.find({ 'name': data.roomName });
                let userPlayer = room[0].players.filter(
                    (player) => player.nickname === data.username
                )
                if (userPlayer.length > 0 && data.timeTaken != 0) {
                    userPlayer[0].points += Math.round((200 / data.timeTaken) * 10);
                    room = await room[0].save();
                    io.to(data.roomName).emit('msg-data', {
                        username: data.username,
                        msg: 'Guessed it!',
                        guessedUserCtr: data.guessedUserCtr + 1
                    })
                }
                socket.emit('closeInput', "")
            } else {
                io.to(data.roomName).emit('msg-data', {
                    username: data.username,
                    msg: data.msg,
                    guessedUserCtr: data.guessedUserCtr
                })
            }
        } catch (error) {
            console.log(error.toString());
        }
    });

    socket.on('change-turn', async (name) => {
        try {
            let room = await Room.findOne({ name });
            let idx = room.turnIndex;
            if (idx + 1 === room.players.length) {
                room.currentRound += 1;
            }
            if (room.currentRound <= room.maxRound) {
                const word = getWord()
                room.word = word;
                room.turnIndex = (idx + 1) % room.players.length;
                room.turn = room.players[room.turnIndex];
                room = await room.save();
                io.to(name).emit('change-turn', room);
            } else {
                io.to(name).emit('show-leaderboard', room.players);
                // show the leader board

            }
        } catch (error) {
            console.log(error);
        }
    });

    socket.on('updateScore', async (name) =>  {
        try {
            const room = await Room.findOne({name});
            io.to(name).emit('updateScore', room)
        } catch (error) {
            console.log(error);
            
        }
    });

    socket.on('disconnect', async() => {
        try {
            let room = Room.findOne({"player.socketID": socket.id});
            for(let i=0; i<room.players.length; i++){
                if(room.players[i].socketID === socket.id){
                    room.players.splice(i, 1);
                    break;
                }
            }
            room = await room.save();
            if(room.players.length === 1){
                socket.broadcast.to(room.name).emit('show-leader', room.players);
            }else{
                socket.broadcast.to(room.name).emit('user-disconnected', room);
            }
        } catch (error) {
            console.log(error);
            
        }
    })

})



httpserver.listen(port, "0.0.0.0", () => {
    console.log('Server started and running on port: ' + port);
});
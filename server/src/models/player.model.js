import mongoose from "mongoose";

const playerSchema = new mongoose.Schema({
    nickname: {
        type: String,
        trim: true,
    },
    socketID: {
        type: String,
    },
    isPartyLeader: {
        type: Boolean,
        default: false
    },
    points: {
        type: Number,
        default: 0
    }
},{timestamps: true})

const Player = mongoose.model("Player", playerSchema);
export  {playerSchema, Player}
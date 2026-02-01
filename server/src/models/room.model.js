import mongoose, { Mongoose } from "mongoose";
import {playerSchema,  Player } from "./player.model.js";

const roomSchema = new mongoose.Schema({
    word: {
        type: String,
        required: true,
    },
    name: {
        type: String,
        unique: true,
        required: true,
        trim: true,
    },
    occupancy: {
        type: Number,
        required: true,
        default: 4
    },
    maxRound: {
        type: Number,
        required: true,
    },
    currentRound: {
        type: Number,
        required: true,
        default: 1
    },
    players: [playerSchema
    ],
    isJoin: {
        type: Boolean,
        default: true,
    },
    turn: playerSchema,
    turnIndex: {
        type: Number,
        default: 0
    }
},{timestamps: true})

export const Room = mongoose.model("Room", roomSchema)
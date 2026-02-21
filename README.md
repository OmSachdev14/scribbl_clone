# SocketScribe 🎨

A Flutter-based multiplayer drawing and guessing game inspired by Skribbl.io. Draw, guess, and compete with friends in real-time!

## 📹 Demo

https://github.com/OmSachdev14/scribbl_clone/blob/main/Skribbl%20App%20Working.mp4

> *Watch the app in action! See the complete gameplay featuring drawing, guessing, and real-time multiplayer interaction.*

## 📱 About

Scribbl Clone is a multiplayer online drawing and guessing game built with Flutter and Node.js. Players take turns drawing a chosen word while others attempt to guess it. The faster you guess correctly, the more points you earn!

## ✨ Features

- **Real-time Multiplayer Gameplay** - Play with friends or join public rooms
- **Drawing Tools** - Multiple colors, brush sizes, and drawing utilities
- **Chat System** - Built-in chat for guessing and communication
- **Scoring System** - Points awarded based on speed and accuracy
- **Custom Rooms** - Create private rooms with custom settings
- **Cross-Platform** - Works on Android, iOS, Web, Windows, macOS, and Linux
- **Round-based Gameplay** - Multiple rounds with rotating drawers
- **Word Selection** - Choose from multiple word options when it's your turn

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language

### Backend
- **Node.js** - Server runtime
- **Socket.IO** - Real-time bidirectional communication

## 📋 Prerequisites

Before running this project, make sure you have:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version)
- [Node.js](https://nodejs.org/) (v14 or higher)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended IDEs)

## 🚀 Getting Started

### Backend Setup

1. Navigate to the server directory:
```bash
cd server
```

2. Install dependencies:
```bash
npm install
```

3. Start the server:
```bash
npm start
```

The server will run on `http://localhost:3000` by default.

### Frontend Setup

1. Navigate to the project root directory

2. Get Flutter dependencies:
```bash
flutter pub get
```

3. Update the server URL in the app (if needed):
   - Open the relevant configuration file
   - Update the socket connection URL to match your server address

4. Run the app:
```bash
# For development
flutter run

# For specific platform
flutter run -d chrome        # Web
flutter run -d windows       # Windows
flutter run -d macos         # macOS
flutter run -d linux         # Linux
```

## 🎮 How to Play

1. **Join/Create a Room**
   - Enter your username
   - Join a public room or create a private one

2. **When Drawing**
   - Choose a word from the given options
   - Draw it using the available tools
   - You have 80 seconds per round

3. **When Guessing**
   - Watch the drawing and type your guess in the chat
   - Faster correct guesses earn more points
   - Pay attention to the word hints

4. **Winning**
   - Player with the most points at the end wins!

## 📦 Project Structure
```
scribbl_clone/
├── android/          # Android-specific code
├── ios/              # iOS-specific code
├── lib/              # Flutter application code
├── linux/            # Linux-specific code
├── macos/            # macOS-specific code
├── windows/          # Windows-specific code
├── web/              # Web-specific code
├── server/           # Node.js backend server
├── test/             # Test files
├── pubspec.yaml      # Flutter dependencies
└── README.md         # This file
```

## 🔧 Configuration

### Server Configuration
Edit `server/config.js` (if exists) to configure:
- Port number
- CORS settings
- Room settings
- Word lists

### App Configuration
Edit the Flutter app configuration to set:
- Server URL
- Default settings
- Theme customization

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 TODO

- [ ] Add user authentication
- [ ] Implement custom word lists
- [ ] Add more drawing tools
- [ ] Implement game statistics
- [ ] Add sound effects
- [ ] Support for multiple languages
- [ ] Leaderboard system
- [ ] Replay functionality

## 🐛 Known Issues

- List any known bugs or limitations here

## 📄 License

This project is created for educational purposes. 

## 👨‍💻 Author

**Om Sachdev**
- GitHub: [@OmSachdev14](https://github.com/OmSachdev14)

## 🙏 Acknowledgments

- Inspired by [Skribbl.io](https://skribbl.io/)
- Flutter community
- Socket.IO documentation


**Note:** This is a clone project created for learning purposes. All credit for the original game concept goes to the creators of Skribbl.io.

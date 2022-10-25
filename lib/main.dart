import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart' show DateFormat;
import 'package:path_provider/path_provider.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audio Recording and Playing fun',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterSoundRecorder? _recordingSession;
  final recordingPlayer = AssetsAudioPlayer();
  final testRecordingPlayer = AssetsAudioPlayer();
  String? pathToAudio;
  String _timerText = '00:00:00';
  bool _playAudio = false;

  void initState() {
    super.initState();
    initializer();
  }


  // https://blog.logrocket.com/creating-flutter-audio-player-recorder-app/
  void initializer() async {
    pathToAudio = '/sdcard/Download/temp.wav';
    _recordingSession = FlutterSoundRecorder();
    await _recordingSession!.openRecorder(
        // focus: AudioFocus!.requestFocusAndStopOthers,
        // category: SessionCategory!.playAndRecord,
        // mode: SessionMode!.modeDefault,
        // device: AudioDevice!.speaker
    );

    await _recordingSession!.setSubscriptionDuration(Duration(
        milliseconds: 10));
    await initializeDateFormatting();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  Future<void> startRecording() async {
    Directory directory = Directory(path.dirname(pathToAudio!));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    _recordingSession!.openRecorder();
    await _recordingSession!.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );
    StreamSubscription _recorderSubscription =
    _recordingSession!.onProgress!.listen((e) {
      var date = DateTime.fromMillisecondsSinceEpoch(
          e.duration.inMilliseconds,
          isUtc: true);
      var timeText = DateFormat('mm:ss:SS', 'en_GB').format(date);
      setState(() {
        _timerText = timeText.substring(0, 8);
      });
    });
    _recorderSubscription.cancel();
  }

  Future<String?> stopRecording() async {
    //_recordingSession.closeAudioSession();
    return await _recordingSession!.stopRecorder();
  }

  Future<void> playFunc() async {
    recordingPlayer.open(
      Audio.file(pathToAudio!),
      autoStart: true,
      showNotification: true,
    );
  }
  Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }

  Future uploadAudioToFireBase() async {
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();
    String fileName = "testing_audio" + DateTime.now().millisecondsSinceEpoch.toString();
    final audioFileRef = storageRef.child("$fileName");

    Directory appDocDir = await getApplicationDocumentsDirectory();

    //String filePath = '${appDocDir.absolute}/$pathToAudio';
    File file = File(pathToAudio!);

    // TODO: try/catch this
    await audioFileRef.putFile(file);

    // try {
    //   await audioFileRef.putFile(file);
    // } on firebase_core.FirebaseException catch (e) {
    //   // ...
    // }
  }

  Future<void> testPlayFunc() async {
    testRecordingPlayer.open(
      Audio.network("http://codeskulptor-demos.commondatastorage.googleapis.com/GalaxyInvaders/theme_01.mp3"),
      autoStart: true,
      showNotification: true,
    );
  }
  Future<void> testStopPlayFunc() async {
    testRecordingPlayer.stop();
  }




  ElevatedButton createElevatedButton(
      {IconData? icon , Color? iconColor, onPressFunc}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(6.0),
        side: BorderSide(
          color: Colors.red,
          width: 4.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        primary: Colors.white,
        elevation: 9.0,
      ),
      onPressed: onPressFunc,
      icon: Icon(
        icon,
        color: iconColor,
        size: 38.0,
      ),
      label: Text(''),
    );
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Center(
                child: Text(
                 _timerText,
                  style: TextStyle(fontSize: 70, color: Colors.red),
                ),
              ),
            ),
            SizedBox(height: 20,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                createElevatedButton(
                  icon: Icons.mic,
                  iconColor: Colors.red,
                 onPressFunc: startRecording,
                ),
                SizedBox(
                  width: 30,
                ),
                createElevatedButton(
                  icon: Icons.stop,
                  iconColor: Colors.red,
                  onPressFunc: stopRecording,
                ),

              ],
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              style:
              ElevatedButton.styleFrom(elevation: 9.0,
                  primary: Colors.red),
              onPressed: () {
                setState(() {
                  _playAudio = !_playAudio;
                });
                if (_playAudio) playFunc();
                if (!_playAudio) stopPlayFunc();
              },
              icon: _playAudio
                  ? Icon(
                Icons.stop,
              )
                  : Icon(Icons.play_arrow),
              label: _playAudio
                  ? Text(
                "Stop",
                style: TextStyle(
                  fontSize: 28,
                ),
              )
                  : Text(
                "Play",
                style: TextStyle(
                  fontSize: 28,
                ),
              ),
            ),
            ElevatedButton.icon(
              style:
              ElevatedButton.styleFrom(elevation: 9.0,
                  primary: Colors.blueAccent),
              onPressed: () {
                setState(() {
                  _playAudio = !_playAudio;
                });
                if (_playAudio) playFunc();
                if (!_playAudio) stopPlayFunc();
              },
              icon: _playAudio
                  ? Icon(
                Icons.stop,
              )
                  : Icon(Icons.play_arrow),
              label: _playAudio
                  ? Text(
                "Stop",
                style: TextStyle(
                  fontSize: 28,
                ),
              )
                  : Text(
                "Play",
                style: TextStyle(
                  fontSize: 28,
                ),
              ),
            ),

            ElevatedButton(onPressed: uploadAudioToFireBase,
                child: Text("Upload Audio"))


          ],
        ),
      ),

    );
  }
}


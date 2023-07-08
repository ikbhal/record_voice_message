import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}


class Audio {
  String audioPath;

  Audio({
    required this.audioPath,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Audio> audioList = [];
  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath ='';

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audioRecord = Record();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    audioRecord.dispose();
    super.dispose();
  }

  void addAudio() {
    setState(() {
      audioList.add(Audio(audioPath: audioPath));
    });
  }

  void deleteAudio(int index) {
    setState( (){
      audioList.removeAt(index);
    });
  }

  Future<void> startRecording() async {
    // await audioRecord.start(path: 'test.mp3');
    try{
      if(await audioRecord.hasPermission()) {
        await audioRecord.start();

        setState(() {
          isRecording = true;
        });
      }
    } catch(e ){
      print('Error starting recording : $e  ');
    }
  } 

  // create stopRecording function 
  Future<void> stopRecording() async {
    try{
      String? path = await audioRecord.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
        Audio audio = Audio(audioPath: audioPath );
        audioList.add(audio);
      });
    } catch(e) {
      print('Error stopping recording : $e  ');
    }
  } 

  // create playRecording function
  Future<void> playRecording() async {
    try{
      Source urlSource = UrlSource(audioPath);
      await audioPlayer.play(urlSource);
    } catch(e) {
      print('Error playing recording : $e  ');
    }
  }

  void playAudio(int index) async{
    setState(() {
      audioPath = audioList[index].audioPath;
    });
    await playRecording();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recorded voice messages'),
      ),
      body:
        Column(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if(isRecording)
                    const Text(
                      'Recording in progress...',
                      style: TextStyle(
                          fontSize: 20
                      ),
                    ),

                  ElevatedButton(
                      onPressed: isRecording ? stopRecording : startRecording,
                      child:
                      isRecording ?
                      const Text('Stop Recording') :
                      const Text('Start Recording')
                  ),

                  SizedBox(height: 25),
                  // create Elevated Button play recording
                  if(!isRecording && audioPath != null)
                    ElevatedButton(
                        onPressed: playRecording,
                        child: const Text('Play Recording')
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: audioList.length,
                itemBuilder: (BuildContext context, int index) {
                  final audio = audioList[index];
                  return ListTile(
                    title: Text("Audio $index"),
                    trailing: IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () => playAudio(index),
                    ),
                    onLongPress: () => deleteAudio(index),
                  );
                },
              )
            )
          ],
        )

    );
  }
}

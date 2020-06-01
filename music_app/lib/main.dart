import 'dart:async';

import 'package:flutter/material.dart';
import 'musique.dart';
import 'package:audioplayer/audioplayer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music App by LLMounir',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Music App by LLMounir'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Musique> maListeDeMusique = [
    new Musique('Green Lights', 'NF', 'assets/nf_greenlights.jpg',
        'http://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    new Musique(
        'Entre Gris Clair et Gris Foncé',
        'Jean-Jacques Goldman',
        'assets/jjg_egcegf.jpg',
        'http://codabee.com/wp-content/uploads/2018/06/deux.mp3')
  ];

  AudioPlayer lamusica;
  StreamSubscription positionSub;
  StreamSubscription stateSub;
  Musique maMusiqueAcuelle;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 10);
  PlayerState statut = PlayerState.stopped;

  void configurationAudioPlayer() {
    lamusica = new AudioPlayer();
    positionSub = lamusica.onAudioPositionChanged
        .listen((pos) => setState(() => position = pos));
    stateSub = lamusica.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          duree = lamusica.duration;
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.stopped;
        });
      }
    }, onError: (message) {
      print("erreur: $message");
      setState(() {
        statut = PlayerState.stopped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await lamusica.play(maMusiqueAcuelle.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async {
    await lamusica.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  @override
  void initState() {
    super.initState();
    maMusiqueAcuelle = maListeDeMusique[0];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height / 2,
                child: new Image.asset(maMusiqueAcuelle.imagePath),
              ),
            ),
            texteAvecStyle(maMusiqueAcuelle.titre, 1.5),
            texteAvecStyle(maMusiqueAcuelle.artiste, 1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                bouton(
                    (statut == PlayerState.playing)
                        ? Icons.pause
                        : Icons.play_arrow,
                    45.0,
                    (statut == PlayerState.playing)
                        ? ActionMusic.pause
                        : ActionMusic.play),
                bouton(Icons.fast_forward, 30.0, ActionMusic.forward)
              ],
            ),
            new Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                inactiveColor: Colors.white,
                activeColor: Colors.black,
                onChanged: (double d) {
                  setState(() {
                    Duration nouvelleDuration =
                        new Duration(seconds: d.toInt());
                    position = nouvelleDuration;
                  });
                }),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                texteAvecStyle('0:00', 0.9),
                texteAvecStyle('', 0.9),
                texteAvecStyle('', 0.9),
                texteAvecStyle('0:22', 0.9)
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconButton bouton(IconData icone, double taille, ActionMusic action) {
    return new IconButton(
        iconSize: taille,
        color: Colors.white,
        icon: new Icon(icone),
        onPressed: () {
          switch (action) {
            case ActionMusic.play:
              play();
              break;
            case ActionMusic.pause:
              pause();
              break;
            case ActionMusic.rewind:
              print("Rewind");
              break;
            case ActionMusic.forward:
              print("Forward");
              break;
          }
        });
  }

  Text texteAvecStyle(String data, double scale) {
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(color: Colors.white, fontSize: 20.0),
    );
  }
}

enum ActionMusic { play, pause, rewind, forward }
enum PlayerState { playing, stopped, paused }

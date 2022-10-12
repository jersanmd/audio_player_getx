import 'package:algolia/algolia.dart';
import 'package:audio_player_getx/bindings/initial_bindings.dart';
import 'package:audio_player_getx/page_manager.dart';
import 'package:audio_player_getx/services/algolia_playlist_controller.dart';
import 'package:audio_player_getx/services/audio_handler.dart';
import 'package:audio_player_getx/states/button_state.dart';
import 'package:audio_player_getx/states/repeat_state.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InitialBindings().dependencies();

  await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.audio',
      androidNotificationChannelName: 'Audio Service Demo',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageManager pageManager = Get.find<PageManager>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: const [
            CurrentSongTitle(),
            Playlist(),
            AudioProgressBar(),
            AudioControlButtons(),
          ],
        ),
      ),
    );
  }
}

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    PageManager pageManager = Get.find<PageManager>();
    return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Obx(() => Text(pageManager.currentSongTitleNotifier.value,
            style: const TextStyle(fontSize: 40))));
  }
}

class Playlist extends StatelessWidget {
  const Playlist({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    AlgoliaPlaylistController algoliaPlaylistController =
        Get.find<AlgoliaPlaylistController>();
    return Obx(() => Expanded(
        child: algoliaPlaylistController.audioResultMusic.value.isEmpty
            ? const Center(
                child: Text(
                'No Result',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ))
            : ListView.builder(
                itemCount: algoliaPlaylistController.audioResultMusic.length,
                itemBuilder: (BuildContext context, int index) {
                  AlgoliaObjectSnapshot snapshot =
                      algoliaPlaylistController.audioResultMusic.value[index];
                  return ListTile(
                    title: Text('${snapshot.data['title']}'),
                  );
                },
              )));
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    PageManager pageManager = Get.find<PageManager>();
    return Obx(() => ProgressBar(
          progress: pageManager.progressNotifier.value.current,
          buffered: pageManager.progressNotifier.value.buffered,
          total: pageManager.progressNotifier.value.total,
          onSeek: pageManager.seek,
        ));
  }
}

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          RepeatButton(),
          PreviousSongButton(),
          PlayButton(),
          NextSongButton(),
          ShuffleButton(),
        ],
      ),
    );
  }
}

class RepeatButton extends StatelessWidget {
  const RepeatButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    PageManager pageManager = Get.find<PageManager>();
    Icon icon;

    switch (pageManager.repeatButton.value) {
      case RepeatState.off:
        icon = const Icon(Icons.repeat, color: Colors.grey);
        break;
      case RepeatState.repeatSong:
        icon = const Icon(Icons.repeat_one);
        break;
      case RepeatState.repeatPlaylist:
        icon = const Icon(Icons.repeat);
        break;
    }

    return IconButton(
      icon: icon,
      onPressed: pageManager.repeat,
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    PageManager pageManager = Get.find<PageManager>();

    return IconButton(
      icon: const Icon(Icons.skip_previous),
      onPressed:
          (pageManager.isFirstSongNotifier.value) ? null : pageManager.previous,
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    PageManager pageManager = Get.find<PageManager>();

    switch (pageManager.playButtonNotifier.value) {
      case ButtonState.loading:
        return Container(
          margin: const EdgeInsets.all(8.0),
          width: 32.0,
          height: 32.0,
          child: const CircularProgressIndicator(),
        );
      case ButtonState.paused:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          iconSize: 32.0,
          onPressed: pageManager.play,
        );
      case ButtonState.playing:
        return IconButton(
          icon: const Icon(Icons.pause),
          iconSize: 32.0,
          onPressed: pageManager.pause,
        );
    }
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    PageManager pageManager = Get.find<PageManager>();
    return IconButton(
      icon: const Icon(Icons.skip_next),
      onPressed:
          (pageManager.isLastSongNotifier.value) ? null : pageManager.next,
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    PageManager pageManager = Get.find<PageManager>();
    return IconButton(
      icon: (pageManager.isShuffleModeEnabledNotifier.value)
          ? const Icon(Icons.shuffle)
          : const Icon(Icons.shuffle, color: Colors.grey),
      onPressed: pageManager.shuffle,
    );
  }
}

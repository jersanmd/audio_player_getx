import 'package:algolia/algolia.dart';
import 'package:audio_player_getx/page_manager.dart';
import 'package:audio_player_getx/services/algolia_playlist_controller.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';

class InitialBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(AudioHandler);
    Get.put(AlgoliaPlaylistController());
    Get.put(PageManager());
  }
}

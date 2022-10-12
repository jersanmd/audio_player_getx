import 'package:algolia/algolia.dart';
import 'package:get/get.dart';

class AlgoliaPlaylistController extends RxController {
  static const Algolia algolia = Algolia.init(
    applicationId: '71LFSCR1MZ',
    apiKey: 'c81fd030a7da1b6f8e000a865056bfdd',
  );

  var audioResultMusic = [].obs;
  var audioResultSermons = [].obs;

  Future<void> getSearchResultMusic() async {
    AlgoliaQuery algoliaQuery = algolia.instance.index("choir").query('');
    AlgoliaQuerySnapshot snapshot = await algoliaQuery.getObjects();
    audioResultMusic.value = snapshot.hits;
  }

  Future<void> getSearchResultSermon() async {
    AlgoliaQuery algoliaQuery = algolia.instance.index("sermons").query('');
    AlgoliaQuerySnapshot snapshot = await algoliaQuery.getObjects();
    audioResultSermons.value = snapshot.hits;
  }
}

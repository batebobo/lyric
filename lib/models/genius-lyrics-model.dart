import 'package:meta/meta.dart';

class GeniusLyricsModel {
  final String title; // full_title
  final String imageUrl;
  final String url;

  GeniusLyricsModel({ @required this.title, @required this.imageUrl, @required this.url });

  GeniusLyricsModel.fromJson(Map<String, dynamic> json)
    : title = json['result']['full_title'],
      imageUrl = json['result']['song_art_image_thumbnail_url'],
      url = json['result']['path'];

}
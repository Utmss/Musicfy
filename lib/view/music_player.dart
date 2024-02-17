import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/color.dart';
import 'package:flutter_application_1/view/artwork.dart';
import 'package:flutter_application_1/view/music.dart';
import 'package:flutter_application_1/view/string.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:spotify/spotify.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Musicplayer extends StatefulWidget {
  const Musicplayer({super.key});

  @override
  State<Musicplayer> createState() => _MusicplayerState();
}

class _MusicplayerState extends State<Musicplayer> {
  final player = AudioPlayer();
  Music music = Music(trackId: "7yDHHVKLbvDmVw1XXhDDIO");

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final credentials = SpotifyApiCredentials(
        Customstrings.clientId, Customstrings.clientSecret);
    final spotify = SpotifyApi(credentials);
    spotify.tracks.get(music.trackId).then((track) async {
      String? tempSongName = track.name;
      if (tempSongName != null) {
        music.songName = tempSongName;
        music.artistImage = track.artists?.first.name ?? "";
        String? image = track.album?.images?.first.url;
        if (image != null) {
          music.songImage = image;
          final tempSongColor = await getImagePalette(NetworkImage(image));
          if (tempSongColor != null) {
            music.songColor = tempSongColor;
          }
        }

        music.artistImage = track.artists?.first.images?.first.url;
        final yt = YoutubeExplode();
        final video =
            (await yt.search.search("$tempSongName ${music.artistName ?? ""}"))
                .first;
        final videoId = video.id.value;
        music.duration = video.duration;
        setState(() {});
        var manifest = await yt.videos.streamsClient.getManifest(videoId);
        var audioUrl = manifest.audioOnly.last.url;
        player.play(UrlSource(audioUrl.toString()));
      }
    });
    super.initState();
  }

  Future<Color?> getImagePalette(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor?.color;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: music.songColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.close,
                    color: Colors.transparent,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Music Player",
                        style: textTheme.bodyMedium
                            ?.copyWith(color: CustomColors.primarycolor),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: music.artistImage != null
                                ? NetworkImage(music.artistImage!)
                                : null,
                            radius: 10,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            music.artistName ?? 'Songify',
                            style: textTheme.bodyLarge
                                ?.copyWith(color: Colors.white),
                          )
                        ],
                      )
                    ],
                  ),
                  Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ],
              ),
              Expanded(
                  flex: 2,
                  child: Center(
                    child: Artwork(image: music.songImage!),
                  )),
              Expanded(
                  child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            music.songName ?? '',
                            style: textTheme.titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          Text(
                            music.artistName ?? '-',
                            style: textTheme.titleMedium
                                ?.copyWith(color: Colors.white54),
                          )
                        ],
                      ),
                      Icon(
                        Icons.favorite,
                        color: CustomColors.primarycolor,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  StreamBuilder(
                      stream: player.onPositionChanged,
                      builder: (context, data) {
                        return ProgressBar(
                          progress: data.data ?? const Duration(seconds: 0),
                          total: music.duration ?? const Duration(minutes: 4),
                          bufferedBarColor: Colors.white38,
                          baseBarColor: Colors.white10,
                          thumbColor: Colors.white,
                          progressBarColor: Colors.white,
                          onSeek: (duration) {
                            player.seek(duration);
                          },
                        );
                      }),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.lyrics_outlined,
                            color: Colors.white,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 36,
                          )),
                      IconButton(
                          onPressed: () async {
                            if (player.state == PlayerState.playing) {
                              await player.pause();
                            } else {
                              await player.resume();
                            }
                            setState(() {});
                          },
                          icon: Icon(
                            player.state == PlayerState.playing
                                ? Icons.pause
                                : Icons.play_circle,
                            color: Colors.white,
                            size: 60,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 36,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.loop,
                            color: CustomColors.primarycolor,
                          )),
                    ],
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}

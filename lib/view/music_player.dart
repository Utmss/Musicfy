import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/color.dart';
import 'package:flutter_application_1/view/artwork.dart';
import 'package:flutter_application_1/view/string.dart';
import 'package:spotify/spotify.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Musicplayer extends StatefulWidget {
  const Musicplayer({super.key});

  @override
  State<Musicplayer> createState() => _MusicplayerState();
}

class _MusicplayerState extends State<Musicplayer> {
  Color songcolor = Color(0xFF251117);
  String Artistname = "End of World !";
  String songname = "Arjan velley";
  String MusicTrackId = "4ApCig0GTR4IEp7Ijsyo3r";
  final player = AudioPlayer();
  Duration? duration;
  String? artistImage;

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
    spotify.tracks.get(MusicTrackId).then((track) async {
      String? songname = track.name;
      if (songname != null) {
        final yt = YoutubeExplode();
        final video = (await yt.search.search(songname)).first;
        final videoId = video.id.value;
        duration = video.duration;
        setState(() {});
        var manifest = await yt.videos.streamsClient.getManifest(videoId);
        var audioUrl = manifest.audioOnly.first.url;
        player.play(UrlSource(audioUrl.toString()));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: songcolor,
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
                            backgroundImage: NetworkImage(
                                "https://imgs.search.brave.com/DtBl-Kti9W76KVSxqOW3VhTy6fuvLESSUt0kuXipSO0/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9jZG4u/cGl4YWJheS5jb20v/cGhvdG8vMjAxNS8w/NS8zMS8xMy8xMC9n/aXJsLTc5MTY4Nl82/NDAuanBn"),
                            radius: 10,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            Artistname,
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
                    child: Artwork(
                        image:
                            "https://imgs.search.brave.com/fygf0I-YHzut0LA6GrFE3w3m-srMpy6SODGKaqMbugk/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzLzMzLzE2/L2Y3LzMzMTZmNzRj/MzQ3MTkxMDQyZGE1/MDZkMmJlMjJjNGM5/LmpwZw"),
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
                            songname,
                            style: textTheme.titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          Text(
                            Artistname,
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
                          total: duration ?? const Duration(minutes: 4),
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

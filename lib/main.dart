import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lyric/blocs/spotify-auth-bloc.dart';
import 'package:lyric/widgets/home-page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  SpotifyAuthBloc spotifyAuthBloc = SpotifyAuthBloc();

  @override
  void initState() {
    spotifyAuthBloc.dispatch(RequestAuthorizationToken());
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        bloc: spotifyAuthBloc,
        child: BlocBuilder(
          bloc: spotifyAuthBloc,
          builder: (BuildContext context, SpotifyAuthState state) {
            if (state is NotInitialized) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Authenticating'),
                  CupertinoActivityIndicator(animating: true, radius: 40)
                ],
              );
            } else if (state is WithToken) {
              return HomePage(token: state.token);
            }
          },
        ),
      ),
    );
  }
}

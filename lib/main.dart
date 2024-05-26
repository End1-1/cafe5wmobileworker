import 'dart:io';

import 'package:cafe5_mworker/bloc/app_bloc.dart';
import 'package:cafe5_mworker/bloc/date_bloc.dart';
import 'package:cafe5_mworker/bloc/question_bloc.dart';
import 'package:cafe5_mworker/screen/login.dart';
import 'package:cafe5_mworker/utils/prefs.dart';
import 'package:cafe5_mworker/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/model.dart';
import 'model/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  prefs = await SharedPreferences.getInstance();
  PackageInfo pa = await PackageInfo.fromPlatform();
  prefs.setString('appversion', '${pa.version}.${pa.buildNumber}');
  prefs.init();
  runApp(MultiBlocProvider(providers: [
    BlocProvider<AppBloc>(create: (context) => AppBloc()),
    BlocProvider<InitAppBloc>(create: (context) => InitAppBloc()..add(InitAppEvent())),
    BlocProvider<AppAnimateBloc>(create: (context) => AppAnimateBloc()),
    BlocProvider<DateBloc>(create: (context) => DateBloc()),
    BlocProvider<QuestionBloc>(create: (context) => QuestionBloc())
  ], child: App()));
}

class App extends StatefulWidget {
  final model = WMModel();

  App({super.key}) {
    Prefs.navigatorKey = GlobalKey<NavigatorState>();
  }

  @override
  State<StatefulWidget> createState() => _App();
}

class _App extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Picasso',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        navigatorKey: Prefs.navigatorKey,
        home: Scaffold(
            body: SafeArea(
                child: BlocListener<InitAppBloc, InitAppState>(
                    listener: (context, state) {
                      if (state.runtimeType == InitAppState) {
                        BlocProvider.of<InitAppBloc>(context)
                            .add(InitAppEvent());
                      }
                      if (state.runtimeType == InitAppStateFinished) {
                        if ((prefs.getBool('stayloggedin') ?? false) && prefs.string('sessionkey').isNotEmpty) {
                          widget.model.loginPasswordHash();
                        }
                      }
                    },
                    child: BlocBuilder<InitAppBloc, InitAppState>(
                      builder: (context, state) {
                        if (prefs.string('serveraddress').isEmpty) {
                          return Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                const Text('Please, configure server address'),
                                IconButton(
                                    onPressed: () {
                                      Navigation(widget.model).config().then((value) {
                                        BlocProvider.of<InitAppBloc>(context).add(InitAppEvent());
                                      });
                                    },
                                    icon: const Icon(Icons.arrow_forward))
                              ]));
                        }
                        if (state is InitAppStateLoading) {
                          return Center(
                            child: Container(
                              color: Colors.white,
                              height: 30,
                              width: 30,
                              child: const CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (state is InitAppStateFinished) {
                          if (state.error) {
                            return Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(child: Container()),
                                  Row(children: [
                                    Expanded(
                                        child:
                                            Styling.textError(state.errorText))
                                  ]),
                                  Styling.columnSpacingWidget(),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Styling.textButton(() {
                                          BlocProvider.of<InitAppBloc>(context).add(InitAppEvent());
                                        }, widget.model.tr('Retry'))
                                      ]),
                                      Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Styling.textButton(widget.model.navigation.settings
                                            , widget.model.tr('Setting'))
                                          ]),
                                      Expanded(child: Container()),
                                      Row(children: [
                                        Expanded(child: Styling.textCenter(prefs.string('appversion')))
                                      ],)
                                ]));
                          }
                          return Center(
                              child: WMLogin(
                                  widget.model, WMLogin.username_password));
                        }
                        return Container();
                      },
                    )))));
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

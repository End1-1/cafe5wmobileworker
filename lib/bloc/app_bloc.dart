import 'dart:convert';

import 'package:cafe5_mworker/utils/http_query.dart';
import 'package:cafe5_mworker/utils/prefs.dart';
import 'package:cafe5_mworker/utils/res.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event_bloc.dart';

part 'state_bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState()) {
    on<AppEvent>((event, emit) => emit(AppState()));
    on<AppEventLoading>((event, emit) => loadingData(event));
    on<AppEventError>((event, emit) => emit(AppStateError(event.text)));
  }

  void loadingData(AppEventLoading event) async {
    if (event.route.isEmpty) {
      emit(event.state!);
      return;
    }
    emit(AppStateLoading(event.text));
    final result = await HttpQuery(event.route).request(event.data);
    if (result['status'] == 0) {
      emit(AppStateError(result['data']));
    }
    if (event.state != null) {
      emit(event.state!..data = result['data']);
    }
    if (event.callback != null) {
      event.callback!(result['status'] == 0, result['data']);
    }
  }
}

class InitAppBloc extends Bloc<InitAppEvent, InitAppState> {
  InitAppBloc() : super(InitAppState()) {
    on<InitAppEvent>((event, emit) => configureClient(event));
  }

  void configureClient(InitAppEvent event) async {
    if (kIsWeb) {
      prefs.setString('serveraddress', Uri.base.host);
      final result = await HttpQuery('engine/client-config.php')
          .request({'res_version': prefs.getInt('res_version') ?? 0});
      initRes(result);
      emit(InitAppStateFinished(result['status'] == 0,
          result['status'] == 0 ? result['data'] : '', result['data']));
      return;
    }
    if (prefs.string('serveraddress').isEmpty) {
      emit(InitAppStateFinished(true, '', null));
      return;
    }
    emit(InitAppStateLoading());
    final result = await HttpQuery('engine/client-config.php')
        .request({'res_version': prefs.getInt('res_version') ?? 0});
    initRes(result);
    emit(InitAppStateFinished(result['status'] == 0,
        result['status'] == 0 ? result['data'] : '', result['data']));
  }

  void initRes(dynamic result) {
    if (result['status'] == 1) {
      dynamic d = result['data'];
      if (d['res_version'] != (prefs.getInt('res_version') ?? 0)) {
        prefs.setString('translator_hy', d['translator_hy']);
        prefs.setString('res', jsonEncode(d['res']));
        prefs.setInt('res_version', d['res_version']);
      }
      Res.initFrom(prefs.string('res'));
      Res.initTr(prefs.string('translator_hy'));
    }
  }
}

class AppAnimateBloc extends Bloc<AppAnimateEvent, AppAnimateStateIdle> {
  AppAnimateBloc() : super(AppAnimateStateIdle()) {
    on<AppAnimateEvent>((event, emit) => emit(AppAnimateStateIdle()));
    on<AppAnimateEventRaise>((event, emit) => emit(AppAnimateStateRaise()));
  }
}

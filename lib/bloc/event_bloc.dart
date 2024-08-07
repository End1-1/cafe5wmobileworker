part of 'app_bloc.dart';

class AppEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppEventLoading extends AppEvent {
  final String text;
  final String route;
  final Map<String, dynamic> data;
  final AppStateFinished? state;
  final Function(bool, dynamic)? callback;

  ///{@template AppEventLoading}
  ///text of query, route and date
  ///callback 1st - bool, is error
  ///2nd - data
  ///{@endtemplate}
  AppEventLoading(this.text, this.route, this.data, this.callback, this.state) ;
}

class AppEventError extends AppEvent {
  final String text;
  AppEventError(this.text);
}

class InitAppEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppAnimateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppAnimateEventRaise extends AppAnimateEvent {}

class AppAnimateEventShowMenu extends AppAnimateEvent {}
class AppAnimateEventHideMenu extends AppAnimateEvent {}
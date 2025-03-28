import 'package:cafe5_mworker/bloc/app_bloc.dart';
import 'package:cafe5_mworker/bloc/question_bloc.dart';
import 'package:cafe5_mworker/model/model.dart';
import 'package:cafe5_mworker/utils/calendar.dart';
import 'package:cafe5_mworker/utils/prefs.dart';
import 'package:cafe5_mworker/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'app.dart';
import 'draft_sale.dart';

part 'dashboard.model.dart';

part 'hotel/dashboard.hotel.dart';

part 'dashboard.store.dart';

part 'dashboard.reports.dart';

part 'dashboard.waiter.dart';

part 'reports/elina/dashboard.elinarep.dart';

class WMDashboard extends WMApp {
  final _model = DashboardModel();

  WMDashboard({super.key, required super.model}) {
    getDashboard();
  }

  @override
  Widget? leadingButton(BuildContext context) {
    return null;
  }

  @override
  String titleText() {
    return Prefs.config['first_page_title'] ?? 'Picasso';
  }

  @override
  List<Widget> actions() {
    return [
      IconButton(onPressed: getDashboard, icon: const Icon(Icons.refresh)),
      if (Prefs.config['dashboard'] == 'hotel') ...actionsHotel(),
      IconButton(onPressed: model.menuRaise, icon: const Icon(Icons.menu))
    ];
  }

  @override
  List<Widget> menuWidgets() {
    final defaultButtons = [
      Styling.menuButton(
          model.navigation.settings, 'config', model.tr('Configuration')),
      Styling.menuButton(model.navigation.logout, 'logout', model.tr('Logout')),
    ];

    return menuWidgetsStore()..addAll(defaultButtons);
  }

  @override
  Widget body() {
    return bodyStore();
  }
}

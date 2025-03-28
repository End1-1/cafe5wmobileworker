part of 'goods_reserve.dart';

class GoodsReserveModel {
  final reserveQtyTextController = TextEditingController();
  final reserveCommentTextController = TextEditingController();
  var reservationExpiration = DateTime.now();
  var reservationStore = 0;
  var reservationGoods = 0;
  var reservationBarcode = '';
  var reservationGoodsName = '';
  var maxReserveQty = 0.0;
}

extension WMEGoodsReserve on WMGoodsReserve {
  void createReservation() {
    var err = '';
    var qty = double.tryParse(_model.reserveQtyTextController.text) ?? 0;
    if (qty < 1) {
      err += model.tr('Quantity is not set');
      err += '\r\n';
    }
    if (err.isNotEmpty) {
      BlocProvider.of<AppBloc>(prefs.context()).add(AppEventError(err));
      return;
    }
    Map<String, dynamic> d = {
      'action': 1,
      'userfrom': Prefs.config['store'] ?? 0,
      'userto': _model.reservationStore,
      'goods': _model.reservationGoods,
      'goodsname': _model.reservationGoodsName,
      'barcode': _model.reservationBarcode,
      'scancode': _model.reservationBarcode,
      'qty': double.tryParse(_model.reserveQtyTextController.text) ?? 0,
      'usermessage': _model.reserveCommentTextController.text.replaceAll('\n', ' '),
      'enddate': prefs.dateMySqlText(_model.reservationExpiration),
      'f_enddate': prefs.dateMySqlText(_model.reservationExpiration),
      'f_goods': _model.reservationGoods,
      'f_qty': double.tryParse(_model.reserveQtyTextController.text) ?? 0,
      'f_message': _model.reserveCommentTextController.text.replaceAll('\n', ' ')
    };
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
        model.tr('Create reservation'), 'engine/shop/create-reserve.php', d,
            (e, s) {
          if (e) {
          } else {
            Navigator.pop(prefs.context(), true);
          }
        }, null));
  }

  void setReservationExpiration() {
    showDatePicker(
        context: prefs.context(),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)))
        .then((value) {
      if (value != null) {
        _model.reservationExpiration = value;
        BlocProvider.of<DateBloc>(prefs.context()).add(DateEvent());
      }
    });
  }

  void reserveQtyChanged(String s) {
    var nv = double.tryParse(s) ?? 0;
    if (nv > _model.maxReserveQty) {
      nv = _model.maxReserveQty;
      _model.reserveQtyTextController.text = prefs.df(nv.toString());
    }
  }
}
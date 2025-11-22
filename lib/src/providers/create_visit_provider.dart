import 'package:flutter/material.dart';

import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../classes/client.dart';

class CreateVisitProvider with ChangeNotifier {

  List<Client> _lClients = [];
  List<MultiSelectItem<Client>> _lItems = [];
  List<Client> _lSelectedClients = [];

  DateTime? _selectedDate;

  List<Client> get lClients => _lClients;
  List<MultiSelectItem<Client>> get lItems => _lItems;
  List<Client> get lSelectedClients => _lSelectedClients;

  DateTime? get selectedDate => _selectedDate;

  void setClients( List<Client> lClients ) {
    _lClients = lClients;
    notifyListeners();
  }

  void setItems( List<MultiSelectItem<Client>> lItems ) {
    _lItems = lItems;
    notifyListeners();
  }

  void setSelectedClients( List<Client> lSelectedClients ) {
    _lSelectedClients = lSelectedClients;
    notifyListeners();
  }

  void removeClientSelected( Client oClient ) {
    _lSelectedClients.remove( oClient );
    notifyListeners();
  }

  void setSelectedDate( DateTime? selectedDate ) {
    _selectedDate = selectedDate;
    notifyListeners();
  }

}
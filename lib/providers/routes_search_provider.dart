import 'dart:convert';
// import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrroadways/models/bus_route_model.dart';

class RoutesSearchProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BusRoute> _allRoutes = [];
  List<BusRoute> _searchResult = [];
  List<BusRoute> get searchResult => _searchResult;

  Future<void> searchRoutes(String from, String to) async {
    _isLoading = true;
    _searchResult = [];
    notifyListeners();

    if (_allRoutes.isEmpty) {
      _allRoutes = await loadRoutes();
    }

    // Separate lists for sorting by priority
    List<BusRoute> directRoutes = [];
    List<BusRoute> fromViaRoutes = [];
    List<BusRoute> viaToRoutes = [];
    List<BusRoute> viaSequenceRoutes = [];

    for (var route in _allRoutes) {
      if (route.from.toLowerCase().contains(from.toLowerCase())&&
          route.to.toLowerCase().contains(to.toLowerCase())) {
        // Direct route (From → To)
        directRoutes.add(route);
      } else if (route.from.toLowerCase().contains(from.toLowerCase() )&&
          route.via.toLowerCase().contains(to.toLowerCase())) {
        // From → Via
        fromViaRoutes.add(route);
      } else if (route.via.toLowerCase().contains(from.toLowerCase()) &&
          route.to.toLowerCase().contains(to.toLowerCase())) {
        // Via → To
        viaToRoutes.add(route);
      } else if (_isValidViaSequence(route.via, from, to) ||
          _isValidViaSequence(route.routeName, from, to)) {
        // Both from and to are in via sequence or route name sequence
        viaSequenceRoutes.add(route);
      }
    }

    // Merge lists in priority order
    _searchResult = [...directRoutes, ...fromViaRoutes, ...viaToRoutes, ...viaSequenceRoutes];

    _isLoading = false;
    notifyListeners();
  }

// Helper method to check if from and to locations exist in via sequence or route name
  bool _isValidViaSequence(String text, String from, String to) {
    if (text.isEmpty) return false;

    // Split text by common delimiters (-, |, ,, etc.)
    List<String> stops = text.split(RegExp(r'[-|,\s]+'))
        .map((stop) => stop.trim().toLowerCase())
        .where((stop) => stop.isNotEmpty)
        .toList();

    // Find indices of from and to in sequence
    int fromIndex = -1;
    int toIndex = -1;

    for (int i = 0; i < stops.length; i++) {
      if (stops[i] == from.toLowerCase()) {
        fromIndex = i;
      }
      if (stops[i] == to.toLowerCase()) {
        toIndex = i;
      }
    }

    // Both locations must exist and from must come before to in sequence
    return fromIndex != -1 && toIndex != -1 && fromIndex < toIndex;
  }

  Future<List<BusRoute>> loadRoutes() async {
    final String response = await rootBundle.loadString('assets/master.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => BusRoute.fromJson(json)).toList();
  }
}

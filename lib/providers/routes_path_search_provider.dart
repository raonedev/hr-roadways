import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/bus_route_model.dart';

class RoutesPathSearchProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BusRoute> _allRoutes = [];
  List<String> _path = [];
  List<String> get path => _path;

  Future<void> _initialized() async {
    if (_allRoutes.isEmpty) {
      _allRoutes = await _loadRoutes();
    }
  }

  Future<void> searchPath(String from, String to) async {
    _isLoading = true;
    _path = [];
    notifyListeners();
    try {
      await _initialized();
      await searchCompletePath(from, to, _allRoutes);
      _addToPath(to); 
      dev.log(_path.toString());
    } catch (e) {
      dev.log("Exception while searching");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<BusRoute>> _loadRoutes() async {
    final String response = await rootBundle.loadString('assets/master.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => BusRoute.fromJson(json)).toList();
  }

  List<BusRoute> _searchDirectRoutes(
    String from,
    String to,
    List<BusRoute> routes,
  ) {
    List<BusRoute> directRoutes = [];
    for (var route in routes) {
      final rFrom = route.from.toLowerCase();
      final rTo = route.to.toLowerCase();
      if (rFrom.contains(from.toLowerCase()) &&
          rTo.contains(to.toLowerCase())) {
        directRoutes.add(route);
      }
    }
    return directRoutes;
  }

  // You'll need to define a unique route key, e.g., combining from-via-to
  String _createRouteKey(BusRoute route) {
    return '${route.from.toLowerCase()}_${route.via.toLowerCase()}_${route.to.toLowerCase()}';
  }

  Future<void> searchCompletePath(
    String from,
    String to,
    List<BusRoute> routes, [
    Set<String>? visitedRoutes,
  ]) async {
    final currentVisited = visitedRoutes ?? <String>{};
    final List<BusRoute> results = _searchDirectRoutes(from, to, routes);
    dev.log("search for FROM:$from TO:$to result count : ${results.length}");
    _addToPath(from);

    if (results.isEmpty) {
      return;
    } else {
      for (var r in results) {
        final routeKey = _createRouteKey(r);

        if (currentVisited.contains(routeKey)) {
          continue;
        }
        currentVisited.add(routeKey);
        await searchCompletePath(r.from, r.via, routes, currentVisited);
        await searchCompletePath(r.via, r.to, routes, currentVisited);
        dev.log("search to $to");

        // _addToPath(to);
        break;
      }
    }
    return;
  }

  // Helper function to prevent duplicates in the path list
  void _addToPath(String city) {
    if (city.isEmpty) return;

    String trimmedCity = city.trim();
    // Case-insensitive check against the entire list
    bool alreadyExists = _path.any(
      (element) => element.trim().toLowerCase() == trimmedCity.toLowerCase(),
    );

    if (!alreadyExists) {
      _path.add(trimmedCity);
    }
  }
}

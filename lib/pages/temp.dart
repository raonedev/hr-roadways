import 'dart:convert';
import 'dart:io';

import '../models/bus_route_model.dart';

Future<List<BusRoute>> loadRoutes() async {
  final file = File('assets/master.json');
  final jsonString = await file.readAsString();
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((e) => BusRoute.fromJson(e)).toList();
}

bool isValidViaSequence(String text, String from, String to) {
  if (text.isEmpty) return false;

  List<String> stops =
      text
          .split(RegExp(r'[-|,\s]+'))
          .map((stop) => stop.trim().toLowerCase())
          .where((stop) => stop.isNotEmpty)
          .toList();

  int fromIndex = stops.indexOf(from.toLowerCase());
  int toIndex = stops.indexOf(to.toLowerCase());

  return fromIndex != -1 && toIndex != -1 && fromIndex < toIndex;
}

List<BusRoute> searchRoutes(String from, String to, List<BusRoute> routes) {
  List<BusRoute> directRoutes = [];
  List<BusRoute> fromViaRoutes = [];
  List<BusRoute> viaToRoutes = [];
  List<BusRoute> viaSequenceRoutes = [];

  for (var route in routes) {
    final rFrom = route.from.toLowerCase();
    final rVia = route.via.toLowerCase();
    final rTo = route.to.toLowerCase();

    if (rFrom.contains(from.toLowerCase()) && rTo.contains(to.toLowerCase())) {
      directRoutes.add(route);
    } else if (rFrom.contains(from.toLowerCase()) &&
        rVia.contains(to.toLowerCase())) {
      fromViaRoutes.add(route);
    } else if (rVia.contains(from.toLowerCase()) &&
        rTo.contains(to.toLowerCase())) {
      viaToRoutes.add(route);
    } else if (isValidViaSequence(route.via, from, to) ||
        isValidViaSequence(route.routeName, from, to)) {
      viaSequenceRoutes.add(route);
    }
  }

  return [
    ...directRoutes,
    // ...fromViaRoutes,
    // ...viaToRoutes,
    // ...viaSequenceRoutes,
  ];
}

List<String> path = [];

void main() async {
  final routes = await loadRoutes();
  final from = "karnal";
  final to = "hisar";
  await searchCompletePath(from, to, routes);
  print(path);
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
  final List<BusRoute> results = searchRoutes(from, to, routes);
  print("search for ${from} result count : ${results.length}");
  path.add(from);

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
      print("search to ${to}");
      path.add(to);
    }
  }
  return;
}

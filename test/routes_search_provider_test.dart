import 'package:flutter_test/flutter_test.dart';
import 'package:hrroadways/providers/routes_search_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('RoutesSearchProvider', () {
    late RoutesSearchProvider provider;

    setUp(() {
      provider = RoutesSearchProvider();
    });

    test('Initial state is correct', () {
      expect(provider.isLoading, false);
      expect(provider.searchResult, isEmpty);
    });

    test('loadRoutes loads data correctly', () async {
      final routes = await provider.loadRoutes();
      expect(routes, isNotEmpty);
    });

    test('searchRoutes finds direct routes', () async {
      await provider.searchRoutes('DELHI', 'CHANDIGARH');
      expect(provider.searchResult, isNotEmpty);
      expect(provider.searchResult.first.from, 'DELHI');
      expect(provider.searchResult.first.to, 'CHANDIGARH');
    });

    test('searchRoutes finds via-to routes', () async {
      await provider.searchRoutes('DELHI', 'AMBALA');
      expect(provider.searchResult, isNotEmpty);
      expect(provider.searchResult.first.from, 'DELHI');
      expect(provider.searchResult.first.via, contains('AMBALA'));
    });

    test('searchRoutes finds via-from routes', () async {
      await provider.searchRoutes('AMBALA', 'CHANDIGARH');
      expect(provider.searchResult, isNotEmpty);
      expect(provider.searchResult.first.via, contains('AMBALA'));
      expect(provider.searchResult.first.to, 'CHANDIGARH');
    });

    test('searchRoutes finds sequential via routes', () async {
      await provider.searchRoutes('PANIPAT', 'AMBALA');
      expect(provider.searchResult, isNotEmpty);
      expect(provider.searchResult.first.via, contains('PANIPAT'));
      expect(provider.searchResult.first.via, contains('AMBALA'));
    });

    test('searchRoutes is case-insensitive', () async {
      await provider.searchRoutes('delhi', 'chandigarh');
      expect(provider.searchResult, isNotEmpty);
      expect(provider.searchResult.first.from, 'DELHI');
      expect(provider.searchResult.first.to, 'CHANDIGARH');
    });

    test('searchRoutes handles no results', () async {
      await provider.searchRoutes('NOWHERE', 'ANYWHERE');
      expect(provider.searchResult, isEmpty);
    });
  });
}

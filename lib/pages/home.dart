import 'package:flutter/material.dart';
import 'package:hrroadways/pages/routes_page.dart';
import 'package:hrroadways/providers/routes_path_search_provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:hrroadways/colors.dart';
import 'package:hrroadways/models/bus_route_model.dart';
import 'package:hrroadways/widgets/bus_route_card.dart';
import 'package:hrroadways/providers/routes_search_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/list_of_place.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController fromController;
  late TextEditingController toController;

  @override
  void initState() {
    super.initState();
    fromController = TextEditingController();
    toController = TextEditingController();
    _checkTermsAccepted();
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  Future<void> _checkTermsAccepted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool accepted = prefs.getBool('termsAccepted') ?? false;

    if (!accepted && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTermsDialog();
      });
    }
  }

  Future<void> _launchTermsUrl() async {
    const url =
        'https://raonedev.github.io/hHrRoadways_privacyPolicy/privay-policy-web.html';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } else {
      throw Exception('Cannot launch $url');
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing without action
      builder: (context) {
        return AlertDialog(
          title: const Text("Terms & Conditions"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Disclaimer: This app is not an official Haryana Roadways app. "
                  "Data is sourced from publicly available Haryana Roadways PDF files "
                  "and presented for public convenience.\n\nBy continuing, you agree to our ",
                ),
                GestureDetector(
                  onTap: _launchTermsUrl,
                  child: const Text(
                    "Terms & Conditions",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('termsAccepted', true);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Accept"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final routesProvider = Provider.of<RoutesSearchProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 350.0,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.darkCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double currentHeight = constraints.biggest.height;
                final bool isCollapsed = currentHeight < kToolbarHeight + 50;
                return FlexibleSpaceBar(
                  centerTitle: true,
                  title:
                      isCollapsed && routesProvider.searchResult.isNotEmpty
                          ? Text(
                            '${fromController.text.trim()} to ${toController.text.trim()}',
                            style: TextStyle(
                              color: AppColors.light,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                          : null,
                  background: buildSearchCard(),
                );
              },
            ),
          ),
          routesProvider.searchResult.isEmpty
              ? SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      (fromController.text.isNotEmpty ||
                              toController.text.isNotEmpty)
                          ? "\nPlease try with different routes"
                          : "\n\nNote: This is not an official Haryana Roadways app. \nData is sourced from https://hartrans.gov.in/ for public convenience.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              )
              : SliverList(
                delegate: SliverChildBuilderDelegate((
                  BuildContext context,
                  int index,
                ) {
                  final BusRoute route = routesProvider.searchResult[index];
                  return GestureDetector(
                    onTap: () {
                      context.read<RoutesPathSearchProvider>().searchPath(
                        fromController.text.trim(),
                        toController.text.trim(),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RoutesPage()),
                      );
                    },
                    child: BusRouteCard(route: route),
                  );
                }, childCount: routesProvider.searchResult.length),
              ),
        ],
      ),
    );
  }

  Widget buildSearchCard() {
    return Padding(
      padding: const EdgeInsets.only(
        top: kToolbarHeight + 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "From",
            style: TextStyle(
              color: AppColors.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return locations.where(
                (option) => option.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            },
            optionsViewBuilder: (
              BuildContext context,
              AutocompleteOnSelected<String> onSelected,
              Iterable<String> options,
            ) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: AppColors.darkCard,
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    // Adjust width as needed, typically matching the input field
                    width: MediaQuery.of(context).size.width - 40,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return InkWell(
                          onTap: () {
                            onSelected(option);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.iconColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  option,
                                  style: TextStyle(
                                    color: AppColors.light,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            onSelected: (String selection) {
              fromController.text = selection;
            },
            fieldViewBuilder: (
              context,
              controller,
              focusNode,
              onFieldSubmitted,
            ) {
              controller.text = fromController.text;
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                style: TextStyle(color: AppColors.light),

                decoration: InputDecoration(
                  hintText: "Enter origin",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 2,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedBus01,
                      color: AppColors.iconColor,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "To",
                style: TextStyle(
                  color: AppColors.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Color(0xff282E3D),
                  ),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowReloadVertical,
                    color: AppColors.iconColor,
                    size: 16,
                  ),
                  onPressed: () {
                    setState(() {
                      final String temp = fromController.text.trim();
                      fromController.text = toController.text;
                      toController.text = temp;
                    });
                  },
                ),
              ),
            ],
          ),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return locations.where(
                (option) => option.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            },
            optionsViewBuilder: (
              BuildContext context,
              AutocompleteOnSelected<String> onSelected,
              Iterable<String> options,
            ) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: AppColors.darkCard,
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    // Adjust width as needed, typically matching the input field
                    width: MediaQuery.of(context).size.width - 40,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return InkWell(
                          onTap: () {
                            onSelected(option);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.iconColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  option,
                                  style: TextStyle(
                                    color: AppColors.light,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },

            onSelected: (String selection) {
              toController.text = selection;
            },
            fieldViewBuilder: (
              context,
              controller,
              focusNode,
              onFieldSubmitted,
            ) {
              controller.text = toController.text;
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                style: TextStyle(color: AppColors.light),
                decoration: InputDecoration(
                  hintText: "Enter destination",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 2,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedLocation01,
                      color: AppColors.iconColor,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<RoutesSearchProvider>().searchRoutes(
                  fromController.text.trim(),
                  toController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Search",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

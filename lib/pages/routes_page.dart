import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrroadways/colors.dart';
import 'package:hrroadways/common/timeline.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../models/bus_route_model.dart';
import '../providers/routes_path_search_provider.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({
    super.key,
    required this.from,
    required this.to,
    this.route,
  });
  final String from;
  final String to;
  final BusRoute? route;

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text("${widget.from} to ${widget.to}"),
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.maybePop(context);
          },
          icon: HugeIcon(icon: HugeIcons.strokeRoundedLinkBackward),
        ),
        leadingWidth: 50,
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Text("Journey Stops"),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                tileMode: TileMode.mirror,
                colors: [
                  AppColors.purple.withValues(alpha: 0.3),
                  AppColors.purple.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          Consumer<RoutesPathSearchProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return SizedBox(
                  width: 300,
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (provider.path.length <= 2 && widget.route != null) {
                final List<String> shortPath = [
                  widget.route!.from,
                  widget.route!.via,
                  widget.route!.to,
                ];

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Timeline(
                        indicatorSize: 50,
                        indicators: _buildIndicators(shortPath.length),
                        children:
                            shortPath
                                .map(
                                  (stop) => TimelineCard(
                                    time:
                                        "N/A", // Or use widget.route!.departureTime
                                    title: stop,
                                  ),
                                )
                                .toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: kToolbarHeight,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.dark,
                            ),
                            children: [
                              const TextSpan(
                                text: "Route : ",
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              TextSpan(
                                text: widget.route?.routeName ?? "N/A",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (provider.path.isNotEmpty) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Timeline(
                        indicatorSize: 50,
                        indicators: List.generate(provider.path.length, (
                          index,
                        ) {
                          if (index == 0) {
                            // First indicator
                            return CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  backgroundColor: AppColors.purple,
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedBus01,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            );
                          } else if (index == provider.path.length - 1) {
                            // Last indicator
                            return CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  backgroundColor: AppColors.purple,
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedLocation01,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Middle indicators
                            return UpcomingIndicator();
                          }
                        }),
                        children: List.generate(provider.path.length, (index) {
                          return TimelineCard(
                            time: "${(index + 1) * 12}",
                            title: provider.path[index], // name from list
                          );
                        }),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: kToolbarHeight,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.dark,
                            ),
                            children: [
                              const TextSpan(
                                text: "Route Name: ",
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              TextSpan(
                                text: widget.route?.routeName ?? "N/A",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return SizedBox(
                  width: 300,
                  height: 300,
                  child: Center(child: Text("No Rountes Found")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIndicators(int length) {
    return List.generate(length, (index) {
      if (index == 0) {
        return CircleAvatar(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: AppColors.purple,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedBus01,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        );
      } else if (index == length - 1) {
        return CircleAvatar(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: AppColors.purple,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        );
      } else {
        return const UpcomingIndicator();
      }
    });
  }
}

class UpcomingIndicator extends StatelessWidget {
  const UpcomingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: AppColors.light.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundColor: AppColors.purple.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class TimelineCard extends StatelessWidget {
  const TimelineCard({super.key, required this.title, required this.time});
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.only(top: 16, left: 12),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Departure",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.end,
          //     children: [
          //       Text(
          //         time,
          //         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          //           fontWeight: FontWeight.bold,
          //           color: AppColors.purple,
          //         ),
          //       ),
          //       Text("KM"),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

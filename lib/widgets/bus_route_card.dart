import 'package:flutter/material.dart';
import 'package:hrroadways/colors.dart';
import 'package:hrroadways/common/dashed_divider.dart';
import 'package:hrroadways/common/dotted_divider.dart';
import 'package:hrroadways/models/bus_route_model.dart';
import 'package:hugeicons/hugeicons.dart';

class BusRouteCard extends StatelessWidget {
  final BusRoute route;

  const BusRouteCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.temp.withValues(alpha: 0.1), // Soft shadow
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// **Route Name & Bus Stand**
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.routeName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                    Text(
                      "Departure From ${route.from}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      route.departureTime,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: AppColors.purple),
                    ),
                    Text(
                      "Departure",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          DashedDivider(height: 24, color: AppColors.iconColor),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedBus01,
                color: AppColors.purple,
                size: 16,
              ),
              Flexible(
                flex: 2,
                child: Text(
                  route.from,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, color: AppColors.dark),
                ),
              ),
              Flexible(
                flex: 1,
                child: DottedDivider(dotSpace: 1, dotRadius: 1),
              ),
              Flexible(
                flex: 2,
                child: Text(
                  route.via,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, color: AppColors.dark),
                ),
              ),
              Flexible(
                flex: 1,
                child: DottedDivider(dotSpace: 1, dotRadius: 1),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                color: AppColors.purple,
                size: 16,
              ),
              Flexible(
                flex: 2,
                child: Text(
                  route.to,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, color: AppColors.dark),
                ),
              ),
            ],
          ),

          // Text(
          //   route.busStandName,
          //   style: TextStyle(
          //     fontSize: 14,
          //     color: AppColors.dark.withValues(alpha: 0.7),
          //   ),
          // ),
          // const Divider(thickness: 1, height: 16),

          /// **Route Details (From → Via → To)**
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     /// **From**
          //     Flexible(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             "From:",
          //             style: TextStyle(
          //               fontSize: 14,
          //               fontWeight: FontWeight.w600,
          //               color: AppColors.temp.withValues(alpha: 0.8),
          //             ),
          //           ),
          //           Text(
          //             route.from,
          //             style: TextStyle(fontSize: 16, color: AppColors.dark),
          //           ),
          //         ],
          //       ),
          //     ),

          //     /// **Via (if exists)**
          //     if (route.via.isNotEmpty && route.via != "Unknown")
          //       Flexible(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             Text(
          //               "Via:",
          //               style: TextStyle(
          //                 fontSize: 14,
          //                 fontWeight: FontWeight.w600,
          //                 color: AppColors.temp.withValues(alpha: 0.8),
          //               ),
          //             ),
          //             Text(
          //               route.via,
          //               style: TextStyle(fontSize: 16, color: AppColors.dark),
          //             ),
          //           ],
          //         ),
          //       ),

          //     /// **To**
          //     Flexible(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.end,
          //         children: [
          //           Text(
          //             "To:",
          //             style: TextStyle(
          //               fontSize: 14,
          //               fontWeight: FontWeight.w600,
          //               color: AppColors.temp.withValues(alpha: 0.8),
          //             ),
          //           ),
          //           Text(
          //             route.to,
          //             style: TextStyle(fontSize: 16, color: AppColors.dark),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),

          // const SizedBox(height: 12),

          /// **Departure Time**
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       "Departure From ${route.from}:",
          //       style: TextStyle(
          //         fontSize: 14,
          //         fontWeight: FontWeight.w600,
          //         color: AppColors.temp.withValues(alpha: 0.8),
          //       ),
          //     ),
          //     Text(
          //       route.departureTime,
          //       style: TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.bold,
          //         color: AppColors.dark,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}

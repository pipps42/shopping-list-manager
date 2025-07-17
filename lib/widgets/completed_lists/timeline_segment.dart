import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/color_palettes.dart';

class TimelineSegment extends StatelessWidget {
  final bool isMonth;
  final bool isFirst;
  final bool isLast;

  const TimelineSegment({
    super.key,
    required this.isMonth,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppConstants.timelineSegmentWidth,
      child: Stack(
        children: [
          // Linea verticale continua che copre tutta l'altezza disponibile
          Positioned(
            left: (AppConstants.timelineSegmentWidth / 2) - 1, // Centrata
            top: 0,
            bottom: 0,
            child: Container(
              width: 2,
              color: AppColors.secondary.withOpacity(0.3),
            ),
          ),

          // Pallino centrato verticalmente
          Center(
            child: Container(
              width: isMonth ? 14 : 10,
              height: isMonth ? 14 : 10,
              decoration: BoxDecoration(
                color: isMonth ? AppColors.secondary : AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surface(context),
                  width: isMonth ? 3 : 2,
                ),
              ),
            ),
          ),

          // Linea orizzontale per i mesi
          if (isMonth)
            Positioned(
              left:
                  (AppConstants.timelineSegmentWidth / 2) +
                  6, // Dopo il pallino
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 14,
                  height: 2,
                  color: AppColors.secondary.withOpacity(0.3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

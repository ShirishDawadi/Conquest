import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuestReward extends StatelessWidget {
  final String amount;
  final bool isXp;
  final bool isWeekly;
  final double width;

  const QuestReward({
    super.key,
    required this.amount,
    required this.isXp,
    required this.isWeekly,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(amount, style: TextStyle(fontSize: width)),
        SizedBox(width: 5),
        if (isXp)
          SvgPicture.asset(
            'assets/icons/xp.svg',
            width: width,
            height: width,
          ),
        SizedBox(width: 5),
        if (isWeekly)
          SvgPicture.asset(
            'assets/icons/weekly_point.svg',
            width: width,
            height: width,
          ),
      ],
    );
  }
}

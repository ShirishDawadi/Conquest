import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/views/profile/cards/total_overview/total_overview_expanded.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class TotalOverview extends StatefulWidget {
  final DateTime date;
  const TotalOverview({super.key, required this.date});

  @override
  State<TotalOverview> createState() => _TotalOverviewState();
}

class _TotalOverviewState extends State<TotalOverview> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEE, d MMMM, y').format(widget.date);
    final mutedColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.50);
    final borderColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.10);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                formattedDate: formattedDate,
                isExpanded: _isExpanded,
                onTap: () => setState(() => _isExpanded = !_isExpanded),
              ),
              const SizedBox(height: 15),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
                child: _isExpanded
                    ? TotalOverviewExpanded(
                        mutedColor: mutedColor,
                        borderColor: borderColor,
                      )
                    : _CompactBody(
                        mutedColor: mutedColor,
                        borderColor: borderColor,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String formattedDate;
  final bool isExpanded;
  final VoidCallback onTap;

  const _Header({
    required this.formattedDate,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/calendar_month.svg',
          width: 24,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(formattedDate, style: const TextStyle(fontSize: 14)),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: isExpanded ? 0.5 : 0,
            child: SvgPicture.asset(
              isExpanded
                  ? 'assets/icons/collapse.svg'
                  : 'assets/icons/expand.svg',
              width: 20,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactBody extends StatelessWidget {
  final Color mutedColor;
  final Color borderColor;

  const _CompactBody({
    required this.mutedColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/steps.svg',
                      width: 30,
                      height: 30,
                      colorFilter: const ColorFilter.mode(
                        AppColors.greenish_3,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Steps',
                          style: TextStyle(fontSize: 10, color: mutedColor),
                        ),
                        const Text(
                          '12756',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Goal:5000',
                          style: TextStyle(fontSize: 10, color: mutedColor),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenish_3,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '100%',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 0.5, height: 48, color: borderColor),
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/scan.svg',
                      width: 30,
                      height: 30,
                      colorFilter: const ColorFilter.mode(
                        AppColors.bronze_mid,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Objects',
                          style: TextStyle(fontSize: 10, color: mutedColor),
                        ),
                        const Text(
                          '1/2',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Found',
                          style: TextStyle(fontSize: 10, color: mutedColor),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.30),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.30),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 0.5, height: 48, color: borderColor),
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/kcal.svg',
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calories',
                          style: TextStyle(fontSize: 10, color: mutedColor),
                        ),
                        const Text(
                          '300 kcal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Divider(thickness: 0.5, color: borderColor),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              const Text('Rewards Earned', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 20),
              SvgPicture.asset('assets/icons/xp.svg', width: 10, height: 10),
              const SizedBox(width: 3),
              const Text('40', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 20),
              SvgPicture.asset(
                'assets/icons/weekly_point.svg',
                width: 10,
                height: 10,
              ),
              const SizedBox(width: 3),
              const Text('20', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

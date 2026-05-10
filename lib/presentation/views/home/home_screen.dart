import 'package:conquest/core/constants/app_constants.dart';
import 'package:conquest/core/services/step_service.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/step_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/user_viewmodel.dart';
import 'package:conquest/presentation/views/home/widgets/background_tracking_dialog.dart';
import 'package:conquest/presentation/views/home/widgets/greeting_level.dart';
import 'package:conquest/presentation/views/home/widgets/quest_card.dart';
import 'package:conquest/presentation/views/home/widgets/reset_card.dart';
import 'package:conquest/presentation/views/home/widgets/step_arc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _walkController;
  int _walkFrame = 0;
  bool _hideTrackingBanner = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _walkController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        )..addListener(() {
          setState(() {
            _walkFrame = (_walkController.value * 4).floor().clamp(0, 3);
          });
        });
    _walkController.repeat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _walkController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(stepProvider.notifier).retryHealthConnect();
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Widget? _buildTrackingBanner(
    StepTrackingMode mode,
    double screenWidth,
    double screenHeight,
  ) {
    if (mode == StepTrackingMode.health || _hideTrackingBanner) {
      return null;
    }

    final isPedometer = mode == StepTrackingMode.pedometer;
    final color = isPedometer ? Colors.orange : Colors.red;
    final icon = isPedometer ? Icons.warning_amber : Icons.error_outline;

    final message = isPedometer
        ? 'Steps only count while app is open. Tap to enable background tracking.'
        : 'Step tracking unavailable. Please grant activity permission in Settings.';

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.008,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),

          const SizedBox(width: 8),

          Expanded(
            child: GestureDetector(
              onTap: isPedometer
                  ? () => BackgroundTrackingDialog.show(context)
                  : null,
              child: Text(
                message,
                style: TextStyle(
                  fontSize: screenWidth * 0.028,
                  color: isPedometer
                      ? Colors.orange.shade800
                      : Colors.red.shade800,
                ),
              ),
            ),
          ),

          if (isPedometer)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.orange.shade800,
              ),
            ),

          GestureDetector(
            onTap: () {
              setState(() {
                _hideTrackingBanner = true;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.close,
                size: 16,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final questState = ref.watch(questProvider);
    final stepState = ref.watch(stepProvider);
    final trackingMode = ref.watch(trackingModeProvider);
    final steps = stepState.value ?? 0;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final trackingBanner = _buildTrackingBanner(
      trackingMode,
      screenWidth,
      screenHeight,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: AppConstants.navBarBottomPadding(context),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.04),
                userState.when(
                  loading: () => const SizedBox(height: 80),
                  error: (e, _) => const SizedBox(height: 80),
                  data: (user) =>
                      GreetingLevel(user: user, greeting: _getGreeting()),
                ),
                if (trackingBanner != null) trackingBanner,
                SizedBox(height: screenHeight * 0.04),
                questState.when(
                  loading: () => const Center(
                    child: CupertinoActivityIndicator(
                      color: AppColors.greenish_3,
                      radius: 20,
                    ),
                  ),
                  error: (e, _) =>
                      const Center(child: Text('Failed to load quest')),
                  data: (quest) {
                    if (quest.needsReset) return const ResetCard();
                    return Column(
                      children: [
                        const SizedBox(height: 40),
                        StepArc(
                          steps: steps,
                          goal: quest.stepGoal ?? 1,
                          walkFrame: _walkFrame,
                        ),
                        const SizedBox(height: 40),
                        QuestCard(quest: quest, steps: steps),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

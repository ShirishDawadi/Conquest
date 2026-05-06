import 'package:conquest/core/constants/app_constants.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/user_viewmodel.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _walkController;
  int _walkFrame = 0;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
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
    _walkController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final questState = ref.watch(questProvider);
    final screenHeight = MediaQuery.of(context).size.height;

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
                const SizedBox(height: 40),
                userState.when(
                  loading: () => const SizedBox(height: 80),
                  error: (e, _) => const SizedBox(height: 80),
                  data: (user) => GreetingLevel(
                    user: user,
                    greeting: _getGreeting(),
                  ),
                ),
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
                          steps: 1000,
                          goal: quest.stepGoal ?? 1,
                          walkFrame: _walkFrame,
                        ),
                        const SizedBox(height: 40),
                        QuestCard(quest: quest, steps: 1000),
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
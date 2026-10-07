import 'dart:async';
import 'package:conquest/core/constants/app_constants.dart';
import 'package:conquest/core/services/object_image_sync_service.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/viewmodels/connectivity_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/step_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/user_viewmodel.dart';
import 'package:conquest/presentation/views/home/steps_reset_screen.dart';
import 'package:conquest/presentation/views/home/cards/greeting&arc/greeting_level.dart';
import 'package:conquest/presentation/views/home/cards/quest_card/quest_card.dart';
import 'package:conquest/presentation/views/home/cards/greeting&arc/step_arc.dart';
import 'package:conquest/presentation/views/home/cards/tracking/tracking_banner.dart';
import 'package:conquest/presentation/views/home/cards/activity_stats/activity_stats_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _isWalking = false;
  Timer? _walkTimer;
  StreamSubscription<StepCount>? _pedometerSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pedometerSubscription = Pedometer.stepCountStream.listen((event) {
      if (!_isWalking) setState(() => _isWalking = true);
      _walkTimer?.cancel();
      _walkTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isWalking = false);
      });
    }, onError: (e) {});

    CaptureSyncService().syncPending(ref);

    ref.listenManual(connectivityProvider, (previous, next) {
      final wasOffline = previous?.value == false;
      final isOnlineNow = next.value == true;
      if (wasOffline && isOnlineNow) {
        CaptureSyncService().syncPending(ref);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _walkTimer?.cancel();
    _pedometerSubscription?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final questState = ref.watch(questProvider);
    final stepState = ref.watch(stepProvider);
    final stepAsync = ref.watch(stepProvider);
    final trackingMode = ref.watch(trackingModeProvider);
    final isRunTracking = ref.watch(
      mapProvider.select((state) => state.isTracking),
    );
    final steps = stepState.value ?? 0;
    final isWalking = _isWalking || isRunTracking;

    final bestSessionKm = ref.watch(bestSessionTodayKmProvider);

    if (questState.hasValue && questState.value!.needsReset) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.invalidate(questProvider);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StepsResetScreen()),
        );
      });
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFloatingHeader(
              child: ColoredBox(
                color: Colors.transparent,
                child: userState.when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (user) => Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: GreetingLevel(user: user, greeting: _getGreeting()),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    if (stepAsync.hasValue)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TrackingBanner(mode: trackingMode),
                      ),
                    const SizedBox(height: 24),
                    questState.when(
                      loading: () => const Center(
                        child: CupertinoActivityIndicator(
                          color: AppColors.greenish_3,
                          radius: 20,
                        ),
                      ),
                      error: (e, _) =>
                          const Center(child: Text('Failed to load quest')),
                      data: (quest) => Column(
                        children: [
                          const SizedBox(height: 24),

                          StepArc(
                            steps: steps,
                            goal: quest.stepGoal ?? 500,
                            isWalking: isWalking,
                          ),

                          const SizedBox(height: 24),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: QuestCard(quest: quest, steps: steps),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ActivityStatsCard(
                              isSessionActive: isRunTracking,
                              bestSessionKm: bestSessionKm,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: AppConstants.navBarBottomPadding(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
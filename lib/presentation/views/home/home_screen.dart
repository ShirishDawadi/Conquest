import 'dart:async';
import 'dart:developer';
import 'package:conquest/core/constants/app_constants.dart';
import 'package:conquest/core/services/object_image_sync_service.dart';
import 'package:conquest/presentation/viewmodels/connectivity_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/step_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/user_viewmodel.dart';
import 'package:conquest/presentation/views/home/home_skeleton.dart';
import 'package:conquest/presentation/views/home/steps_reset_screen.dart';
import 'package:conquest/presentation/views/home/cards/greeting&arc/greeting_level.dart';
import 'package:conquest/presentation/views/home/cards/quest_card/quest_card.dart';
import 'package:conquest/presentation/views/home/cards/greeting&arc/step_arc.dart';
import 'package:conquest/presentation/views/home/cards/tracking/tracking_banner.dart';
import 'package:conquest/presentation/views/home/cards/activity_stats/activity_stats_card.dart';
import 'package:conquest/presentation/views/shared_widgets/error_state_view.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:dio/dio.dart';
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
  bool _refreshing = false;
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

  Future<void> _onRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      CaptureSyncService().syncPending(ref);
      await Future.wait([
        ref.read(questProvider.notifier).reload(),
        ref.read(userProvider.notifier).reload(),
        Future.delayed(const Duration(milliseconds: 500)),
      ]);
    } catch (e) {
      log('Home refresh failed: $e', name: 'HomeScreen');
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Widget _buildError(Object e) {
    final isOffline = e is DioException && e.response == null;

    return Container(
      width: double.infinity,
      height: 250,
      margin: EdgeInsets.all(10.0),
      child: GlassContainer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isOffline
              ? NoInternetStateView(onRetry: _onRefresh)
              : ErrorStateView(onRetry: _onRefresh),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final questState = ref.watch(questProvider);
    final stepState = ref.watch(stepProvider);
    final trackingMode = ref.watch(trackingModeProvider);
    final isRunTracking = ref.watch(
      mapProvider.select((state) => state.isTracking),
    );
    final steps = stepState.value ?? 0;
    final isWalking = _isWalking || isRunTracking;
    final bestSessionKm = ref.watch(bestSessionTodayKmProvider);

    final quest = questState.value;
    final showSkeleton = _refreshing || questState.isLoading;

    final goal = quest == null ? null : (quest.stepGoal ?? 500);

    if (quest != null && quest.needsReset) {
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
          physics: showSkeleton
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
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
            CupertinoSliverRefreshControl(
              refreshTriggerPullDistance: 120,
              onRefresh: _onRefresh,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    if (stepState.hasValue)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TrackingBanner(mode: trackingMode),
                      ),
                    const SizedBox(height: 48),
                    Center(
                      child: StepArc(
                        steps: goal == null ? 0 : steps,
                        goal: goal ?? 1,
                        isWalking: isWalking,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (showSkeleton)
                      const HomeCardSkeleton()
                    else if (questState.hasError && quest == null)
                      _buildError(questState.error!)
                    else if (quest != null)
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: QuestCard(quest: quest, steps: steps),
                      ),
                    if (showSkeleton)
                      const HomeCardSkeleton()
                    else
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ActivityStatsCard(
                          isSessionActive: isRunTracking,
                          bestSessionKm: bestSessionKm,
                        ),
                      ),
                    SizedBox(height: AppConstants.navBarBottomPadding(context)),
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

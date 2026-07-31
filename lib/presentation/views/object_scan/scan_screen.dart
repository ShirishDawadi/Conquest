import 'package:conquest/core/utils/detection_capability_utils.dart';
import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/presentation/viewmodels/scan_viewmodel.dart';
import 'package:conquest/presentation/views/object_scan/widgets/scan_%20bottom_bar.dart';
import 'package:conquest/presentation/views/object_scan/widgets/scan_camera_view.dart';
import 'package:conquest/presentation/views/object_scan/widgets/scan_frame_painter.dart'
    show ScanBoxesPainter;
import 'package:conquest/presentation/views/object_scan/widgets/scan_top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScanScreen extends ConsumerStatefulWidget {
  final QuestObjectModel object;

  const ScanScreen({super.key, required this.object});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  late final ScanViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = ScanViewModel(object: widget.object, ref: ref);
    vm.init();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                ScanTopBar(
                  displayLabel: vm.displayLabel,
                  mode: vm.mode,
                  modeReady: vm.modeReady,
                  showModeChip: !vm.reviewing && vm.modeReady,
                  flashMode: vm.flashMode,
                  onBack: () => Navigator.of(
                    context,
                  ).pop(vm.reviewing ? vm.reviewFound : false),
                  onToggleMode: vm.toggleMode,
                  onFlashTap: vm.toggleFlash,
                ),

                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          () {
                            if (vm.reviewing) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.memory(
                                      vm.reviewFrame!.bytes,
                                      fit: BoxFit.cover,
                                    ),
                                    CustomPaint(
                                      painter: ScanBoxesPainter(
                                        detections: vm.reviewFrame!.results,
                                        targetLabel: vm.targetLabel,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (vm.cameraReady && vm.cameraController != null) {
                              return ScanCameraView(
                                controller: vm.cameraController!,
                                showBoxes: vm.mode == ScanMode.live,
                                detections: vm.currentDetections,
                                targetLabel: vm.targetLabel,
                                minZoom: vm.minZoom,
                                maxZoom: vm.maxZoom,
                                currentZoom: vm.currentZoom,
                                onZoomChanged: vm.setZoom,
                                onTapToFocus: vm.setFocusAndExposurePoint,
                              );
                            }

                            if (vm.error != null) {
                              return Center(
                                child: Text(
                                  vm.error!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }

                            return const Center(
                              child: CupertinoActivityIndicator(color: Colors.white),
                            );
                          }(),

                          if (vm.capturing)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black87,
                                child: const Center(
                                  child: CupertinoActivityIndicator(
                                    radius: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                ScanBottomBar(
                  reviewing: vm.reviewing,
                  reviewFound: vm.reviewFound,
                  mode: vm.mode,
                  isCameraStable: vm.isCameraStable,
                  holdProgress: vm.holdProgress,
                  capturing: vm.capturing,
                  displayLabel: vm.displayLabel,
                  onCaptureTap: vm.onCaptureTap,
                  onRetryTap: vm.onRetry,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
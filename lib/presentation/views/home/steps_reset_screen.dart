import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/core/validators/input_validators.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/app_text_field.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class StepsResetScreen extends ConsumerStatefulWidget {
  const StepsResetScreen({super.key});

  @override
  ConsumerState<StepsResetScreen> createState() => _ResetCardState();
}

class _ResetCardState extends ConsumerState<StepsResetScreen> {
  int? _selected;
  final _goals = [2000, 5000, 7500, 10000];
  final _stepsController = TextEditingController();
  String? _stepsError;
  final _formatter = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();

    _stepsController.addListener(() {
      if (_stepsController.text.isNotEmpty && _selected != null) {
        setState(() {
          _selected = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _stepsController.dispose();
    super.dispose();
  }

  void _onContinue() {
    int? goal = _selected;

    if (goal == null) {
      final raw = _stepsController.text.replaceAll(',', '').trim();
      goal = int.tryParse(raw);

      setState(() {
        _stepsError = goal == null
            ? 'Please enter a valid number'
            : InputValidators.validateSteps(goal);
      });

      if (_stepsError != null) return;
    }

    ref.read(questProvider.notifier).setupQuest(goal!);

    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              bottom: -(screenHeight * 0.45),
              left: -(screenWidth * 0.5),
              child: Hero(
                tag: 'logo',
                child: SvgPicture.asset(
                  'assets/images/logo_screen.svg',
                  width: screenWidth * 2,
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 40,
                      ),
                      child: Center(
                        child: GlassContainer(
                          blur: 100,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/character/stand_1.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.none,
                                ),
                                const Text(
                                  'Set Your Daily Step Goal',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Choose a step goal to get started.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.50),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AppTextField(
                                  label: 'Set Your Own Goal',
                                  controller: _stepsController,
                                  iconAsset: 'assets/icons/steps.svg',
                                  keyboardType: TextInputType.number,
                                  maxLength: 5,
                                  error: _stepsError,
                                ),
                                const SizedBox(height: 10),
                                _divider(),
                                const SizedBox(height: 5),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      10,
                                      5,
                                      10,
                                      5,
                                    ),
                                    child: Text(
                                      'Choose a Goal',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: List.generate(2, (row) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: List.generate(2, (col) {
                                          final index = row * 2 + col;
                                          return Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                  ),
                                              child: AspectRatio(
                                                aspectRatio: 1.1,
                                                child: _goalTile(
                                                  context,
                                                  _goals[index],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    );
                                  }),
                                ),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/crown.svg',
                                      width: 20,
                                      height: 20,
                                      colorFilter: ColorFilter.mode(
                                        Colors.amber,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Most Used Option',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black.withValues(
                                          alpha: 0.50,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed:
                                        _selected != null ||
                                            _stepsController.text.isNotEmpty
                                        ? _onContinue
                                        : null,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.greenish_3,
                                      disabledBackgroundColor: AppColors
                                          .greenish_3
                                          .withValues(alpha: 0.9),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 1,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.10),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.60),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.10),
          ),
        ),
      ],
    );
  }

  Widget _goalTile(BuildContext context, int goal) {
    final isSelected = _selected == goal;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _stepsController.clear();
        setState(() {
          _selected = goal;
          _stepsError = null;
        });
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.greenish_2.withValues(alpha: 0.40)
              : goal == 5000
              ? Colors.amber.withValues(alpha: 0.30)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.greenish_3.withValues(alpha: 0.50)
                : goal == 5000
                ? Colors.amber.withValues(alpha: 0.50)
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.10),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        'assets/icons/steps.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          isSelected
                              ? AppColors.greenish_3
                              : Theme.of(context).colorScheme.onSurface,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Text(
                      goal == 2000
                          ? 'Beginner'
                          : goal == 5000
                          ? 'Casual'
                          : goal == 7500
                          ? 'Active'
                          : 'Athelete',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      _formatter.format(goal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'steps/day',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.greenish_3,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),
            if (goal == 5000 && !isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: SvgPicture.asset(
                  'assets/icons/crown.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(Colors.amber, BlendMode.srcIn),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

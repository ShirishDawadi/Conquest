import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/viewmodels/user_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = ref.read(userProvider).value;
      if (user != null) {
        _fullnameController.text = user.fullName ?? '';
        _usernameController.text = user.username;
        _initialized = true;
      }
    }
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: SvgPicture.asset(
                        'assets/icons/nav_left.svg',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).iconTheme.color!,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Edit profile',
                          style: TextStyle(fontFamily: 'Vertigo', fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: GlassContainer(
                      blur: 0,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            userState.when(
                              loading: () => const Center(
                                child: CupertinoActivityIndicator(
                                  color: AppColors.greenish_3,
                                  radius: 20,
                                ),
                              ),
                              error: (e, _) =>
                                  const Center(child: Text('Failed to load')),
                              data: (user) => Center(
                                child: Hero(
                                  tag: 'profile-avatar',
                                  child: CircleAvatar(
                                    radius: screenWidth * 0.18,
                                    backgroundImage: user.profilePhoto != null
                                        ? NetworkImage(user.profilePhoto!)
                                        : const AssetImage(
                                                'assets/images/default-avatar.png',
                                              )
                                              as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 24,
                                  backgroundImage: AssetImage(
                                    'assets/images/default-avatar.png',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.greenish_2,
                                  backgroundImage: AssetImage(
                                    'assets/images/character_avatar.png',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {},
                                  style: IconButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    fixedSize: const Size(48, 48),
                                    shape: const CircleBorder(),
                                  ),
                                  icon: SvgPicture.asset(
                                    'assets/icons/gallery.svg',
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).iconTheme.color!,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _field(
                              context,
                              'Full Name',
                              _fullnameController,
                              'assets/icons/profile.svg',
                            ),
                            const SizedBox(height: 5),
                            _field(
                              context,
                              'Username',
                              _usernameController,
                              'assets/icons/at_symbol.svg',
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () {},
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.greenish_3,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Save Changes'),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => Navigator.pop(context),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                  foregroundColor: AppColors.master_light,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context,
    String label,
    TextEditingController controller,
    String iconAsset,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
        SizedBox(
          height: 40,
          child: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                selectionHandleColor: AppColors.greenish_4,
              ),
            ),
            child: TextField(
              controller: controller,
              cursorColor: AppColors.greenish_4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greenish_2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.greenish_3,
                    width: 2,
                  ),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    iconAsset,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).iconTheme.color!,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

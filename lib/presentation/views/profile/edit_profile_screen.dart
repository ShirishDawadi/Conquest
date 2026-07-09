import 'dart:io';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/core/validators/input_validators.dart';
import 'package:conquest/presentation/viewmodels/user_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/app_text_field.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:conquest/presentation/views/shared_widgets/profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _initialized = false;
  String? _usernameError;
  String? _fullnameError;
  File? _pendingAvatar;
  String? _pendingDefaultAvatar;

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
  void initState() {
    super.initState();
    _usernameController.addListener(() {
      if (_usernameError != null) setState(() => _usernameError = null);
    });
    _fullnameController.addListener(() {
      if (_fullnameError != null) setState(() => _fullnameError = null);
    });
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final username = _usernameController.text.trim();
    final fullName = _fullnameController.text.trim();

    setState(() {
      _usernameError = InputValidators.validateUsername(username);
      _fullnameError = InputValidators.validateFullName(fullName);
    });

    if (_usernameError != null || _fullnameError != null) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (_pendingAvatar != null) {
      final compressed = await FlutterImageCompress.compressAndGetFile(
        _pendingAvatar!.path,
        '${_pendingAvatar!.path}_compressed.jpg',
        quality: 70,
        minWidth: 400,
        minHeight: 400,
      );

      if (compressed != null) {
        final avatarError = await ref
            .read(userProvider.notifier)
            .updateAvatar(File(compressed.path));

        if (!mounted) return;

        if (avatarError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(avatarError), backgroundColor: Colors.red),
          );
          return;
        }
      }
    }

    final error = await ref
        .read(userProvider.notifier)
        .updateProfile(
          username: username,
          fullName: fullName,
          profilePhoto: _pendingDefaultAvatar,
        );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _usernameError = error;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final vm = ref.watch(userProvider.notifier);

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
                                  child: _pendingAvatar != null
                                      ? ProfileAvatar(
                                          photoFile: _pendingAvatar!,
                                          radius: screenWidth * 0.18,
                                        )
                                      : _pendingDefaultAvatar != null
                                      ? ProfileAvatar(
                                          assetImage: AssetImage(
                                            'assets/images/$_pendingDefaultAvatar.png',
                                          ),
                                          radius: screenWidth * 0.18,
                                        )
                                      : ProfileAvatar(
                                          photoUrl: user.profilePhoto,
                                          radius: screenWidth * 0.18,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() {
                                      _pendingDefaultAvatar = "avatar1";
                                    });
                                  },
                                  icon: const CircleAvatar(
                                    radius: 24,
                                    backgroundImage: AssetImage(
                                      'assets/images/avatar1.png',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() {
                                      _pendingDefaultAvatar = "avatar2";
                                    });
                                  },
                                  icon: const CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppColors.greenish_2,
                                    backgroundImage: AssetImage(
                                      'assets/images/avatar2.png',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: vm.isSaving
                                      ? null
                                      : () async {
                                          final picker = ImagePicker();
                                          final picked = await picker.pickImage(
                                            source: ImageSource.gallery,
                                          );
                                          if (picked == null) return;

                                          setState(() {
                                            _pendingAvatar = File(picked.path);
                                          });
                                        },
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
                            AppTextField(
                              label: 'Full Name',
                              controller: _fullnameController,
                              iconAsset: 'assets/icons/profile.svg',
                              error: _fullnameError,
                              maxLength: 20,
                            ),
                            const SizedBox(height: 5),
                            AppTextField(
                              label: 'Username',
                              controller: _usernameController,
                              iconAsset: 'assets/icons/at_symbol.svg',
                              error: _usernameError,
                              maxLength: 15,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: vm.isSaving ? null : _saveChanges,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.greenish_3,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: vm.isSaving
                                    ? const CupertinoActivityIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text('Save Changes'),
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
}

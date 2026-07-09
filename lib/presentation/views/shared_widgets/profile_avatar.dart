import 'dart:io';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final File? photoFile;
  final AssetImage? assetImage;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.radius,
    this.photoUrl,
    this.photoFile,
    this.assetImage,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider image;

    if (photoFile != null) {
      image = FileImage(photoFile!);
    } else if (assetImage != null) {
      image = assetImage!;
    } else if (photoUrl != null) {
      if (photoUrl!.startsWith('http')) {
        image = NetworkImage(photoUrl!);
      } else {
        image = AssetImage('assets/images/$photoUrl.png');
      }
    } else {
      image = const AssetImage('assets/images/avatar1.png');
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.greenish_2,
      backgroundImage: image,
    );
  }
}
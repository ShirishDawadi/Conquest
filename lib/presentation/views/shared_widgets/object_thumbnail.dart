import 'dart:io';
import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/data/sources/local/object_image_local_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ObjectThumbnail extends StatelessWidget {
  final QuestObjectModel object;
  final int? questId;
  final Color iconColor;
  final double size;

  const ObjectThumbnail({
    super.key,
    required this.object,
    required this.questId,
    required this.iconColor,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    if (object.imageUrl != null && object.imageUrl!.isNotEmpty) {
      return _wrapWithLongPress(
        context,
        _frame(
          Image.network(
            object.imageUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackIcon(),
          ),
        ),
        imageProvider: NetworkImage(object.imageUrl!),
      );
    }

    return FutureBuilder<String?>(
      future: ObjectImageLocalSource().getPendingImagePath(object.id, questId: questId),
      builder: (context, snapshot) {
        final path = snapshot.data;
        final file = path != null ? File(path) : null;
        final fileExists = file?.existsSync() ?? false;

        if (fileExists) {
          return _wrapWithLongPress(
            context,
            _frame(Image.file(file!, width: size, height: size, fit: BoxFit.cover)),
            imageProvider: FileImage(file),
          );
        }

        return _fallbackIcon();
      },
    );
  }

  Widget _wrapWithLongPress(
    BuildContext context,
    Widget child, {
    required ImageProvider imageProvider,
  }) {
    return GestureDetector(
      onLongPress: () => _showPreview(context, imageProvider),
      child: child,
    );
  }

  void _showPreview(BuildContext context, ImageProvider imageProvider) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image(image: imageProvider, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  Widget _frame(Widget image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: image,
    );
  }

  Widget _fallbackIcon() {
    return SvgPicture.asset(
      'assets/icons/scan.svg',
      width: size - 4,
      height: size - 4,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
  }
}
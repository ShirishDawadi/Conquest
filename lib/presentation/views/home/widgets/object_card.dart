import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/data/sources/local/object_image_local_source.dart';
import 'package:conquest/presentation/views/object_scan/scan_screen.dart';
import 'package:conquest/presentation/views/shared_widgets/object_thumbnail.dart';
import 'package:conquest/presentation/views/shared_widgets/quest_reward.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ObjectCard extends StatefulWidget {
  final QuestObjectModel object;
  final bool completed;
  final int? questId;

  const ObjectCard({
    super.key,
    required this.object,
    required this.completed,
    this.questId,
  });

  @override
  State<ObjectCard> createState() => _ObjectCardState();
}

class _ObjectCardState extends State<ObjectCard> {
  @override
  Widget build(BuildContext context) {
    final difficultyXP = widget.object.difficulty == 'easy'
        ? 10
        : widget.object.difficulty == 'medium'
        ? 15
        : 20;
    final iconColor = Theme.of(context).iconTheme.color!;

    return FutureBuilder<bool>(
      future: widget.completed
          ? Future.value(true)
          : ObjectImageLocalSource().hasPending(widget.object.id, questId: widget.questId),
      builder: (context, snapshot) {
        final effectivelyCompleted = widget.completed || (snapshot.data ?? false);

        return IconButton(
          onPressed: effectivelyCompleted
              ? null
              : () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ScanScreen(object: widget.object)),
                  );
                  if (mounted) setState(() {});
                },
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          icon: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.object.label[0].toUpperCase() +
                            widget.object.label.substring(1).toLowerCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      QuestReward(
                        amount: '$difficultyXP',
                        isXp: true,
                        isWeekly: true,
                        width: 9,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: effectivelyCompleted
                      ? ObjectThumbnail(
                          object: widget.object,
                          questId: widget.questId,
                          iconColor: iconColor,
                        )
                      : SvgPicture.asset(
                          'assets/icons/scan.svg',
                          width: 30,
                          height: 30,
                          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
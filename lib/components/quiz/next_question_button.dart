import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_jogger/models/modes.dart';

import '../../provider.dart';

class NextQuestionButton extends ConsumerWidget {
  final Enum gameMode;
  const NextQuestionButton({super.key, this.gameMode = GameMode.training});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(200, 50),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          ref
              .watch(quizStagingProvider.notifier)
              .nextQuestionAction(ref, context, gameMode);

          ref.read(stopwatchProvider.notifier).startStopwatch(ref);
        },
        child: Text(
          'Continue',
          style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
        ));
  }
}
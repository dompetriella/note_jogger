import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:note_jogger/models/notes.dart';

class Note extends StatelessWidget {
  final Enum value;
  final List<Enum> clef;
  const Note({super.key, required this.value, required this.clef});

  @override
  Widget build(BuildContext context) {
    double calculateNotePosition(int noteValue, List<Enum> clefList) {
      int previousFlats = 0;
      for (var i = 0; i < clefList[value.index].index; i++) {
        if (clefList[i].name.contains('flat')) {
          previousFlats++;
        }
      }
      var position = 29 + (((value.index - previousFlats) + 1) * 10);
      return position.toDouble();
    }

    return Stack(
      children: [
        Stack(
          children: [
            // low c in treble cleft
            // low e in bass cleft
            AnimatedPositioned(
                duration: 200.ms,
                curve: Curves.easeInOut,
                left: 135,
                bottom: calculateNotePosition(value.index, clef),
                child: QuarterNoteWidget(
                  value: value.index,
                )),
          ],
        ),
        AnimatedPositioned(
          duration: 200.ms,
          curve: Curves.easeInOut,
          left: 110,
          bottom: calculateNotePosition(value.index, clef) - 18,
          child: SizedBox(
              height: 40,
              width: 20,
              child: value.name.contains('flat')
                  ? SvgPicture.asset('assets/flat.svg',
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn))
                  : const SizedBox(
                      height: 40,
                      width: 20,
                    )),
        )
      ],
    );
  }
}

class QuarterNoteWidget extends StatelessWidget {
  final int value;
  const QuarterNoteWidget({super.key, required this.value});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: QuarterNotePainter(
          flagIsUp: (value < TrebleClefNotes.B4.index),
          noteColor: Theme.of(context).colorScheme.secondary),
    ).animate().fadeIn();
  }
}

class QuarterNotePainter extends CustomPainter {
  final bool flagIsUp;
  final bool needsFloatingStaff;
  final Color noteColor;
  QuarterNotePainter({
    required this.noteColor,
    this.flagIsUp = false,
    this.needsFloatingStaff = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = noteColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);

    const rect = Rect.fromLTWH(0, 0, 30, 20);
    canvas.drawOval(rect, circlePaint);

    final linePaint = Paint()
      ..color = noteColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.5;

    // Save the current state of the canvas.
    canvas.save();

    canvas.rotate(pi / 2);
    flagIsUp ? canvas.translate(0, -29) : canvas.translate(0, -0.5);

    if (flagIsUp) {
      canvas.drawLine(
        Offset(-60, center.dy + -1),
        Offset(12, center.dy),
        linePaint,
      );
    } else {
      canvas.drawLine(
        Offset(8, center.dy + -1),
        Offset(90, center.dy),
        linePaint,
      );
    }

    canvas.restore();

    // Restore the canvas to its saved state.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

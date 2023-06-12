import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:note_jogger/models/notes.dart';
import 'package:note_jogger/provider.dart';
import 'floating_staff.dart';
import 'note.dart';

class NoteStaff extends ConsumerWidget {
  final dynamic value;
  final String imagePath;
  const NoteStaff({
    required this.value,
    required this.imagePath,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isTrebleClef = value.runtimeType == TrebleClefNotes;

    return Stack(
      children: [
        Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  width: 2.0, color: Theme.of(context).colorScheme.secondary)),
        ),
        Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ref.watch(showHintsProvider)
                        ? [
                            StaffLine(
                              valueHint: isTrebleClef ? 'E' : 'G',
                              animationDelay: 600,
                            ),
                            StaffLine(
                              valueHint: isTrebleClef ? 'C' : 'E',
                              animationDelay: 500,
                            ),
                            StaffLine(
                              valueHint: isTrebleClef ? 'A' : 'C',
                              animationDelay: 400,
                            ),
                            StaffLine(
                              valueHint: isTrebleClef ? 'F' : 'A',
                              animationDelay: 300,
                            ),
                            const StaffLine(),
                          ]
                        : [
                            StaffLine(),
                            StaffLine(),
                            StaffLine(),
                            StaffLine(),
                            const StaffLine(),
                          ],
                  ),
                  Stack(
                    children: [
                      if (value.index > 24)
                        const Positioned(
                            left: 150,
                            bottom: 290,
                            child: FloatingStaffWidget()),
                      if (value.index > 22)
                        const Positioned(
                            left: 150,
                            bottom: 270,
                            child: FloatingStaffWidget()),
                      if (value.index > 20)
                        const Positioned(
                            left: 150,
                            bottom: 250,
                            child: FloatingStaffWidget()),
                      if (value.index > 18)
                        const Positioned(
                            left: 150,
                            bottom: 230,
                            child: FloatingStaffWidget()),
                      if (value.index < 8)
                        const Positioned(
                            left: 150,
                            bottom: 110,
                            child: FloatingStaffWidget()),
                      if (value.index < 6)
                        const Positioned(
                            left: 150,
                            bottom: 90,
                            child: FloatingStaffWidget()),
                      if (value.index < 4)
                        const Positioned(
                            left: 150,
                            bottom: 70,
                            child: FloatingStaffWidget()),
                      if (value.index < 2)
                        const Positioned(
                            left: 150,
                            bottom: 50,
                            child: FloatingStaffWidget()),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0, left: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(value.clefImagePath,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.secondary,
                              BlendMode.srcIn),
                          height:
                              value.clefImagePath == 'assets/treble_clef.svg'
                                  ? 120
                                  : 80,
                          width: 80,
                          semanticsLabel: ''),
                    ),
                  )
                ],
              ),
              Center(
                child: Note(
                  value: value.index,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StaffLine extends StatelessWidget {
  final String valueHint;
  final double animationDelay;
  const StaffLine({super.key, this.valueHint = '', this.animationDelay = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 20,
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(.50),
                      width: 2))),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0),
          child: Text(
            valueHint,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary),
          )
              .animate()
              .fadeIn(delay: animationDelay.ms)
              .slideY(begin: -2, delay: animationDelay.ms),
        )
      ],
    );
  }
}

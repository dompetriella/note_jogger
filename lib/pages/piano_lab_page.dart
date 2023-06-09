import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:note_jogger/models/notes.dart';

import '../components/notestaff/notestaff.dart';
import '../provider.dart';

double whiteKeyWidth = 100;
double blackKeyWidth = whiteKeyWidth / 2;
double minScroll = 0;
double maxScroll = 100;
ScrollController scrollController =
    ScrollController(initialScrollOffset: whiteKeyWidth * 10);
final player = AudioPlayer();

class PianoLabPage extends HookConsumerWidget {
  const PianoLabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<double> scrollPercentage = useState(50);
    return SafeArea(
      child: Scaffold(
        appBar: MediaQuery.of(context).orientation == Orientation.landscape
            ? AppBar(
                title: Row(
                  children: [
                    Expanded(
                        child: Slider(
                      activeColor: Theme.of(context).colorScheme.primary,
                      value: scrollPercentage.value,
                      onChanged: (value) => {
                        scrollPercentage.value = value,
                        scrollController.jumpTo(
                            scrollController.position.maxScrollExtent *
                                (1 - (scrollPercentage.value / maxScroll)))
                      },
                      min: minScroll,
                      max: maxScroll,
                    )),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                actions: const [PianoControls()],
                shape: Border(
                    bottom: BorderSide(
                        color: Theme.of(context).colorScheme.onBackground,
                        width: 4)),
                elevation: 20,
                shadowColor: Colors.black,
              )
            : AppBar(),
        body: Builder(builder: (context) {
          if (MediaQuery.of(context).orientation == Orientation.portrait) {
            return Container(
              color: Theme.of(context).colorScheme.background,
              child: const Center(
                  child: Text(
                'Try Rotating the Device!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36),
              )),
            );
          } else {
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 500),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: 400.ms,
                      child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        controller: scrollController,
                        reverse: true,
                        children: const [PianoUI()],
                      ),
                    ),
                  ),
                  if (ref.watch(showStaffOnPianoProvider))
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).colorScheme.background,
                                Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(.15)
                              ]),
                          border: const Border(
                              bottom: BorderSide(width: 3),
                              left: BorderSide(width: 4))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: NoteStaff(
                          showHints: true,
                          size: .6,
                          note: TrebleClefNotes
                              .values[ref.watch(noteOnPianoStaffProvider)],
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}

class PianoUI extends HookConsumerWidget {
  const PianoUI({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Row(
          children: createWhiteKeys(),
        ),
        Positioned(
          right: whiteKeyWidth * .75,
          child: Row(
            children: createBlackKeys(),
          ),
        ),
      ],
    );
  }
}

List<Widget> createWhiteKeys() {
  List<Widget> returnList = [];
  for (var noteEnum in TrebleClefNotes.values) {
    if (!noteEnum.name.contains('flat')) {
      returnList.add(WhitePianoKey(
        note: noteEnum,
      ));
    }
  }
  return returnList;
}

List<Widget> createBlackKeys() {
  List<Widget> returnList = [];
  for (var noteEnum in TrebleClefNotes.values) {
    if (noteEnum.name.contains('flat')) {
      returnList.add(Padding(
        padding: EdgeInsets.only(
            left: noteEnum.name[0] == 'G' || noteEnum.name[0] == 'D'
                ? whiteKeyWidth + whiteKeyWidth * .5
                : whiteKeyWidth / 2),
        child: BlackPianoKey(
          note: noteEnum,
        ),
      ));
    }
  }
  return returnList;
}

class BlackPianoKey extends HookConsumerWidget {
  final Enum note;
  const BlackPianoKey({super.key, required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isPressed = useState(false);

    return GestureDetector(
      onPanDown: (details) async {
        isPressed.value = true;
        ref.read(noteOnPianoStaffProvider.notifier).state = note.index;
        await player
            .setAsset('audio/base_piano/${note.name[0]}b${note.name[1]}.mp3');
        await player.play();
      },
      onTapUp: (details) async {
        isPressed.value = false;
        await player
            .setAsset('audio/base_piano/${note.name[0]}b${note.name[1]}.mp3');
        await player.stop();
      },
      child: Builder(builder: (context) {
        return Container(
          width: whiteKeyWidth / 2,
          height: MediaQuery.of(context).size.height * .50,
          constraints: const BoxConstraints(maxHeight: 250),
          decoration: BoxDecoration(
              color: isPressed.value
                  ? Colors.lightBlue
                  : Theme.of(context).colorScheme.onBackground,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5))),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ref.watch(showLetterNamesOnPianoProvider)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${TrebleClefNotes.values[note.index - 1].name[0]}#',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.background,
                            fontSize: 22,
                            fontWeight: FontWeight.w400),
                      ).animate().fadeIn(),
                      const Divider(
                        color: Colors.white,
                      ),
                      Text(
                        '${note.name[0]}b',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.background,
                            fontSize: 22,
                            fontWeight: FontWeight.w400),
                      ).animate().fadeIn(),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        );
      }),
    );
  }
}

class WhitePianoKey extends HookConsumerWidget {
  final Enum note;
  const WhitePianoKey({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isPressed = useState(false);

    return GestureDetector(
      onPanDown: (details) async {
        isPressed.value = true;
        ref.read(noteOnPianoStaffProvider.notifier).state = note.index;
        await player.setAsset('audio/base_piano/${note.name}.mp3');
        await player.play();
      },
      onTapUp: (details) async {
        isPressed.value = false;
        await player.setAsset('audio/base_piano/${note.name}.mp3');
        await player.stop();
      },
      child: Container(
        width: whiteKeyWidth,
        decoration: BoxDecoration(
            color: isPressed.value
                ? Theme.of(context).colorScheme.secondary.withOpacity(.25)
                : Theme.of(context).colorScheme.background,
            border: Border(
                left: BorderSide(
                    width: 3, color: Theme.of(context).colorScheme.onPrimary),
                right: BorderSide(
                    width: 3, color: Theme.of(context).colorScheme.onPrimary),
                bottom: BorderSide(
                    width: 3, color: Theme.of(context).colorScheme.onPrimary))),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: ref.watch(showLetterNamesOnPianoProvider)
                  ? PianoNoteHint(note: note).animate().fadeIn()
                  : const SizedBox.shrink(),
            )),
      ),
    );
  }
}

class PianoNoteHint extends StatelessWidget {
  const PianoNoteHint({
    super.key,
    required this.note,
  });

  final Enum note;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      width: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            note.name[0],
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              note.name[1],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class PianoControls extends ConsumerWidget {
  const PianoControls({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () => ref.read(showStaffOnPianoProvider.notifier).state =
                !ref.read(showStaffOnPianoProvider),
            child: Icon(
              Icons.key,
              size: 45,
              color: ref.watch(showStaffOnPianoProvider)
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.onPrimary.withOpacity(.15),
            ),
          ),
        ),
      ],
    );
  }
}

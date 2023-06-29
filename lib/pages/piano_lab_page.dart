import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:note_jogger/components/notestaff/note_staff.dart';
import 'package:note_jogger/globals.dart';
import 'package:note_jogger/models/notes.dart';

import '../provider.dart';

double whiteKeyWidth = 100;
double blackKeyWidth = whiteKeyWidth / 2;
ScrollController scrollController = ScrollController();
final player = AudioPlayer();

class PianoLabPage extends HookConsumerWidget {
  const PianoLabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          actions: [PianoControls()],
          shape: Border(
              bottom: BorderSide(
                  color: Theme.of(context).colorScheme.onBackground, width: 4)),
          elevation: 20,
          shadowColor: Colors.black,
        ),
        body: Builder(builder: (context) {
          if (MediaQuery.of(context).orientation == Orientation.portrait) {
            return Container(
              color: Theme.of(context).colorScheme.background,
              child: Center(
                  child: Text(
                'Try Rotating the Device!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36),
              )),
            );
          } else {
            return Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: 400.ms,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      controller: scrollController,
                      children: [PianoUI()],
                      reverse: true,
                    ),
                  ),
                ),
                if (ref.watch(showStaffOnPianoProvider))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      height: 350,
                      child: Center(
                        child: Builder(builder: (context) {
                          return NoteStaff(
                              value: TrebleClefNotes
                                  .values[ref.watch(noteOnPianoStaffProvider)],
                              imagePath: GLOBAL_treble_clef_path);
                        }),
                      ),
                    ),
                  ),
              ],
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
    final initFunction = useCallback((_) async {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        scrollController.position.isScrollingNotifier.addListener(() {
          if (!scrollController.position.isScrollingNotifier.value) {
            ref.read(pianoIsScrollingProvider.notifier).state = false;
          } else {
            ref.read(pianoIsScrollingProvider.notifier).state = true;
          }
        });
      });
    }, []);

    useEffect(() {
      initFunction(null);
    }, []);

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

    useEffect(() {
      final pianoScrolling = ref.watch(pianoIsScrollingProvider);
      if (!pianoScrolling) {
        isPressed.value = false;
      }
    }, [ref.watch(pianoIsScrollingProvider)]);

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
          decoration: BoxDecoration(
              color: isPressed.value
                  ? Colors.lightBlue
                  : Theme.of(context).colorScheme.onBackground,
              borderRadius: BorderRadius.only(
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
                      Divider(),
                      Text(
                        '${note.name[0]}b',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.background,
                            fontSize: 22,
                            fontWeight: FontWeight.w400),
                      ).animate().fadeIn(),
                    ],
                  )
                : SizedBox.shrink(),
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

    useEffect(() {
      final pianoScrolling = ref.watch(pianoIsScrollingProvider);
      if (!pianoScrolling) {
        isPressed.value = false;
      }
    }, [ref.watch(pianoIsScrollingProvider)]);

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
              ? Theme.of(context).colorScheme.tertiary.withOpacity(.25)
              : Theme.of(context).colorScheme.background,
          border: Border.symmetric(
              vertical: BorderSide(color: Colors.black, width: 2)),
        ),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: ref.watch(showLetterNamesOnPianoProvider)
                  ? PianoNoteHint(note: note).animate().fadeIn()
                  : SizedBox.shrink(),
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
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              note.name[1],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
                  ? Colors.white
                  : Colors.black.withOpacity(.5),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () => ref
                .read(showLetterNamesOnPianoProvider.notifier)
                .state = !ref.read(showLetterNamesOnPianoProvider),
            child: Icon(
              Icons.abc,
              size: 60,
              color: ref.watch(showLetterNamesOnPianoProvider)
                  ? Colors.white
                  : Colors.black.withOpacity(.5),
            ),
          ),
        ),
      ],
    );
  }
}

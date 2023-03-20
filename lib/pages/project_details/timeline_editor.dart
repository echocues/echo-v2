import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:echocues/api/models/event.dart';
import 'package:echocues/api/models/event_time.dart';
import 'package:echocues/components/idle_button.dart';
import 'package:echocues/utilities/text_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimelineEditor extends StatefulWidget {
  final List<EventModel>? events;
  final Function(EventModel) onEditEvent;

  const TimelineEditor({Key? key, required this.events, required this.onEditEvent}) : super(key: key);

  @override
  State<TimelineEditor> createState() => _TimelineEditorState();
}

class _TimelineEditorState extends State<TimelineEditor> {
  final GlobalKey<_TimelineCursorState> _cursor = GlobalKey();

  final EventTime _runningTime = EventTime();
  Timer? _timeUpdater;
  late _TimelinePainter _painter;
  
  @override
  Widget build(BuildContext context) {
    _painter = _TimelinePainter(events: widget.events)
      ..horizontalOffsetSeconds = _runningTime.toSeconds() - 5 <= 0 ? 0 : _runningTime.toSeconds() - 5; // show 5 extra seconds if its not at the begining
    
    if (widget.events == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: TextHelper.title(context, "No Scene Selected"),
        ),
      );
    } else {
      return LayoutBuilder(
        builder: (ctx, constraints) => Stack(
          children: [
            GestureDetector(
              onTapDown: (details) {
                if (_painter.overEvent != null) {
                  widget.onEditEvent(_painter.overEvent!);
                } else {
                  moveCursor(details.localPosition.dx, constraints.maxWidth, _painter);
                }
              },
              onHorizontalDragUpdate: (details) {
                moveCursor(details.localPosition.dx, constraints.maxWidth, _painter);
              },
              child: CustomPaint(
                painter: _painter,
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),
            ),
            _TimelineCursor(
              key: _cursor,
              painter: _painter,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IdleButton(
                    onPressed: () {
                      addEvent(_painter);
                    }, 
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_box),
                        TextHelper.normal(ctx, "Add Event"),
                      ],
                    ),
                  ),
                  IdleButton(
                    onPressed: () {
                      if (_timeUpdater == null) {
                        setState(() {
                          _timeUpdater = Timer.periodic(const Duration(seconds: 1), (timer) {
                            var runningSeconds = _runningTime.toSeconds();
                            print("runningSeconds " + runningSeconds.toString());
                            print("relativeSeconds" + (runningSeconds - _painter.horizontalOffsetSeconds).toString());
                            print("canFit" + _painter.fitThisManySeconds.toString());
                            
                            // TODO also need to go backwards if needed 
                            if (runningSeconds % 10 == 0 || (runningSeconds - _painter.horizontalOffsetSeconds) >= (_painter.fitThisManySeconds - 1)) {
                              // every 10 seconds or when the running time is out of the current viewport
                              // we want to rebuild so the timeline can move forward
                              setState(() {
                                _runningTime.addSeconds(1);
                              });
                            } else {
                              _runningTime.addSeconds(1);
                            }
                          
                            _cursor.currentState?.moveToTime(_runningTime);
                          });
                        });
                      } else {
                        setState(() {
                          _timeUpdater!.cancel();
                          _timeUpdater = null;
                        });
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_timeUpdater == null ? Icons.play_arrow_outlined : Icons.pause_outlined),
                        TextHelper.normal(ctx, _timeUpdater == null ? "Run Timeline" : "Pause Timeline"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
    }
  }
  
  void addEvent(_TimelinePainter painter) {
    setState(() {
      widget.events?.add(EventModel(time: EventTime.fromSeconds(_cursor.currentState!.getAtSecond()), cues: [], notes: []));
    });
  }
  
  void moveCursor(double mouseX, double width, _TimelinePainter painter) {
    _cursor.currentState?.setState(() {
      var x = clampDouble(mouseX, 0, width);
      var timeInSeconds = (x / painter.pixelSpaceIntervalForEachSecond).round(); 
      _runningTime.minutes = 0;
      _runningTime.hours = 0;
      _runningTime.seconds = timeInSeconds + painter.horizontalOffsetSeconds;
      _runningTime.format();
      x = timeInSeconds * painter.pixelSpaceIntervalForEachSecond;
      _cursor.currentState?.setMouseX(x);
    });
  }
}

class _TimelinePainter extends CustomPainter {
  final List<EventModel>? events;

  late double pixelSpaceIntervalForEachSecond;
  double eventDotRadius = 6;
  int maxFitThisManyRows = 5;
  int fitThisManySeconds = 50;
  int horizontalOffsetSeconds = 0;
  int verticalOffsetRows = 0;

  HashMap<Offset, EventModel> eventsOnGraph = HashMap();
  EventModel? overEvent;

  _TimelinePainter({required this.events});

  @override
  void paint(Canvas canvas, Size size) {
    var pos = size.topLeft(Offset.zero);
    // BACKGROUND
    final backgroundPaint = Paint()
      ..color = const Color(0xff424242);
    if (events == null) {
      canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height), backgroundPaint);
      return;
    }
    canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height), backgroundPaint);

    // INITIALIZE VARIABLES
    pixelSpaceIntervalForEachSecond = size.width / fitThisManySeconds;
    final horizontalOffset = horizontalOffsetSeconds * pixelSpaceIntervalForEachSecond;

    // LINE PAINTS
    final linePaint = Paint()
      ..color = const Color(0x99888888)
      ..strokeWidth = 2.0;
    final faintLinePaint = Paint()
      ..color = const Color(0x99666666)
      ..strokeWidth = 1.0;

    // DRAW INTERVALS
    var count = -1;
    for (double i = 0; i < size.width; i += pixelSpaceIntervalForEachSecond + 0.00000000001) { // add a tiny number to the end to prevent the last one from drawing
      count++; var shouldBeThick = count % (5 + horizontalOffsetSeconds % 5) == 0;
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), shouldBeThick ? linePaint : faintLinePaint);

      // DRAW TIME LABEL
      if (shouldBeThick) {
        final textPainter = TextPainter(
            text: TextSpan(
              text: EventTime.fromSeconds(((i / pixelSpaceIntervalForEachSecond) + horizontalOffsetSeconds).round()).toSmartString(),
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
            textDirection: TextDirection.ltr
        )
          ..layout(minWidth: 0, maxWidth: pixelSpaceIntervalForEachSecond * 5);

        final x = (i + textPainter.width / 2);
        final y = textPainter.height / 2;
        textPainter.paint(canvas, Offset(x, y));
      }
    }

    // COMPUTE EVENTS
    final eventResults = computeEventPositions(pixelSpaceIntervalForEachSecond);
    final pixelSpaceIntervalForEachRow = size.height / (eventResults.rowsRequired + 1);
    final verticalOffset = verticalOffsetRows * pixelSpaceIntervalForEachRow;

    // DRAW ROWS
    // do not draw on top and bottom. only in the middle
    for (double i = pixelSpaceIntervalForEachRow; i < size.height;
    i += pixelSpaceIntervalForEachRow) {
      canvas.drawLine(
        Offset(0, i + verticalOffset),
        Offset(size.width, i + verticalOffset),
        linePaint,
      );
    }

    final eventPaint = Paint()
      ..color = const Color(0xffee6C4C)
      ..style = PaintingStyle.fill;

    // DRAW EVENTS
    for (var entry in eventResults.positions.entries) {
      // again, +1 
      final offset = Offset(entry.key.xPosition, (entry.key.row + 1) * pixelSpaceIntervalForEachRow + verticalOffset);
      canvas.drawCircle(offset, eventDotRadius, eventPaint);
      eventsOnGraph[offset] = entry.value;
    }
  }
  
  _EventsPositionResult computeEventPositions(double pixelSpaceIntervalForEachSecond) {
    final HashMap<int, int> times = HashMap();
    final HashMap<_PrecomputedEventPosition, EventModel> result = HashMap();

    var maxRows = 1;

    for (EventModel event in events!) {
      var eventTime = event.time.toSeconds() - horizontalOffsetSeconds;

      // is not in the view
      if (eventTime < 0 || eventTime > fitThisManySeconds) {
        continue;
      }

      // if there is already an event at this time, we need to add 1 to it
      if (times.containsKey(eventTime)) {
        final newValue = times[eventTime]! + 1;
        times[eventTime] = newValue;

        // if it is larger than the existing one, we change it 
        if (newValue > maxRows) {
          maxRows = newValue;
        }
      } else {
        // set to 1
        times[eventTime] = 1;
      }

      // if this does not fit in the current view
      final newValue = times[eventTime]!;
      if (newValue > maxFitThisManyRows) {
        continue;
      }

      // finally add it to the result
      result[_PrecomputedEventPosition(eventTime * pixelSpaceIntervalForEachSecond, newValue - 1)] = event;
    }

    return _EventsPositionResult(result, maxRows);
  }

  @override
  bool shouldRepaint(_TimelinePainter oldDelegate) {
    return oldDelegate.events != events
        || oldDelegate.horizontalOffsetSeconds != horizontalOffsetSeconds
        || oldDelegate.verticalOffsetRows != verticalOffsetRows
        || oldDelegate.fitThisManySeconds != fitThisManySeconds
        || oldDelegate.maxFitThisManyRows != maxFitThisManyRows;
  }
  
  @override
  bool? hitTest(Offset position) {
    for (var entry in eventsOnGraph.entries) {
      var offset = Offset(position.dx - entry.key.dx, position.dy - entry.key.dy);
      if (offset.distanceSquared < eventDotRadius * eventDotRadius) {
        overEvent = entry.value;
        return true;
      }
    }
    
    overEvent = null;
    return null;
  }
}

class _EventsPositionResult {
  HashMap<_PrecomputedEventPosition, EventModel> positions;
  int rowsRequired;

  _EventsPositionResult(this.positions, this.rowsRequired);
}

class _PrecomputedEventPosition {
  double xPosition;
  int row;

  _PrecomputedEventPosition(this.xPosition, this.row);
}

class _TimelineCursor extends StatefulWidget {
  final _TimelinePainter painter;
  
  const _TimelineCursor({Key? key, required this.painter}) : super(key: key);

  @override
  State<_TimelineCursor> createState() => _TimelineCursorState();
}

class _TimelineCursorState extends State<_TimelineCursor> {
  double _mouseX = 0;
  double _previousPosition = 0;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: _previousPosition, end: _mouseX),
        duration: const Duration(milliseconds: 75),
        builder: (_, value, __) => Transform(
          transform: Matrix4.translationValues(value, 0, 0),
          child: const VerticalDivider(
            color: Colors.yellow,
            width: 2,
          ),
        ),
      ),
    );
  }
  
  int getAtSecond() {
     return (_mouseX / widget.painter.pixelSpaceIntervalForEachSecond).round() + widget.painter.horizontalOffsetSeconds;
  }
  
  void moveToTime(EventTime time) {
    setState(() {
      _mouseX = (time.toSeconds() - widget.painter.horizontalOffsetSeconds) * widget.painter.pixelSpaceIntervalForEachSecond;
    });
  }
  
  void setMouseX(double mouseX) {
    _previousPosition = _mouseX;
    _mouseX = mouseX;
  }
}

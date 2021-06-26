
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:date_count_down/date_count_down.dart';
import 'package:event/Event.dart';
import 'package:event/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class More extends StatefulWidget {
  Event event;
  Function(Event, Set, int) callback;
  int index;
  Set<int> set;
  More(this.event, this.callback, this.set, this.index);

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends State<More> {
  bool pinned = true;
  bool snap = false;
  DateTime now = DateTime.now();
  bool floating = false;
  Timer timer;
  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        now = DateTime.now();
      });
    });
  }

  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: widget.event.dateTime,
        firstDate: DateTime(1000),
        lastDate: DateTime(5000));
    if (pickedDate != null && pickedDate != widget.event.dateTime) {
      setState(() {
        widget.event.setDateTime(new DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            widget.event.dateTime.hour,
            widget.event.dateTime.minute,
            0,
            0));
        cancelPrevEventNoti();
      });
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: widget.event.dateTime.hour,
            minute: widget.event.dateTime.minute));
    if (pickedTime != null && pickedTime != widget.event.dateTime) {
      setState(() {
        widget.event.setDateTime(new DateTime(
            widget.event.dateTime.year,
            widget.event.dateTime.month,
            widget.event.dateTime.day,
            pickedTime.hour,
            pickedTime.minute,
            0,
            0));
        cancelPrevEventNoti();
      });
    }
  }

  Future<void> pickFromGal() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        this.widget.event.setImage(File(pickedFile.path));
      });
    }
  }

  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
              pinned: this.pinned,
              snap: this.snap,
              floating: this.floating,
              expandedHeight: 300,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.event.name),
                background: this.widget.event.image != null
                    ? Image.file(
                        this.widget.event.image,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              actions: [
                IconButton(
                    onPressed: pickFromGal, icon: Icon(Icons.camera_alt)),
                IconButton(
                    onPressed: () => {
                          print("done icon clicked"),
                          Navigator.pop(context),
                          widget.callback(
                              widget.event, widget.set, widget.index),
                        },
                    icon: Icon(Icons.done)),
              ]),
          SliverFillRemaining(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 32, 16, 0),
                child: Column(children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                          CountDown().timeLeft(
                              widget.event.dateTime.isBefore(DateTime.now())
                                  ? new DateTime(
                                      now.year + 1,
                                      widget.event.dateTime.month,
                                      widget.event.dateTime.day,
                                      widget.event.dateTime.hour,
                                      widget.event.dateTime.minute,
                                      widget.event.dateTime.second)
                                  : new DateTime(
                                      now.year,
                                      widget.event.dateTime.month,
                                      widget.event.dateTime.day,
                                      widget.event.dateTime.hour,
                                      widget.event.dateTime.minute,
                                      widget.event.dateTime.second),
                              "Was today(" +
                                  widget.event.dateTime.hour.toString() +
                                  ":" +
                                  widget.event.dateTime.minute.toString() +
                                  ":" +
                                  widget.event.dateTime.second.toString() +
                                  ")",
                              longDateName: true),
                          style: TextStyle(
                            fontSize: 24,
                          )),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.celebration),
                                  Padding(padding: EdgeInsets.only(left: 8)),
                                  Text(widget.event.name,
                                      style: TextStyle(
                                        fontSize: 24,
                                      ))
                                ],
                              ),
                              TextButton(
                                  onPressed: () => {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                  title: Text("Set event name"),
                                                  content: TextField(
                                                      controller:
                                                          this.controller,
                                                      onChanged: (text) {
                                                        setState(() {
                                                          widget.event.name =
                                                              text;
                                                        });
                                                      }));
                                            })
                                      },
                                  child: Text("Change"))
                            ]),
                      )),
                  Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.event),
                                  Padding(padding: EdgeInsets.only(left: 8)),
                                  Text(
                                      this
                                              .widget
                                              .event
                                              .dateTime
                                              .day
                                              .toString() +
                                          "/" +
                                          this
                                              .widget
                                              .event
                                              .dateTime
                                              .month
                                              .toString() +
                                          "/" +
                                          this
                                              .widget
                                              .event
                                              .dateTime
                                              .year
                                              .toString(),
                                      style: TextStyle(
                                        fontSize: 24,
                                      ))
                                ],
                              ),
                              TextButton(
                                  onPressed: () => {selectDate(context)},
                                  child: Text("Change"))
                            ]),
                      )),
                  Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.watch),
                                  Padding(padding: EdgeInsets.only(left: 8)),
                                  Text(
                                      this
                                              .widget
                                              .event
                                              .dateTime
                                              .hour
                                              .toString() +
                                          ":" +
                                          this
                                              .widget
                                              .event
                                              .dateTime
                                              .minute
                                              .toString(),
                                      style: TextStyle(
                                        fontSize: 24,
                                      ))
                                ],
                              ),
                              TextButton(
                                  onPressed: () => {selectTime(context)},
                                  child: Text("Change"))
                            ]),
                      )),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Icon(Icons.notifications),
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                          ),
                          TextButton(
                            child: Text("Set notification",
                                style: TextStyle(fontSize: 24)),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    Duration duration =
                                        new Duration(minutes: 5);
                                    bool onEvent = widget.event.onEventId == -1
                                        ? false
                                        : true;
                                    bool onTime = widget.event.onTimeId == -1
                                        ? false
                                        : true;
                                    int time = 1;
                                    String before = "5 minutes";
                                    return StatefulBuilder(
                                        builder: (context, _setState) {
                                      return AlertDialog(
                                        actions: [
                                          TextButton(
                                              onPressed: () => {
                                                    print("done clicked"),
                                                    widget.event.time = time,
                                                    if (onEvent)
                                                      {
                                                        print(
                                                            "there is a onEvent noti"),
                                                        if (widget.event
                                                                .onEventId ==
                                                            -1)
                                                          {
                                                            print(
                                                                "onEvnet noti dont have id"),
                                                            widget.event
                                                                    .onEventId =
                                                                giveUniqueId(),
                                                            print("onEvent got id of " +
                                                                widget.event
                                                                    .onEventId
                                                                    .toString()),
                                                          }
                                                      }
                                                    else
                                                      {
                                                        print(
                                                            'cancelling onEvent noti or there is not any'),
                                                        cancelEventNoti()
                                                      },
                                                    if (onTime)
                                                      {
                                                        print(
                                                            "there is a on time noti"),
                                                        if (widget.event
                                                                .onTimeId ==
                                                            -1)
                                                          {
                                                            print(
                                                                "it didnt has any id,so giving one"),
                                                            widget.event
                                                                    .onTimeId =
                                                                giveUniqueId(),
                                                            print("onEvent got id of " +
                                                                widget.event
                                                                    .onTimeId
                                                                    .toString()),
                                                          }
                                                      }
                                                    else
                                                      {
                                                        print(
                                                            "cancelling onTime noti or there wasent any "),
                                                        cancelTimeNoti()
                                                      },
                                                    Navigator.of(context).pop(),
                                                  },
                                              child: Text("Done"))
                                        ],
                                        title: Text("Set Notification"),
                                        content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(children: [
                                                Checkbox(
                                                    value: onEvent,
                                                    onChanged: (ok) {
                                                      _setState(() {
                                                        onEvent = ok;
                                                      });
                                                    }),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5)),
                                                Text("At the Time of event")
                                              ]),
                                              Row(children: [
                                                Checkbox(
                                                    value: onTime,
                                                    onChanged: (ok) {
                                                      _setState(() {
                                                        onTime = ok;
                                                      });
                                                    }),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5)),
                                                Text(before + " before event"),
                                              ]),
                                              Row(children: [
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 15),
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      if (time == 1) {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Unable to set notification less than 5 minutes before the event");
                                                      } else {
                                                        _setState(() {
                                                          time--;
                                                          before =
                                                              setBefore(time);
                                                        });
                                                      }
                                                    },
                                                    child: Text("-")),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10)),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      if (time == 13) {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Unable to set notification greater than 1 month before the event");
                                                      } else {
                                                        _setState(() {
                                                          time++;
                                                          before =
                                                              setBefore(time);
                                                        });
                                                      }
                                                    },
                                                    child: Text("+"))
                                              ])
                                            ]),
                                      );
                                    });
                                  });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    child:Padding(
                    padding:EdgeInsets.all(8),
                    
                    child: Container(
                      child: ListTile(
                            leading:Icon(Icons.notifications),
                            title:Text("Notificatioin set at the time of event",
                            style:TextStyle(fontSize:24)
                            ),
                            
                      ),
                    ),
                    ),
                    visible:true,
                  )
                ]),
              )
            )
          )
        ]
    )
    );
  }
    giveUniqueId(){

      var id = Random().nextInt(pow(2, 31).toInt() - 1);
     while (widget.set.contains(id)){
       id = Random().nextInt(pow(2, 31).toInt() - 1);
     };

    widget.set.add(id);
    print("ID ADDED TO SET");
    return id;
  }

  void cancelEventNoti() {
    if (widget.event.onEventId != -1) {
      flutterLocalNotificationsPlugin.cancel(widget.event.onEventId);
      print("id removed from set");
      widget.set.remove(widget.event.onEventId);
      widget.event.onEventId = -1;
    }
  }

  void cancelTimeNoti() {
    if (widget.event.onTimeId != -1) {
      flutterLocalNotificationsPlugin.cancel(widget.event.onTimeId);
      print("id removed from set");
      widget.set.remove(widget.event.onTimeId);
      widget.event.onTimeId = -1;
    }
  }

  void cancelPrevEventNoti() {
    if (widget.event.onEventId != -1) {
      flutterLocalNotificationsPlugin.cancel(widget.event.onEventId);
      widget.set.remove(widget.event.onEventId);
      widget.event.onEventId = -1;
    }
    if (widget.event.onTimeId != -1) {
      flutterLocalNotificationsPlugin.cancel(widget.event.onTimeId);
      widget.set.remove(widget.event.onTimeId);
      widget.event.onTimeId = -1;
    }
  }

  String setBefore(int time) {
    return time == 1
        ? "5 minutes"
        : time == 2
            ? "15 minutes"
            : time == 3
                ? "30 minutes"
                : time == 4
                    ? "1 hour"
                    : time == 5
                        ? "2 hours"
                        : time == 6
                            ? "4 hours"
                            : time == 7
                                ? "8 hours"
                                : time == 8
                                    ? "12 hours"
                                    : time == 9
                                        ? "1 day"
                                        : time == 10
                                            ? "3 days"
                                            : time == 11
                                                ? "1 week"
                                                : time == 12
                                                    ? "2 weeks"
                                                    : time == 13
                                                        ? "1 month"
                                                        : "ok";
  }
}

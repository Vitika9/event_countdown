import 'dart:io';
import 'package:event/Event.dart';
import 'package:event/More.dart';
import 'package:event/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_count_down/date_count_down.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<Event> events = [];
  Set<int> set = {};
  void addEvent(Event event, Set set, int index) {
    this.set = set;
    if (!event.isCreated) {
      print("its a new event so inserting it");
      this.setState(() {
        events.insert(0, event);
      });
    } else {
      print("its an old event so replacing it");
      this.setState(() {
        events.removeAt(index);
        events.insert(index, event);
      });
    }
    if (event.onEventId != -1) {
      setEventNoti(true, 0, event);
    }
    if (event.onTimeId != -1) {
      setEventNoti(false, event.time, event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => {this.setState(() {})},
              icon: Icon(Icons.refresh))
        ],
        title: Text("Event Counter"),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          Event event = events[index];
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actions: <Widget>[
              IconSlideAction(
                caption: 'Home',
                color: Colors.blue,
                icon: Icons.home,
                onTap: () => {},
              ),
              IconSlideAction(
                caption: 'Share',
                color: Colors.indigo,
                icon: Icons.share,
                onTap: () => {},
              ),
            ],
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: 'Edit',
                color: Colors.black45,
                icon: Icons.edit,
                onTap: () => {},
              ),
              IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () => {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Delete"),
                                content: Text("Confirm action?"),
                                actions: [
                                  TextButton(
                                      onPressed: () => {
                                            this.setState(() {
                                              if (events
                                                      .elementAt(index)
                                                      .onEventId !=
                                                  -1) {
                                                flutterLocalNotificationsPlugin
                                                    .cancel(events
                                                        .elementAt(index)
                                                        .onEventId);
                                                set.remove(events
                                                    .elementAt(index)
                                                    .onEventId);
                                              }
                                              if (events
                                                      .elementAt(index)
                                                      .onTimeId !=
                                                  -1) {
                                                flutterLocalNotificationsPlugin
                                                    .cancel(events
                                                        .elementAt(index)
                                                        .onTimeId);
                                                set.remove(events
                                                    .elementAt(index)
                                                    .onTimeId);
                                              }

                                              events.removeAt(index);
                                            }),
                                            Navigator.of(context).pop()
                                          },
                                      child: Text("OK")),
                                  TextButton(
                                      onPressed: () =>
                                          {Navigator.of(context).pop()},
                                      child: Text("Cancel")),
                                ],
                              );
                            })
                      }),
            ],
            child: ListTile(
                leading: CircleAvatar(
                    backgroundImage: event.image != null
                        ? Image.file(event.image).image
                        : null,
                    backgroundColor: Colors.blue),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => More(
                            new Event.allProp(
                                event.name,
                                event.dateTime,
                                event.image,
                                event.details,
                                event.isCreated,
                                event.onEventId,
                                event.onTimeId,
                                event.time,
                                event.notiTime),
                            this.addEvent,
                            this.set,
                            index))),
                title: Text(event.name),
                subtitle: Text(
                  CountDown().timeLeft(
                      event.dateTime.isBefore(DateTime.now())
                          ? new DateTime(
                              DateTime.now().year + 1,
                              event.dateTime.month,
                              event.dateTime.day,
                              event.dateTime.hour,
                              event.dateTime.minute,
                              event.dateTime.second)
                          : new DateTime(
                              DateTime.now().year,
                              event.dateTime.month,
                              event.dateTime.day,
                              event.dateTime.hour,
                              event.dateTime.minute,
                              event.dateTime.second),
                      "Was today(" +
                          event.dateTime.hour.toString() +
                          ":" +
                          event.dateTime.minute.toString() +
                          ":" +
                          event.dateTime.second.toString() +
                          ")",
                      longDateName: true),
                )),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        mini: false,
        onPressed: () => {
          print("floating action button clicked"),
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      More(new Event.fromEvent(), this.addEvent, this.set, 0)))
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void setEventNoti(bool onEvent, int durBefore, Event event) {
    print("scheduleNoti called");
    event.notiTime = event.dateTime.isBefore(DateTime.now())
        ? new DateTime(
            DateTime.now().year + 1,
            event.dateTime.month,
            event.dateTime.day,
            event.dateTime.hour,
            event.dateTime.minute,
            event.dateTime.second)
        : new DateTime(
            DateTime.now().year,
            event.dateTime.month,
            event.dateTime.day,
            event.dateTime.hour,
            event.dateTime.minute,
            event.dateTime.second);
    scheduleNoti(event.notiTime, onEvent, durBefore, event);
  }

  void scheduleNoti(
      DateTime dateTime, bool onEvent, int durationBefore, Event event) async {
    var id = event.onEventId;
    if (!onEvent) {
      id = event.onTimeId;
    }
    print("id is " + id.toString());
    var scheduleNotificationsDateTime =
        dateTime.subtract(getDuration(durationBefore));
    print(scheduleNotificationsDateTime.toString());
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "nofi", "noti", "Channel for noti",
        icon: 'app_icon', largeIcon: DrawableResourceAndroidBitmap('app_icon'));

    var iosPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iosPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
        id,
        event.name,
        onEvent
            ? event.name + " is now!"
            : setBefore(durationBefore) + " left for " + event.name + "!",
        scheduleNotificationsDateTime,
        platformChannelSpecifics);
  }

  Duration getDuration(int time) {
    return time == 0
        ? Duration(seconds: 0)
        : time == 1
            ? Duration(minutes: 5)
            : time == 2
                ? Duration(minutes: 15)
                : time == 3
                    ? Duration(minutes: 30)
                    : time == 4
                        ? Duration(hours: 1)
                        : time == 5
                            ? Duration(hours: 2)
                            : time == 6
                                ? Duration(hours: 4)
                                : time == 7
                                    ? Duration(hours: 8)
                                    : time == 8
                                        ? Duration(hours: 12)
                                        : time == 9
                                            ? Duration(days: 1)
                                            : time == 10
                                                ? Duration(days: 3)
                                                : time == 11
                                                    ? Duration(days: 7)
                                                    : time == 12
                                                        ? Duration(days: 14)
                                                        : time == 13
                                                            ? Duration(days: 30)
                                                            : Duration(
                                                                seconds: 0);
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

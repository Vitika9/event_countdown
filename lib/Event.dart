import 'dart:io';

import 'package:flutter/material.dart';

class Event {
  String name = "Your Event";
  DateTime dateTime = DateTime.now();
  File image;
  String details = "";
  bool isCreated = false;
  DateTime notiTime=DateTime.now();
  int onEventId = -1;
  int onTimeId = -1;
  int time = 1;
  Event.allProp(this.name, this.dateTime, this.image, this.details,
      this.isCreated, this.onEventId, this.onTimeId, this.time,this.notiTime);
  Event.fromEvent();
  Event(this.name, this.dateTime, this.image, this.isCreated);
  void setImage(File img) {
    this.image = img;
  }

  void setDateTime(DateTime dateTime) {
    this.dateTime = dateTime;
  }
}

// To parse this JSON data, do
//
//     final emptierData = emptierDataFromJson(jsonString);

import 'dart:convert';

EmptierData emptierDataFromJson(String str) =>
    EmptierData.fromJson(json.decode(str));

String emptierDataToJson(EmptierData data) => json.encode(data.toJson());

class EmptierData {
  EmptierData({
    this.applicationId,
    this.sludgevol,
    this.emptytime,
    this.vacutugNo,
    this.capacity,
    this.driver,
    this.emptier1,
    this.emptier2,
    this.startTime,
    this.endTime,
    this.reqtrips,
    this.receiptcost,
    this.noreceiptcost,
    this.disposalcost,
    this.disposalplace,
    this.receiptNumber,
  });

  int applicationId;
  int sludgevol;
  String emptytime;
  int vacutugNo;
  int capacity;
  String driver;
  String emptier1;
  String emptier2;
  String startTime;
  String endTime;
  int reqtrips;
  int receiptcost;
  int noreceiptcost;
  int disposalcost;
  String disposalplace;
  String receiptNumber;

  factory EmptierData.fromJson(Map<String, dynamic> json) => EmptierData(
        applicationId: json["application_id"],
        sludgevol: json["sludgevol"],
        emptytime: json["emptytime"],
        vacutugNo: json["vacutug_no"],
        capacity: json["capacity"],
        driver: json["driver"],
        emptier1: json["emptier1"],
        emptier2: json["emptier2"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        reqtrips: json["reqtrips"],
        receiptcost: json["receiptcost"],
        noreceiptcost: json["noreceiptcost"],
        disposalcost: json["disposalcost"],
        disposalplace: json["disposalplace"],
        receiptNumber: json["receipt_number"],
      );

  Map<String, dynamic> toJson() => {
        "application_id": applicationId,
        "sludgevol": sludgevol,
        "emptytime": emptytime,
        "vacutug_no": vacutugNo,
        "capacity": capacity,
        "driver": driver,
        "emptier1": emptier1,
        "emptier2": emptier2,
        "start_time": startTime,
        "end_time": endTime,
        "reqtrips": reqtrips,
        "receiptcost": receiptcost,
        "noreceiptcost": noreceiptcost,
        "disposalcost": disposalcost,
        "disposalplace": disposalplace,
        "receipt_number": receiptNumber,
      };
}

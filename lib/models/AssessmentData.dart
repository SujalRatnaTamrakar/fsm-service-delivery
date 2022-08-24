// To parse this JSON data, do
//
//     final assessmentData = assessmentDataFromJson(jsonString);

import 'dart:convert';

AssessmentData assessmentDataFromJson(String str) =>
    AssessmentData.fromJson(json.decode(str));

String assessmentDataToJson(AssessmentData data) => json.encode(data.toJson());

class AssessmentData {
  AssessmentData({
    this.applicationId,
    this.servcode,
    this.estimatedCost,
    this.rddist,
    this.rdwidth,
    this.sludgeasd,
    this.proposedEmptyingDate,
    this.userId,
    this.tankWidth,
    this.tankLength,
    this.tankDepth,
    this.vacutagAccessibility,
    this.reqdTrips,
    this.comments,
  });

  String applicationId;
  String servcode;
  String estimatedCost;
  String rddist;
  String rdwidth;
  String sludgeasd;
  String proposedEmptyingDate;
  String userId;
  String tankWidth;
  String tankLength;
  String tankDepth;
  String vacutagAccessibility;
  String reqdTrips;
  String comments;

  factory AssessmentData.fromJson(Map<String, String> json) => AssessmentData(
        applicationId: json["application_id"],
        servcode: json["servcode"],
        estimatedCost: json["estimated_cost"],
        rddist: json["rddist"],
        rdwidth: json["rdwidth"],
        sludgeasd: json["sludgeasd"],
        proposedEmptyingDate: json["proposed_emptying_date"],
        userId: json["user_id"],
        tankWidth: json["tank_width"],
        tankLength: json["tank_length"],
        tankDepth: json["tank_depth"],
        vacutagAccessibility: json["vacutag_accessibility"],
        reqdTrips: json["reqd_trips"],
        comments: json["comments"],
      );

  Map<String, dynamic> toJson() => {
        "application_id": applicationId,
        "servcode": servcode,
        "estimated_cost": estimatedCost,
        "rddist": rddist,
        "rdwidth": rdwidth,
        "sludgeasd": sludgeasd,
        "proposed_emptying_date": proposedEmptyingDate,
        "user_id": userId,
        "tank_width": tankWidth,
        "tank_length": tankLength,
        "tank_depth": tankDepth,
        "vacutag_accessibility": vacutagAccessibility,
        "reqd_trips": reqdTrips,
        "comments": comments,
      };
}

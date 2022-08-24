import 'dart:convert';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:my_app/models/DatabaseHelper.dart';
import 'package:my_app/models/Supabase_helper.dart';
import 'package:postgres/postgres.dart';

class UploadScreen extends StatefulWidget {
  static final id = 'UploadScreen';
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  var connection;
  Future<List<Map<String, dynamic>>> containment, building;
  List<dynamic> containmentList, buildingList;
  bool _inAsyncCall = false;

  @override
  void initState() {
    super.initState();
    initConnection();
    _updateList();
  }

  initConnection() async {
    connection = PostgreSQLConnection(
        'db.gwqybjrkashrliujmxol.supabase.co', 5432, 'postgres',
        username: 'postgres', password: 'imisinnovativeflutter');
    await connection.open();
  }

  _updateList() {
    setState(() {
      containment = DatabaseHelper.instance
          .getContainmentMapList(supabase.auth.currentUser.email);
      building = DatabaseHelper.instance
          .getBuildingMapList(supabase.auth.currentUser.email);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload'),
        actions: <Widget>[],
        automaticallyImplyLeading: true,
        backgroundColor: Color.fromRGBO(101, 157, 82, 1),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _inAsyncCall,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Text(
                'Containment :',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              Divider(
                height: 20,
                thickness: 1,
              ),
              _getBodyWidget(containment, containmentList, 'Containment'),
              Text(
                'Building :',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              Divider(
                height: 20,
                thickness: 1,
              ),
              _getBodyWidget(building, buildingList, 'Building'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ConstrainedBox(
        constraints:
            BoxConstraints.tightFor(width: double.infinity, height: 60),
        child: ElevatedButton(
          onPressed: () async {
            bool result = await InternetConnectionChecker().hasConnection;
            if (result == true) {
              setState(() {
                _inAsyncCall = true;
              });
              if (containmentList.length > 0) {
                for (int i = 0; i < containmentList.length; i++) {
                  double lat = double.parse(containmentList[i]['lat']);
                  double lon = double.parse(containmentList[i]['lon']);
                  String latString = containmentList[i]['lat'];
                  String lonString = containmentList[i]['lon'];
                  final containmentResponse = await connection.query(
                      "INSERT INTO containment_data(lat, lon , geom) VALUES ($lat, $lon, ST_GeomFromText('POINT($lonString $latString)',4326));");
                  print(containmentResponse);
                }
              }
              if (buildingList.length > 0) {
                List<String> polygonPoints = [];
                for (int i = 0; i < buildingList.length; i++) {
                  String firstLat;
                  String firstLon;
                  polygonPoints.clear();
                  List<dynamic> list = json.decode(buildingList[i]['geom']);
                  for (int j = 0; j < list.length; j++) {
                    String latString = list[j]['latitude'];
                    String lonString = list[j]['longitude'];
                    firstLat = list[0]['latitude'];
                    firstLon = list[0]['longitude'];
                    polygonPoints.add(lonString + ' ' + latString);
                  }
                  polygonPoints.add(firstLon + ' ' + firstLat);
                  String points = polygonPoints.toString();
                  String polygon = points.substring(1, points.length - 1);
                  print(polygon);
                  final buildingResponse = await connection.query(
                      "INSERT INTO building_data(geom) VALUES (ST_GeomFromText('POLYGON(($polygon))'));");
                }
              }
              setState(() {
                DatabaseHelper.instance.deleteContainment();
                DatabaseHelper.instance.deleteBuilding();
                containment = DatabaseHelper.instance
                    .getContainmentMapList(supabase.auth.currentUser.email);
                building = DatabaseHelper.instance
                    .getBuildingMapList(supabase.auth.currentUser.email);
                _inAsyncCall = false;
              });
            } else {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('No Internet Connection!'),
                  content: const Text(
                      'There is no active internet connection! Please connect and try again.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          child: Text(
            'UPLOAD!',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          // style: ButtonStyle(
          //   backgroundColor: MaterialStateProperty.all(kPrimaryColor),
          // ),
        ),
      ),
    );
  }

  Widget _getBodyWidget(Future<List<Map<String, dynamic>>> future,
      List<dynamic> list, String type) {
    return Container(
      child: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          list = List.from(snapshot.data).reversed.toList();
          type == 'Building' ? buildingList = list : containmentList = list;
          return (ExpandableTheme(
            data: const ExpandableThemeData(
              iconColor: Colors.blue,
              useInkWell: true,
            ),
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: type == 'Building'
                  ? returnBuildingCards(snapshot.data.length, list, context)
                  : returnContainmentCards(snapshot.data.length, list, context),
            ),
          ));
        },
      ),
    );
  }
}

List<Widget> returnContainmentCards(
    int count, List<dynamic> list, BuildContext context) {
  List<Widget> widgetList = [];
  for (int i = 0; i < count; i++) {
    widgetList.add(Container(
      child: ExpandableNotifier(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              ScrollOnExpand(
                scrollOnExpand: true,
                scrollOnCollapse: false,
                child: ExpandablePanel(
                  theme: const ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToCollapse: true,
                  ),
                  header: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Latitude : ' + list[i]['lat'].toString() + '',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      )),
                  collapsed: Text(
                    'Longitude : ' + list[i]['lon'].toString() + '',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  expanded: Container(),
                  builder: (_, collapsed, expanded) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: const ExpandableThemeData(crossFadePoint: 0),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      )),
    ));
  }
  return widgetList;
}

List<Widget> returnBuildingCards(
    int count, List<dynamic> list, BuildContext context) {
  List<Widget> widgetList = [];
  for (int i = 0; i < count; i++) {
    widgetList.add(Container(
      child: ExpandableNotifier(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              ScrollOnExpand(
                scrollOnExpand: true,
                scrollOnCollapse: false,
                child: ExpandablePanel(
                  theme: const ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToCollapse: true,
                  ),
                  header: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Latitude : ' +
                            json
                                .decode(list[i]['geom'])[i]['latitude']
                                .toString() +
                            '',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      )),
                  collapsed: Text(
                    'Longitude : ' +
                        json
                            .decode(list[i]['geom'])[i]['longitude']
                            .toString() +
                        '',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  expanded: Table(
                    defaultColumnWidth: FixedColumnWidth(120.0),
                    children:
                        tableRows(List.from(json.decode(list[i]['geom']))),
                  ),
                  builder: (_, collapsed, expanded) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: const ExpandableThemeData(crossFadePoint: 0),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      )),
    ));
  }
  return widgetList;
}

tableRows(List<dynamic> list) {
  List<TableRow> tableRowsList = [];
  tableRowsList.add(TableRow(children: [
    Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('Latitude', style: TextStyle(fontSize: 17.0))]),
    Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [Text('Longitude', style: TextStyle(fontSize: 17.0))]),
  ]));
  for (int i = 0; i < list.length; i++) {
    tableRowsList.add(TableRow(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(list[i]['latitude'], style: TextStyle(fontSize: 15.0))
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(list[i]['longitude'], style: TextStyle(fontSize: 15.0))
      ]),
    ]));
  }
  return tableRowsList;
}

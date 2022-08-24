import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as MapsToolkit;
import 'package:my_app/constants/constants.dart';
import 'package:my_app/models/Building.dart';
import 'package:my_app/models/Containment.dart';
import 'package:my_app/models/DatabaseHelper.dart';
import 'package:my_app/models/Supabase_helper.dart';
import 'package:my_app/utils/config.helper.dart';
import 'package:latlong/latlong.dart';
import 'package:my_app/widgets/StylesOption.dart';
import 'package:postgres/postgres.dart';
import 'package:user_location/user_location.dart';
import 'package:badges/badges.dart';

enum Layer { Layer1, Layer2 }

class MapScreen extends StatefulWidget {
  static final id = 'MapScreen';

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController();
  UserLocationOptions userLocationOptions;
  List<Marker> markers = [];
  List<LatLng> tappedPoints = [];
  List<Marker> tappedMarkers = [];
  List<LatLng> polylinePoints = [];
  Map<int, Marker> markerMap = {};
  Map<LatLng, int> markerId = {};
  Map<int, double> distances = {};
  bool layer1 = false;
  bool layer2 = false;
  int i = 0;
  double layer1opacity = 0.0, layer2opacity = 0.0;
  // Color springBorder = Color(0xff3681FE);
  // Color satelliteBorder = Colors.transparent;
  // Color galaxyBorder = Colors.transparent;
  final satelliteBorder = new ValueNotifier(Colors.transparent);
  final springBorder = new ValueNotifier(Color(0xff3681FE));
  final galaxyBorder = new ValueNotifier(Colors.transparent);
  double springOpacity = 1.0, satelliteOpacity = 0.0, galaxyOpacity = 0.0;
  MarkerLayerOptions markerLayerOptions;
  int noOfRows;

  @override
  void initState() {
    super.initState();
  }

  onTapFAB() {
    print('Callback function has been called');
    userLocationOptions.updateMapLocationOnPositionChange = false;
  }

  @override
  Widget build(BuildContext context) {
    userLocationOptions = UserLocationOptions(
      context: context,
      mapController: mapController,
      // markerWidget: Icon(
      //   Icons.person_pin_circle_rounded,
      //   color: Colors.redAccent,
      //   semanticLabel: 'Me',
      //   size: 30.0,
      // ),
      markers: markers,
      updateMapLocationOnPositionChange: false,
      showMoveToCurrentLocationFloatingActionButton: true,
      zoomToCurrentLocationOnLoad: true,
      fabBottom: 70.0,
      fabRight: 15.0,
      verbose: false,
      locationUpdateIntervalMs: 1000,
    );
    markerLayerOptions = MarkerLayerOptions(markers: markerMap.values.toList());
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        // leading: Icon(Icons.map_outlined),
        automaticallyImplyLeading: true,
        backgroundColor: Color.fromRGBO(101, 157, 82, 1),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  markerMap.clear();
                  polylinePoints.clear();
                  distances.clear();
                  i = 0;
                });
              },
              icon: Icon(Icons.highlight_remove))
        ],
      ),
      body: FutureBuilder(
        future: loadConfigFile(),
        builder: (
          BuildContext buildContext,
          AsyncSnapshot<Map<String, dynamic>> snapshot,
        ) {
          if (snapshot.hasData) {
            return FlutterMap(
              options: MapOptions(
                center: LatLng(23.544987, 89.172603),
                zoom: 14,
                maxZoom: 25,
                onTap: (point) {
                  i++;
                  Marker marker = setMarker(
                      point: point,
                      count: markerMap.values.toList().length + 1);
                  setState(() {
                    markerMap[i] = marker;
                    markerId[point] = i;
                  });
                  polylinePoints.add(point);

                  if (polylinePoints.length > 1) {
                    double distanceBetweenPoints =
                        MapsToolkit.SphericalUtil.computeDistanceBetween(
                            MapsToolkit.LatLng(polylinePoints[i - 2].latitude,
                                polylinePoints[i - 2].longitude),
                            MapsToolkit.LatLng(polylinePoints[i - 1].latitude,
                                polylinePoints[i - 1].longitude));
                    distances[i - 1] =
                        double.parse(distanceBetweenPoints.toStringAsFixed(2));

                    setState(() {
                      markerMap.clear();
                      markerId.clear();
                      for (int i = 0; i < polylinePoints.toList().length; i++) {
                        Marker marker = setMarker(
                            point: polylinePoints.toList()[i],
                            count: i + 1,
                            distance: distances[i + 1]);
                        markerMap[i + 1] = marker;
                        markerId[polylinePoints.toList()[i]] = i + 1;
                      }
                    });
                  }
                  if (polylinePoints.length > 2 &&
                      (polylinePoints.length) == (i)) {
                    double dist =
                        MapsToolkit.SphericalUtil.computeDistanceBetween(
                            MapsToolkit.LatLng(polylinePoints[0].latitude,
                                polylinePoints[0].longitude),
                            MapsToolkit.LatLng(
                                polylinePoints[polylinePoints.length - 1]
                                    .latitude,
                                polylinePoints[polylinePoints.length - 1]
                                    .longitude));

                    setState(() {
                      distances[polylinePoints.length] =
                          double.parse(dist.toStringAsFixed(2));
                      markerMap.clear();
                      markerId.clear();
                      for (int i = 0; i < polylinePoints.toList().length; i++) {
                        Marker marker = setMarker(
                            point: polylinePoints.toList()[i],
                            count: i + 1,
                            distance: distances[i + 1]);
                        markerMap[i + 1] = marker;
                        markerId[polylinePoints.toList()[i]] = i + 1;
                      }
                    });
                  }
                },
                plugins: [
                  UserLocationPlugin(),
                ],
              ),
              mapController: mapController,
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        'https://map-style-url-here',
                    opacity: springOpacity,
                    maxZoom: 25),
                TileLayerOptions(
                    urlTemplate:
                        'http://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}',
                    opacity: satelliteOpacity,
                    subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
                    maxZoom: 25),
                TileLayerOptions(
                    urlTemplate:
                        'https://map-style-url-here',
                    opacity: galaxyOpacity,
                    subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
                    maxZoom: 25),
                MarkerLayerOptions(markers: markers),
                TileLayerOptions(
                    wmsOptions: wmsTileLayerOptions(
                        baseUrl:
                            'http://localhost/geoserver/project/wms?',
                        layers: ['buildings_layer'],
                        styles: ['buildings_layer_structype']),
                    backgroundColor: Colors.transparent,
                    opacity: layer1opacity,
                    maxZoom: 25),
                TileLayerOptions(
                    wmsOptions: wmsTileLayerOptions(
                        baseUrl:
                            'http://localhost/geoserver/project//wms?',
                        layers: ['jhe_containment'],
                        styles: ['jhe_containment_containtyp']),
                    backgroundColor: Colors.transparent,
                    opacity: layer2opacity,
                    maxZoom: 25),
                PolygonLayerOptions(polygons: [
                  Polygon(
                      points: polylinePoints,
                      color: Colors.transparent,
                      borderColor: Colors.purple,
                      borderStrokeWidth: 4.0)
                ]),
                markerLayerOptions,
              ],
              nonRotatedLayers: [
                userLocationOptions,
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
            backgroundColor: Color(0xff448AFF),
            mini: true,
            onPressed: polylinePoints.length > 0
                ? () async {
                    // var connection = PostgreSQLConnection(
                    //     'db.gwqybjrkashrliujmxol.supabase.co', 5432, 'postgres',
                    //     username: 'postgres',
                    //     password: 'imisinnovativeflutter');
                    // await connection.open();
                    noOfRows = polylinePoints.length;
                    if (polylinePoints.length == 1) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Save Containment Data?'),
                          content: Container(
                            height: MediaQuery.of(context).size.height / 10,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text('Latitude : '),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Text(polylinePoints[0]
                                        .latitude
                                        .toStringAsFixed(6))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('Longitude : '),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    Text(polylinePoints[0]
                                        .longitude
                                        .toStringAsFixed(6))
                                  ],
                                )
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Containment containment = Containment(
                                    latitude: polylinePoints[0]
                                        .latitude
                                        .toStringAsFixed(6),
                                    longitude: polylinePoints[0]
                                        .longitude
                                        .toStringAsFixed(6),
                                    email: supabase.auth.currentUser.email);
                                DatabaseHelper.instance
                                    .insertContainment(containment);
                                Navigator.pop(context);
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (polylinePoints.length > 1) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Save Building Data?'),
                          content: Table(
                            defaultColumnWidth: FixedColumnWidth(120.0),
                            children: tableRows(noOfRows),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                List<Geom> geomList = [];
                                for (int i = 0;
                                    i < polylinePoints.length;
                                    i++) {
                                  Geom geom = Geom(
                                      latitude: polylinePoints[i]
                                          .latitude
                                          .toStringAsFixed(6),
                                      longitude: polylinePoints[i]
                                          .longitude
                                          .toStringAsFixed(6));
                                  geomList.add(geom);
                                }
                                Building building = Building(
                                    email: supabase.auth.currentUser.email,
                                    geom: geomList);
                                DatabaseHelper.instance
                                    .insertBuilding(building);
                                Navigator.pop(context);
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                : null,
            child: Icon(Icons.save),
          ),
          SizedBox(height: 60.0),
          FloatingActionButton(
            backgroundColor: Color(0xff448AFF),
            child: Icon(Icons.layers_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    return ListView(
                      shrinkWrap: true,
                      children: [
                        Container(
                          height: 180.0,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 15.0, top: 15.0, right: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Layers:',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                Divider(
                                  height: 20,
                                  thickness: 1,
                                ),
                                SwitchListTile(
                                  secondary: Icon(Icons.layers_sharp),
                                  title: Text('The Buildings'),
                                  value: layer1,
                                  onChanged: (bool value) {
                                    setModalState(() {
                                      layer1 = value;
                                    });
                                    setState(() {
                                      layer1opacity == 0
                                          ? layer1opacity = 1
                                          : layer1opacity = 0;
                                    });
                                  },
                                ),
                                SwitchListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  secondary: Icon(Icons.layers_sharp),
                                  title: Text('The Containment'),
                                  value: layer2,
                                  onChanged: (bool value) {
                                    setModalState(() {
                                      layer2 = value;
                                    });
                                    setState(() {
                                      layer2opacity == 0
                                          ? layer2opacity = 1
                                          : layer2opacity = 0;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 200.0,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 15.0, top: 15.0, right: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Styles:',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                Divider(
                                  height: 20,
                                  thickness: 1,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 15.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ValueListenableBuilder(
                                        valueListenable: springBorder,
                                        builder: (BuildContext context,
                                            Color value, Widget child) {
                                          return StylesOption(
                                            onPressed: () {
                                              springBorder.value =
                                                  Color(0xff3681FE);
                                              satelliteBorder.value =
                                                  Colors.transparent;
                                              galaxyBorder.value =
                                                  Colors.transparent;
                                              setState(() {
                                                springOpacity = 1.0;
                                                satelliteOpacity = 0.0;
                                                galaxyOpacity = 0.0;
                                              });
                                            },
                                            optionName: 'Spring',
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'images/spring.png'),
                                                fit: BoxFit.cover),
                                            color: springBorder,
                                          );
                                        },
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: satelliteBorder,
                                        builder: (BuildContext context,
                                            Color value, Widget child) {
                                          return StylesOption(
                                            onPressed: () {
                                              springBorder.value =
                                                  Colors.transparent;
                                              satelliteBorder.value =
                                                  Color(0xff3681FE);
                                              galaxyBorder.value =
                                                  Colors.transparent;
                                              setState(() {
                                                springOpacity = 0.0;
                                                satelliteOpacity = 1.0;
                                                galaxyOpacity = 0.0;
                                              });
                                            },
                                            optionName: 'Satellite',
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'images/satellite.png'),
                                                fit: BoxFit.cover),
                                            color: satelliteBorder,
                                          );
                                        },
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: galaxyBorder,
                                        builder: (BuildContext context,
                                            Color value, Widget child) {
                                          return StylesOption(
                                            onPressed: () {
                                              springBorder.value =
                                                  Colors.transparent;
                                              satelliteBorder.value =
                                                  Colors.transparent;
                                              galaxyBorder.value =
                                                  Color(0xff3681FE);
                                              setState(() {
                                                springOpacity = 0.0;
                                                satelliteOpacity = 0.0;
                                                galaxyOpacity = 1.0;
                                              });
                                            },
                                            optionName: 'Galaxy',
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'images/galaxy.png'),
                                                fit: BoxFit.cover),
                                            color: galaxyBorder,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              );
            },
            mini: true,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }

  WMSTileLayerOptions wmsTileLayerOptions(
      {String baseUrl, List<String> layers, List<String> styles}) {
    WMSTileLayerOptions wmsTileLayerOptions;
    try {
      wmsTileLayerOptions = new WMSTileLayerOptions(
          baseUrl: baseUrl,
          format: 'image/png',
          transparent: true,
          version: '1.3.0',
          layers: layers,
          styles: styles);
    } catch (e) {
      print(e.toString());
    }
    return wmsTileLayerOptions;
  }

  Marker setMarker({LatLng point, int count, double distance}) {
    Marker marker = Marker(
      width: 80.0,
      height: 80.0,
      point: point,
      builder: (ctx) => GestureDetector(
        onTap: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  height: MediaQuery.of(ctx).size.height / 3.5,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marker :',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        Divider(
                          height: 20,
                          thickness: 1,
                        ),
                        Row(
                          children: [
                            Text('Latitude : '),
                            Expanded(child: Container()),
                            Text(point.latitude.toString()),
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          children: [
                            Text('Longitude : '),
                            Expanded(child: Container()),
                            Text(point.longitude.toString()),
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          children: [
                            Expanded(child: Column()),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red),
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    markerMap.removeWhere(
                                        (key, value) => key == markerId[point]);
                                    polylinePoints.remove(point);
                                    markerMap.clear();
                                    distances.clear();
                                    for (int i = 0;
                                        i < polylinePoints.toList().length;
                                        i++) {
                                      if (polylinePoints.length == 1) {
                                        Marker marker = setMarker(
                                            point: polylinePoints.toList()[i],
                                            count: i + 1);
                                        markerMap[i + 1] = marker;
                                        markerId[polylinePoints.toList()[i]] =
                                            i + 1;
                                      }
                                      if (polylinePoints.length > 1 &&
                                          (polylinePoints.length) != (i + 1)) {
                                        double distanceBetweenPoints =
                                            MapsToolkit.SphericalUtil
                                                .computeDistanceBetween(
                                                    MapsToolkit.LatLng(
                                                        polylinePoints[i]
                                                            .latitude,
                                                        polylinePoints[i]
                                                            .longitude),
                                                    MapsToolkit.LatLng(
                                                        polylinePoints[i + 1]
                                                            .latitude,
                                                        polylinePoints[i + 1]
                                                            .longitude));
                                        distances[i + 1] = double.parse(
                                            distanceBetweenPoints
                                                .toStringAsFixed(2));

                                        setState(() {
                                          markerMap.clear();
                                          markerId.clear();
                                          for (int i = 0;
                                              i <
                                                  polylinePoints
                                                      .toList()
                                                      .length;
                                              i++) {
                                            Marker marker = setMarker(
                                                point:
                                                    polylinePoints.toList()[i],
                                                count: i + 1,
                                                distance: distances[i + 1]);
                                            markerMap[i + 1] = marker;
                                            markerId[polylinePoints
                                                .toList()[i]] = i + 1;
                                          }
                                        });
                                      }
                                      if (polylinePoints.length > 2 &&
                                          (polylinePoints.length) == (i + 1)) {
                                        double dist = MapsToolkit.SphericalUtil
                                            .computeDistanceBetween(
                                                MapsToolkit.LatLng(
                                                    polylinePoints[0].latitude,
                                                    polylinePoints[0]
                                                        .longitude),
                                                MapsToolkit.LatLng(
                                                    polylinePoints[
                                                            polylinePoints
                                                                    .length -
                                                                1]
                                                        .latitude,
                                                    polylinePoints[
                                                            polylinePoints
                                                                    .length -
                                                                1]
                                                        .longitude));

                                        setState(() {
                                          distances[polylinePoints.length] =
                                              double.parse(
                                                  dist.toStringAsFixed(2));
                                          markerMap.clear();
                                          markerId.clear();
                                          for (int i = 0;
                                              i <
                                                  polylinePoints
                                                      .toList()
                                                      .length;
                                              i++) {
                                            Marker marker = setMarker(
                                                point:
                                                    polylinePoints.toList()[i],
                                                count: i + 1,
                                                distance: distances[i + 1]);
                                            markerMap[i + 1] = marker;
                                            markerId[polylinePoints
                                                .toList()[i]] = i + 1;
                                          }
                                        });
                                      }
                                      noOfRows = polylinePoints.length;
                                    }
                                    i--;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.remove_circle),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text('REMOVE'),
                                  ],
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              });
        },
        child: Container(
          child: Column(
            children: [
              Badge(
                position: BadgePosition.topEnd(top: -30.0, end: -30.0),
                toAnimate: false,
                shape: BadgeShape.square,
                badgeColor: Colors.red,
                borderRadius: BorderRadius.circular(8),
                badgeContent: distance == null
                    ? Text(
                        count.toString(),
                      )
                    : Text(
                        count.toString() + ': $distance',
                      ),
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return marker;
  }

  tableRows(int rows) {
    List<TableRow> tableRowsList = [];
    tableRowsList.add(TableRow(children: [
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Latitude', style: TextStyle(fontSize: 17.0))]),
      Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [Text('Longitude', style: TextStyle(fontSize: 17.0))]),
    ]));
    for (int i = 0; i < rows; i++) {
      tableRowsList.add(TableRow(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(polylinePoints[i].latitude.toStringAsFixed(6),
              style: TextStyle(fontSize: 15.0))
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(polylinePoints[i].longitude.toStringAsFixed(6),
              style: TextStyle(fontSize: 15.0))
        ]),
      ]));
    }
    return tableRowsList;
  }
}

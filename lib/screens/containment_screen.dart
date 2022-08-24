import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:my_app/constants/constants.dart';
import 'package:my_app/models/AssessmentData.dart';
import 'package:my_app/models/Supabase_helper.dart';
import 'package:my_app/widgets/MyFormField.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContainmentScreen extends StatefulWidget {
  static final id = 'ContainmentScreen';
  @override
  _ContainmentScreenState createState() => _ContainmentScreenState();
}

class _ContainmentScreenState extends State<ContainmentScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  List appIDList = [];
  Map<int, String> tankType = {};
  bool _isSepticTank = false;
  String _email;
  bool _inAsyncCall = false;

  @override
  void initState() {
    super.initState();
    recoverSession();
    fetchAppID();
  }

  recoverSession() async {
    setState(() {
      _inAsyncCall = true;
    });
    final prefs = await SharedPreferences.getInstance();
    String jsonStr = prefs.getString(PERSIST_SESSION_KEY);
    final response = await supabase.auth.recoverSession(jsonStr);
    prefs.setString(PERSIST_SESSION_KEY, response.data.persistSessionString);
    _email = response.user.email;
    setState(() {
      _inAsyncCall = false;
    });
  }

  fetchAppID() async {
    setState(() {
      _inAsyncCall = true;
    });
    final appID = await supabase
        .from('applications')
        .select('id,containtyp')
        .eq('assessment_status', '0')
        .execute();
    setState(() {
      for (Map<String, dynamic> map in appID.data) {
        appIDList.add(map['id']);
        tankType[map['id']] = map['containtyp'];
      }
      _inAsyncCall = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Containment Assessment'),
        actions: <Widget>[],
        backgroundColor: Color.fromRGBO(101, 157, 82, 1),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _inAsyncCall,
        child: ListView(children: [
          FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  MyFormField(
                    fieldLabel: 'Application ID*',
                    widget: FormBuilderDropdown(
                      name: 'appId',
                      hint: Text('Select Application ID'),
                      validator: FormBuilderValidators.compose(
                          [FormBuilderValidators.required(context)]),
                      items: appIDList
                          .map((id) => DropdownMenuItem(
                                value: id,
                                child: Text("$id"),
                                onTap: () {
                                  if (tankType[id] == 'Septic Tank') {
                                    setState(() {
                                      _isSepticTank = true;
                                    });
                                  } else {
                                    setState(() {
                                      _isSepticTank = false;
                                    });
                                  }
                                },
                              ))
                          .toList(),
                      decoration: kInputDecoration,
                    ),
                  ), //appId
                  MyFormField(
                    fieldLabel: 'Service Provider*',
                    widget: FormBuilderDropdown(
                      name: 'serviceProvider',
                      validator: FormBuilderValidators.compose(
                          [FormBuilderValidators.required(context)]),
                      hint: Text('Select Service Provider'),
                      items: ['A', 'B', 'C']
                          .map((id) =>
                              DropdownMenuItem(value: id, child: Text("$id")))
                          .toList(),
                      decoration: kInputDecoration,
                    ),
                  ), //service provider
                  MyFormField(
                    fieldLabel: 'Distance from road (m)*',
                    widget: FormBuilderTextField(
                      name: 'disRoad',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter distance from road'),
                    ),
                  ), //disRoad
                  MyFormField(
                    fieldLabel: 'Road width (m)*',
                    widget: FormBuilderTextField(
                      name: 'widthRoad',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter road width'),
                    ),
                  ), //roadWidth
                  MyFormField(
                    fieldLabel: 'Estimated assessed sludge(m3)*',
                    widget: FormBuilderTextField(
                      name: 'estSludge',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter estimated assessed sludge'),
                    ),
                  ), //volume
                  MyFormField(
                    fieldLabel: _isSepticTank
                        ? 'Septic Tank Length (m)*'
                        : 'Pit Length(m)*',
                    widget: FormBuilderTextField(
                      name: 'tankLen',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: _isSepticTank
                              ? 'Enter septic tank length'
                              : 'Enter pit length'),
                    ),
                  ), //tankLen
                  MyFormField(
                    fieldLabel: _isSepticTank
                        ? 'Septic Tank Width (m)*'
                        : 'Pit Width (m)*',
                    widget: FormBuilderTextField(
                      name: 'tankWid',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: _isSepticTank
                              ? 'Enter septic tank width'
                              : 'Enter pit width'),
                    ),
                  ), //tankWid
                  MyFormField(
                    fieldLabel: 'Tank Depth (m)*',
                    widget: FormBuilderTextField(
                      name: 'tankDep',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter tank depth'),
                    ),
                  ), //tankDep
                  MyFormField(
                    fieldLabel: 'Vacutag Accessibility? *',
                    widget: FormBuilderRadioGroup(
                      name: 'vacutag',
                      validator: FormBuilderValidators.compose(
                          [FormBuilderValidators.required(context)]),
                      decoration: kInputDecoration.copyWith(
                        alignLabelWithHint: true,
                      ),
                      options: [
                        FormBuilderFieldOption(value: 'Yes'),
                        FormBuilderFieldOption(value: 'No')
                      ],
                      separator: SizedBox(
                        width: 40,
                      ),
                    ),
                  ), //vacutag accessibility
                  MyFormField(
                    fieldLabel: 'Required trips *',
                    widget: FormBuilderTextField(
                      name: 'reqTrips',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter required trips'),
                    ),
                  ), //reqTrips
                  MyFormField(
                    fieldLabel: 'Comments *',
                    widget: FormBuilderTextField(
                      name: 'comments',
                      validator: FormBuilderValidators.compose(
                          [FormBuilderValidators.required(context)]),
                      maxLines: 4,
                      decoration:
                          kInputDecoration.copyWith(hintText: 'Enter comments'),
                    ),
                  ), //comments
                  MyFormField(
                    fieldLabel: 'Proposed emptying Date*',
                    widget: FormBuilderDateTimePicker(
                      name: 'proposedDate',
                      validator: FormBuilderValidators.compose(
                          [FormBuilderValidators.required(context)]),
                      inputType: InputType.date,
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter proposed emptying date'),
                    ),
                  ), //emptiedDate
                  MyFormField(
                    fieldLabel: 'Estimated Cost*',
                    widget: FormBuilderTextField(
                      name: 'cost',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter estimated cost'),
                    ),
                  ), //costOfDispo
                  SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints.tightFor(height: 50),
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _inAsyncCall = true;
                              });
                              if (_formKey.currentState.validate()) {
                                AssessmentData assessmentData =
                                    AssessmentData.fromJson({
                                  "application_id": _formKey
                                      .currentState.fields['appId'].value
                                      .toString()
                                      .trim(),
                                  "servcode": _formKey.currentState
                                      .fields['serviceProvider'].value
                                      .toString()
                                      .trim(),
                                  "estimated_cost": _formKey
                                      .currentState.fields['cost'].value
                                      .toString()
                                      .trim(),
                                  "rddist": _formKey
                                      .currentState.fields['disRoad'].value
                                      .toString()
                                      .trim(),
                                  "rdwidth": _formKey
                                      .currentState.fields['widthRoad'].value
                                      .toString()
                                      .trim(),
                                  "sludgeasd": _formKey
                                      .currentState.fields['estSludge'].value
                                      .toString()
                                      .trim(),
                                  "proposed_emptying_date": _formKey
                                      .currentState.fields['proposedDate'].value
                                      .toString()
                                      .trim(),
                                  "user_id": _email.toString().trim(),
                                  "tank_width": _formKey
                                      .currentState.fields['tankWid'].value
                                      .toString()
                                      .trim(),
                                  "tank_length": _formKey
                                      .currentState.fields['tankLen'].value
                                      .toString()
                                      .trim(),
                                  "tank_depth": _formKey
                                      .currentState.fields['tankDep'].value
                                      .toString()
                                      .trim(),
                                  "vacutag_accessibility": _formKey
                                      .currentState.fields['vacutag'].value
                                      .toString()
                                      .trim(),
                                  "reqd_trips": _formKey
                                      .currentState.fields['reqTrips'].value
                                      .toString()
                                      .trim(),
                                  "comments": _formKey
                                      .currentState.fields['comments'].value
                                      .toString()
                                      .trim(),
                                });
                                final response = await supabase
                                    .from('assessments')
                                    .insert(assessmentData.toJson())
                                    .execute();
                                switch (response.status) {
                                  case 201:
                                    final res = await supabase
                                        .from('applications')
                                        .update({'assessment_status': '1'})
                                        .eq(
                                            'id',
                                            _formKey.currentState
                                                .fields['appId'].value
                                                .toString()
                                                .trim())
                                        .execute();
                                    if (res.status == 200) {
                                      _formKey.currentState.reset();
                                      setState(() {
                                        appIDList.clear();
                                        fetchAppID();
                                      });
                                    }
                                }
                                setState(() {
                                  _inAsyncCall = false;
                                });
                              } else {}
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                'SUBMIT',
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Color.fromRGBO(101, 157, 82, 1),
                                ),
                                elevation:
                                    MaterialStateProperty.all<double>(5.0)),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}

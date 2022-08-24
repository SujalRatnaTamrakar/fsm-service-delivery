import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:my_app/constants/constants.dart';
import 'package:my_app/models/EmptierData.dart';
import 'package:my_app/models/Supabase_helper.dart';
import 'package:my_app/widgets/MyFormField.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmptyingServiceScreen extends StatefulWidget {
  static final id = 'EmptyingServiceScreen';

  @override
  _EmptyingServiceScreenState createState() => _EmptyingServiceScreenState();
}

class _EmptyingServiceScreenState extends State<EmptyingServiceScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  List appIDList = [];
  String _email;
  bool _inAsyncCall = false;

  @override
  void initState() {
    recoverSession();
    fetchAppID();
    super.initState();
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
        .select('id,emptying_status')
        .eq('assessment_status', '1')
        .eq('emptying_status', '0')
        .execute();
    setState(() {
      for (Map<String, dynamic> map in appID.data) {
        appIDList.add(map['id']);
      }
      _inAsyncCall = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emptying Service Form'),
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
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      hint: Text('Select Application ID'),
                      items: appIDList
                          .map((id) =>
                              DropdownMenuItem(value: id, child: Text("$id")))
                          .toList(),
                      decoration: kInputDecoration,
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'Emptied Date*',
                    widget: FormBuilderDateTimePicker(
                      name: 'emptiedDate',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      inputType: InputType.date,
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter emptied date'),
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'Vacutug Number*',
                    widget: FormBuilderTextField(
                      name: 'vaccutagNum',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter Vacutug Number'),
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'Vacutug Capacity (ltr)*',
                    widget: FormBuilderDropdown(
                      name: 'vaccutugCap',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      hint: Text('Select Capacity'),
                      allowClear: true,
                      items: ['1', '2', '3']
                          .map((id) =>
                              DropdownMenuItem(value: id, child: Text("$id")))
                          .toList(),
                      decoration: kInputDecoration,
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'Place of Disposal*',
                    widget: FormBuilderDropdown(
                      name: 'pod',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      hint: Text('Select place of disposal'),
                      allowClear: true,
                      items: ['A', 'B', 'C']
                          .map((id) =>
                              DropdownMenuItem(value: id, child: Text("$id")))
                          .toList(),
                      decoration: kInputDecoration,
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'Driver*',
                    widget: FormBuilderTextField(
                      name: 'driver',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      decoration:
                          kInputDecoration.copyWith(hintText: 'Enter driver'),
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'Emptier 1*',
                    widget: FormBuilderTextField(
                      name: 'emp1',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter emptier 1'),
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'Emptier 2*',
                    widget: FormBuilderTextField(
                      name: 'emp2',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter emptier 2'),
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'Start Time*',
                    widget: FormBuilderDateTimePicker(
                      name: 'startTime',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      inputType: InputType.time,
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter start time'),
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'End Time*',
                    widget: FormBuilderDateTimePicker(
                      name: 'endTime',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      inputType: InputType.time,
                      decoration:
                          kInputDecoration.copyWith(hintText: 'Enter End Time'),
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'Required Trip for Total Emptying*',
                    widget: FormBuilderTextField(
                      name: 'trip',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter Required Trip for Total Emptying'),
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'Receipt Number*',
                    widget: FormBuilderTextField(
                      name: 'receipt',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter Receipt Number'),
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'Cost paid by Containment owner with receipt*',
                    widget: FormBuilderTextField(
                      name: 'costWReceipt',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText:
                              'Enter Cost paid by Containment owner with receipt'),
                    ),
                  ),
                  MyFormField(
                    fieldLabel:
                        'Cost paid by Containment owner without receipt*',
                    widget: FormBuilderTextField(
                      name: 'costWOReceipt',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText:
                              'Enter Cost paid by Containment owner without receipt'),
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'Cost of disposal*',
                    widget: FormBuilderTextField(
                      name: 'cod',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter Cost of disposal'),
                    ),
                  ),
                  MyFormField(
                    fieldLabel: 'Volume of sludge(m3)*',
                    widget: FormBuilderTextField(
                      name: 'vos',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.numeric(context)
                      ]),
                      decoration: kInputDecoration.copyWith(
                          hintText: 'Enter Volume of sludge(m3)'),
                    ),
                  ),
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
                                EmptierData emptierData = EmptierData.fromJson({
                                  "application_id": _formKey
                                      .currentState.fields['appId'].value,
                                  "sludgevol": int.parse(_formKey
                                      .currentState.fields['vos'].value),
                                  "emptytime": _formKey
                                      .currentState.fields['emptiedDate'].value
                                      .toString()
                                      .trim(),
                                  "vacutug_no": int.parse(_formKey.currentState
                                      .fields['vaccutagNum'].value),
                                  "capacity": int.parse(_formKey.currentState
                                      .fields['vaccutugCap'].value),
                                  "driver": _formKey
                                      .currentState.fields['driver'].value
                                      .toString()
                                      .trim(),
                                  "emptier1": _formKey
                                      .currentState.fields['emp1'].value
                                      .toString()
                                      .trim(),
                                  "emptier2": _formKey
                                      .currentState.fields['emp2'].value
                                      .toString()
                                      .trim(),
                                  "start_time": _formKey
                                      .currentState.fields['startTime'].value
                                      .toString()
                                      .trim(),
                                  "end_time": _formKey
                                      .currentState.fields['endTime'].value
                                      .toString()
                                      .trim(),
                                  "reqtrips": int.parse(_formKey
                                      .currentState.fields['trip'].value),
                                  "receiptcost": int.parse(_formKey.currentState
                                      .fields['costWReceipt'].value),
                                  "noreceiptcost": int.parse(_formKey
                                      .currentState
                                      .fields['costWOReceipt']
                                      .value),
                                  "disposalcost": int.parse(_formKey
                                      .currentState.fields['cod'].value),
                                  "disposalplace": _formKey
                                      .currentState.fields['pod'].value
                                      .toString()
                                      .trim(),
                                  "receipt_number": _formKey
                                      .currentState.fields['receipt'].value
                                      .toString()
                                      .trim(),
                                });
                                final response = await supabase
                                    .from('emptying_services')
                                    .insert(emptierData.toJson())
                                    .execute();
                                switch (response.status) {
                                  case 201:
                                    final res = await supabase
                                        .from('applications')
                                        .update({'emptying_status': '1'})
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
                                  _inAsyncCall = true;
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

import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

const PERSIST_SESSION_KEY = 'PERSIST_SESSION_KEY';

const kInputDecoration = InputDecoration(
  labelStyle: TextStyle(
    fontWeight: FontWeight.bold,
  ),
  enabledBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromRGBO(101, 157, 82, 1), width: 2.5),
  ),
  errorBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
  focusedErrorBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
  disabledBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
);

const kLoginInputDecoration = InputDecoration(
  labelStyle: TextStyle(
    color: Colors.white,
  ),
  enabledBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.5),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.5),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.5),
  ),
);

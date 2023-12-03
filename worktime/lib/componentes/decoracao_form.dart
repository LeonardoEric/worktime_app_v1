import 'package:flutter/material.dart';
import 'package:worktime/_comum/minhas_cores.dart';

InputDecoration getAuthenticationInputDecoration(String label){
  return InputDecoration(
    hintText: label,
    fillColor: MinhasCores.cinzaClaro,
    filled: true,
    contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25),
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:worktime/_comum/minhas_cores.dart';

class TelaLoad extends StatelessWidget{
  const TelaLoad({super.key});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: MinhasCores.azulEscuro,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
              MinhasCores.azulClaro,
              MinhasCores.azulEscuro
            ],
            ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Image.asset("assets/logo_branca.png", height: 128),
    ]
    ),
        ],
      )
    );
  }
}
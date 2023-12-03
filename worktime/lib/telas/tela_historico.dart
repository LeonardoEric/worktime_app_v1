import 'package:flutter/material.dart';
import 'package:worktime/telas/tela_principal.dart';

class TelaHistorico extends StatelessWidget {
  final List<Registro> registros;

  TelaHistorico(this.registros);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Histórico"),
      ),
      body: ListView.builder(
        itemCount: registros.length,
        itemBuilder: (context, index) {
          final registro = registros[index];
          return ListTile(
            title: Text("${registro.tipo}: ${registro.dataHora}"),
          );
        },
      ),
    );
  }
}


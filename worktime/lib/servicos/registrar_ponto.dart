import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de data/hora

class RegistrarEntrada{

  String entrada = "";

  Future<void> registrarEntrada(String uid) async {
    // Obtém a data e hora atual
    final DateTime agora = DateTime.now();
    entrada = "${agora.hour}:${agora.minute}:${agora.second}";
    // Formata a data e hora para uma representação legível
    final String dataHoraFormatada = DateFormat('yyyy-MM-dd HH:mm:ss').format(
        agora);

    // Agora você pode usar a variável "dataHoraFormatada" para enviar para o Cloud Firestore ou fazer o que for necessário.

    // Exemplo de envio para o Cloud Firestore (assumindo que você já configurou a conexão com o Firestore):
    await FirebaseFirestore.instance.collection('registros_de_ponto').add({
      'data_hora': dataHoraFormatada,
      // Outros campos, se necessário

    },
    );
    print('$dataHoraFormatada');
  }

}


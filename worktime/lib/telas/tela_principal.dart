import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:worktime/servicos/autenticacao_servico.dart';
import 'package:worktime/servicos/registrar_ponto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:worktime/telas/tela_historico.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class Registro {
  final String tipo;
  final String dataHora;

  Registro(this.tipo, this.dataHora);
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({Key? key}) : super(key: key);

  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class StorageService{
  String pathService = "images";
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<void> upload({required File file, required String fileName}) async {
    await _firebaseStorage.ref("$pathService/$fileName.png").putFile(file);
  }

  Future<String> getImageUrl(String fileName) async {
    try {
      final downloadUrl = await _firebaseStorage.ref("$pathService/$fileName.png").getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erro ao obter a URL da imagem: $e');
      return ''; // ou null, dependendo do que você preferir retornar em caso de erro
    }
  }

}

class _TelaPrincipalState extends State<TelaPrincipal> {
  List<Registro> registros = [];
  String imageUrl = '';
  String tipo1 = "entrada";
  String tipo2 = "inicio almoço";
  String tipo3 = "fim almoço";
  String tipo4 = "saída";

  User? user = FirebaseAuth.instance.currentUser;
  String? nomeUsuario;
  String? emailUsuario;
  String? uidUltimoDocumento;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late CameraController _cameraController;
  late Future<void> _initializeCameraControllerFuture;

  // Adicione um método para obter a câmera frontal
  Future<CameraDescription> getFrontCamera() async {
    final cameras = await availableCameras();
    return cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );
  }

  @override
  void initState() {
    super.initState();
    carregarDadosUsuario();
    _initializeCamera();
  }

  void _initializeCamera() async{
    final frontCamera = await getFrontCamera();

    setState(() {
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
      );

      _initializeCameraControllerFuture = _cameraController.initialize();
    });

    if (mounted){
      setState(() {

      });
    }
  }

  void carregarDadosUsuario() {
    if (user != null) {
      setState(() {
        nomeUsuario = user?.displayName;
        emailUsuario = user?.email;
      });
    }
  }

  @override
  void dispose() {
    // Descarte o controlador da câmera ao destruir o widget
    _cameraController.dispose();
    super.dispose();
  }

  // Função para tirar uma foto
  Future<void> takePicture() async {
    try {
      // Aguarde a inicialização do controlador da câmera antes de tirar uma foto
      await _initializeCameraControllerFuture;

      // Exiba um diálogo com a visualização da câmera e botão para tirar a foto
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: CameraPreview(_cameraController),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Capture uma foto
                final XFile picture = await _cameraController.takePicture();

                // Crie uma instância da sua classe StorageService
                final StorageService storageService = StorageService();

                // Gere um nome único para o arquivo (pode ser baseado na data/hora, por exemplo)
                String fileName = DateTime.now().millisecondsSinceEpoch.toString();

                // Use o método upload da StorageService para enviar a foto para o Storage
                await storageService.upload(file: File(picture.path), fileName: fileName);

                // Obtenha a URL da imagem carregada
                final imageUrl = await storageService.getImageUrl(fileName);

                // Feche o diálogo
                Navigator.pop(context);

                // Faça algo com a URL da imagem, como salvar no Firestore ou exibir na tela
                print('URL da imagem carregada: $imageUrl');

                // Faça algo com a imagem
                print('Caminho da imagem: ${picture.path}');
              },
              child: const Text("Tirar Foto"),
            ),
          ],
        ),
      );

    } catch (e) {
      print('Erro ao tirar foto: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("WorkTime"),
        elevation: 0,
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(backgroundColor: Colors.white),
              accountName: nomeUsuario != null
                  ? Text("Nome do Usuário: $nomeUsuario")
                  : const Text("Nome do Usuário: Nome não disponível"),
              accountEmail: emailUsuario != null
                  ? Text("E-mail do Usuário: $emailUsuario")
                  : const Text("E-mail do Usuário: E-mail não disponível"),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("Histórico"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaHistorico(registros),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Sair"),
              onTap: () {
                AutenticacaoServico().deslogar();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async{
                    //await takePicture();
                    final user = FirebaseAuth.instance.currentUser;
                    if (user!=null){
                      final uid = user.uid;
                      final agora = DateTime.now();
                      final horaFormatada = DateFormat('HH:mm:ss').format(agora);
                      final dataFormatada = DateFormat('yyyy-MM-dd').format(agora);
                      final StorageService storageService = StorageService();

                      String tipoRegistro;
                      if (registros.length == 3) {
                        tipoRegistro = tipo4;
                      } else if (registros.length == 2) {
                        tipoRegistro = tipo3;
                      } else if (registros.length == 1) {
                        tipoRegistro = tipo2;
                      } else {
                        tipoRegistro = tipo1;
                      }

                      if (registros.length >= 4){
                        registros.clear();
                      }

                      final firestore = FirebaseFirestore.instance;
                      final registrosCollectionRef = FirebaseFirestore.instance.collection('registros');
                      final colecao = firestore.collection('registros');


                      // Consulte os documentos ordenados por um campo de data em ordem decrescente
                      final query = colecao.where('uid do usuario', isEqualTo: uid).orderBy('data', descending: true).limit(1);

                      final querySnapshot = await query.get();

                      if (querySnapshot.docs.isNotEmpty) {
                        final ultimoDocumento = querySnapshot.docs.first;
                        final dataUltimoDocumento = ultimoDocumento.data()['data'] as String; // Suponha que a data seja armazenada como String
                        if(dataUltimoDocumento == dataFormatada){
                          // As datas são iguais, adicione a hora atual ao último documento encontrado

                          // Atualize o documento existente
                          if(ultimoDocumento.data()?['entrada'] == ''){
                            takePicture();
                            await ultimoDocumento.reference.update({
                              'entrada': horaFormatada,
                              'imagem_entrada': imageUrl, // adicione a URL da imagem
                            });
                            uidUltimoDocumento = ultimoDocumento.id;
                            print('Hora atual adicionada ao documento $uidUltimoDocumento');
                          }else if(ultimoDocumento.data()?['inicio almoço'] == ''){
                            takePicture();
                            await ultimoDocumento.reference.update({
                              'inicio almoço': horaFormatada,
                              'imagem_inicio_almoço': imageUrl, // adicione a URL da imagem
                            });
                            uidUltimoDocumento = ultimoDocumento.id;
                            print('Hora atual adicionada ao documento $uidUltimoDocumento');
                          }else if(ultimoDocumento.data()?['fim almoço'] == ''){
                            takePicture();
                            await ultimoDocumento.reference.update({
                              'fim almoço': horaFormatada,
                              'imagem_fim_almoço': imageUrl, // adicione a URL da imagem
                            });
                            uidUltimoDocumento = ultimoDocumento.id;
                            print('Hora atual adicionada ao documento $uidUltimoDocumento');
                          }else if(ultimoDocumento.data()?['saida'] == ''){
                            takePicture();
                            await ultimoDocumento.reference.update({
                              'saida': horaFormatada,
                              'imagem_saida': imageUrl, // adicione a URL da imagem
                            });
                            uidUltimoDocumento = ultimoDocumento.id;
                            print('Hora atual adicionada ao documento $uidUltimoDocumento');
                          }else{
                            print('Não é possível realizar o registro');
                          }
                        }

                        else{
                          // As datas são diferentes, crie um novo documento com a hora atual

                          await colecao.add({
                            'nome': nomeUsuario,
                            'email': emailUsuario,
                            'uid do usuario': uid,
                            'data': dataFormatada,
                            'entrada': horaFormatada,
                            'inicio almoço': '',
                            'fim almoço': '',
                            'saida': '',
                            'imagem_entrada': imageUrl,
                            'imagem_inicio_almoço': '',
                            'imagem_fim_almoço': '',
                            'imagem_saida': '',

                          });
                          takePicture();

                          print('Novo documento criado com a hora atual 1.');
                        }

                      } else {
                        // Não há documentos na coleção, crie um novo documento com a hora atual

                        await colecao.add({
                          'nome': nomeUsuario,
                          'email': emailUsuario,
                          'uid do usuario': uid,
                          'data': dataFormatada,
                          'entrada': horaFormatada,
                          'inicio almoço': '',
                          'fim almoço': '',
                          'saida': '',
                          'imagem_entrada': imageUrl,
                          'imagem_inicio_almoço': '',
                          'imagem_fim_almoço': '',
                          'imagem_saida': '',
                        });
                        takePicture();

                        print('Novo documento criado com a hora atual 2.');
                      }
                    }else{
                      print('Usuário não autenticado');
                    }
                  },
                  child: const Text("Registrar Ponto"),
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(200, 40)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),

            // Lista os registros na tela
            ListView.builder(
              shrinkWrap: true,
              itemCount: registros.length,
              itemBuilder: (context, index) {
               final registro = registros[index];
               return ListTile(
                 title: Text("${registro.tipo}: ${registro.dataHora}"),
               );
             },
            ),
          ],
        ),
      ),
    );
  }
}

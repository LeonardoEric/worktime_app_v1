import 'package:flutter/material.dart';
import 'package:worktime/_comum/meu_snackbar.dart';
import 'package:worktime/_comum/minhas_cores.dart';
import 'package:worktime/componentes/decoracao_form.dart';
import 'package:worktime/servicos/autenticacao_servico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class TelaForm extends StatefulWidget{
  const TelaForm({super.key});

  @override
  State<TelaForm> createState() => _TelaFormState();
}

class _TelaFormState extends State<TelaForm> {
  bool entrar = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();

  AutenticacaoServico _autenServico = AutenticacaoServico();

  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: Stack(
          children: [
            Container(

            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Image.asset("assets/logo_azul.png", height: 128),
                      const SizedBox(height: 32,
                      ),
                      Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: getAuthenticationInputDecoration("E-mail"),
                            validator: (String? value){
                            if(value == null || value.isEmpty) {
                              return "E-mail incorreto";
                            }
                            if(!value.contains("@")){
                              return "E-mail incorreto";
                            }
                            return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _senhaController,
                            decoration: getAuthenticationInputDecoration("Senha"),
                            validator: (String? value){
                              if(value == null || value.isEmpty) {
                                return "Senha incorreta";
                              }
                              if(value.length < 6){
                                return "Senha incorreta";
                              }
                              return null;
                            },
                            obscureText: true,
                          ),
                          const SizedBox(height: 8),
                      ],
                      ),

                      Visibility(visible: !entrar, child: Column(
                        children: [


                          TextFormField(decoration: getAuthenticationInputDecoration("Confirmar Senha"),
                            validator: (String? value){
                              if(value == null || value.isEmpty) {
                                return "Senha incorreta";
                              }
                              if(value.length < 6){
                                return "Senha incorreta";
                              }
                              if(value != _senhaController.text){
                                return "As senhas são diferentes";
                              }
                              return null;
                            },
                            obscureText: true,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nomeController,
                            decoration: getAuthenticationInputDecoration("Nome"),
                            validator: (String? value){
                              if(value == null || value.isEmpty) {
                                return "O campo deve ser preenchido";
                              }
                              return null;
                            },
                          ),
                        ],
                      )),
                      const SizedBox(height: 16,
                      ),
                      ElevatedButton(onPressed: (){
                        botaoClicado();
                      },
                          child: Text((entrar)?"Entrar" : "Enviar"),
                      ),
                      TextButton(onPressed: (){
                        setState(() {
                          entrar = !entrar;
                        });
                      },
                        child: Text((entrar)? "Cadastre-se" : "Entre com sua conta"),
                      ),
                    ],
                ),
              ),
            ),
          ],
        )
    );
  }
  botaoClicado() async{
    String email = _emailController.text;
    String senha = _senhaController.text;
    String nome = _nomeController.text;
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (_formKey.currentState!.validate()) {
      if (entrar) {
        print("Login em andamento...");

        try {
          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: senha);

          // Autenticação bem-sucedida, você pode acessar userCredential.user.uid
          String uid = userCredential.user?.uid ?? '';

          print("Usuário logado com sucesso. Nome: $nome UID: $uid");
          Usuario usuario = Usuario(nome, email);

          // Lógica adicional após o login bem-sucedido, se necessário

        } catch (e) {
          // Trate os erros de autenticação aqui
          print("Erro ao fazer login: $e");
          mostrarSnackBar(context: context, texto: "E-mail/senha incorretos");
        }
      } else {
        print("Cadastro em andamento...");

        try {
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: senha);

          // Autenticação bem-sucedida, você pode acessar userCredential.user.uid
          String uid = userCredential.user?.uid ?? '';

          print("Usuário cadastrado com sucesso.Nome: $nome UID: $uid");

          // Lógica adicional após o registro bem-sucedido, se necessário

          // Após o registro bem-sucedido, você pode criar o usuário no Firestore
          await criarUsuario(nome, email, uid);

          mostrarSnackBar(
              context: context, texto: "Cadastro realizado com sucesso", isErro: false);
        } catch (e) {
          // Trate os erros de autenticação aqui
          print("Erro ao fazer o cadastro: $e");
          mostrarSnackBar(context: context, texto: "Erro no cadastro");
        }
      }
    } else {
      print("Formulário inválido");
    }
  }

  Future<void> criarUsuario(String nome, String email, String uid) async {
    try {
      // Crie um novo documento na coleção "users" com o uid como ID
      await FirebaseFirestore.instance.collection('users').doc(nome).set({
        'nome': nome,
        'email': email,
        'uid': uid,
        // Outros campos, se necessário
      });
    } catch (e) {
      print("Erro ao criar usuário no Firestore: $e");
      // Lide com o erro de alguma forma, como mostrar uma mensagem de erro
    }
  }

}

class Usuario {
  final String nome;
  final String email;

  Usuario(this.nome, this.email);
}

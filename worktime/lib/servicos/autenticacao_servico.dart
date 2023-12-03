import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AutenticacaoServico{
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future <String?> cadastrarUsuario({required String email, required String senha,})
  async{
    try {

      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: senha
      );

      return null;

    } on FirebaseAuthException catch (e){
      if (e.code == "email-already-in-use"){
        return "O e-mail já foi cadastrado";
      }
      return "Erro desconhecido";
    }
  }

  Future<String?> logarUsuarios({required String email, required String senha}) async{
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha,);
      return null;
    } on FirebaseAuthException catch (e){
      return e.message;
    }
  }
  Future<void> deslogar()async{
    print("Chamando a função de deslogar");
    await FirebaseAuth.instance.signOut();
    print("Usuário deslogado com sucesso");
  }


}
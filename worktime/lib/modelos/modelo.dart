class Modelo{
 String id;
 String nome;
 String hora;
 String? urlImagem;

 Modelo({
   required this.id,
   required this.nome,
   required this.hora,
 });

 Modelo.fromMap(Map<String, dynamic>map):
       id = map["id"],
       nome = map["nome"],
       hora = map["hora"],
       urlImagem = map["urlImagem"];

 Map<String, dynamic> toMap(){
   return{
     "id": id,
     "hora": nome,
     "hora": hora,
     "urlImagem": urlImagem,
   };
 }
}
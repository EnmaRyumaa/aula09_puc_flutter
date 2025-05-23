import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  _recuperarBD() async {
    final caminho = await getDatabasesPath();
    final local = join(caminho, "bancodados.db");

    var retorno = await openDatabase(
      local,
      version: 1,
      onCreate: (db, dbVersaoRecente) {
        String sql = "CREATE TABLE usuarios ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "matricula TEXT UNIQUE, "
            "nome TEXT, "
            "idade INTEGER, "
            "curso TEXT)";
        db.execute(sql);
      },
    );

    return retorno;
  }

  _salvarDados(BuildContext context, String nome, int idade, String matricula, String curso) async {
    Database db = await _recuperarBD();

    Map<String, dynamic> dadosUsuario = {
      "matricula": matricula,
      "nome": nome,
      "idade": idade,
      "curso": curso,
    };

    try {
      int id = await db.insert("usuarios", dadosUsuario);
      _mostrarDialogo(context, "Usuário salvo com sucesso!");
    } catch (e) {
      _mostrarDialogo(context, "Erro ao salvar: Matrícula já cadastrada.");
    }
  }

  _mostrarDialogo(BuildContext context, String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Resultado"),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  _listarUsuarios() async {
    Database db = await _recuperarBD();
    List usuarios = await db.rawQuery("SELECT * FROM usuarios");
    for (var usu in usuarios) {
      print("Matricula: ${usu['matricula']}, Nome: ${usu['nome']}, Idade: ${usu['idade']}, Curso: ${usu['curso']}");
    }
  }

  _listarUmUsuario(BuildContext context, String matricula) async {
    Database db = await _recuperarBD();
    List usuarios = await db.query(
      "usuarios",
      columns: ["matricula", "nome", "idade", "curso"],
      where: "matricula = ?",
      whereArgs: [matricula],
    );

    if (usuarios.isNotEmpty) {
      var usuario = usuarios.first;
      _mostrarDialogo(context,
          "Matrícula: ${usuario['matricula']} \nNome: ${usuario['nome']} \nIdade: ${usuario['idade']} \nCurso: ${usuario['curso']}");
    } else {
      _mostrarDialogo(context, "Usuário com matrícula $matricula não encontrado.");
    }
  }

  _excluirUsuario(BuildContext context, String matricula) async {
    Database db = await _recuperarBD();
    int retorno = await db.delete(
      "usuarios",
      where: "matricula = ?",
      whereArgs: [matricula],
    );

    _mostrarDialogo(context, "Usuário com matrícula $matricula excluído com sucesso.");
  }

  _atualizarUsuario(BuildContext context, String matricula, String? nome, int? idade, String? curso) async {
    Database db = await _recuperarBD();

    Map<String, dynamic> dadosUsuario = {};
    if (nome != null && nome.isNotEmpty) {
      dadosUsuario["nome"] = nome;
    }
    if (idade != null) {
      dadosUsuario["idade"] = idade;
    }
    if (curso != null && curso.isNotEmpty) {
      dadosUsuario["curso"] = curso;
    }

    if (dadosUsuario.isNotEmpty) {
      int retorno = await db.update(
        "usuarios",
        dadosUsuario,
        where: "matricula = ?",
        whereArgs: [matricula],
      );

      _mostrarDialogo(context, "Usuário com matrícula $matricula atualizado com sucesso.");
    } else {
      _mostrarDialogo(context, "Nenhuma informação para atualizar.");
    }
  }

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _cursoController = TextEditingController();
  final TextEditingController _matriculaFiltroController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              campoTexto(_nomeController, "Digite o nome:"),
              campoTexto(_idadeController, "Digite a idade:", numero: true),
              campoTexto(_matriculaController, "Digite a matrícula:"),
              campoTexto(_cursoController, "Digite o nome do curso:"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _salvarDados(
                    context,
                    _nomeController.text,
                    int.tryParse(_idadeController.text) ?? 0,
                    _matriculaController.text,
                    _cursoController.text,
                  );
                },
                child: const Text("Salvar um usuário"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _listarUsuarios,
                child: const Text("Listar todos usuários"),
              ),
              campoTexto(_matriculaFiltroController, "Digite a matrícula para listar/excluir/atualizar:"),
              ElevatedButton(
                onPressed: () {
                  if (_matriculaFiltroController.text.isNotEmpty) {
                    _listarUmUsuario(context, _matriculaFiltroController.text);
                  } else {
                    _mostrarDialogo(context, "Por favor, insira uma matrícula válida para listar.");
                  }
                },
                child: const Text("Listar um usuário"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_matriculaFiltroController.text.isNotEmpty) {
                    _excluirUsuario(context, _matriculaFiltroController.text);
                  } else {
                    _mostrarDialogo(context, "Por favor, insira uma matrícula válida para excluir.");
                  }
                },
                child: const Text("Excluir usuário"),
              ),
              ElevatedButton(
                onPressed: () {
                  String? nome = _nomeController.text.isNotEmpty ? _nomeController.text : null;
                  int? idade = int.tryParse(_idadeController.text);
                  String? curso = _cursoController.text.isNotEmpty ? _cursoController.text : null;

                  if (_matriculaFiltroController.text.isNotEmpty) {
                    _atualizarUsuario(context, _matriculaFiltroController.text, nome, idade, curso);
                  } else {
                    _mostrarDialogo(context, "Por favor, insira uma matrícula válida para atualizar.");
                  }
                },
                child: const Text("Atualizar usuário"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget campoTexto(TextEditingController controller, String label, {bool numero = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: 300,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: numero ? TextInputType.number : TextInputType.text,
      ),
    );
  }
}

import 'dart:async';
import 'package:fire_stemic/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// O código de criar sua conta no Firebase. Recebe um email e uma senha, se o email existir
// um email de confirmação será enviado
class CriarConta extends StatefulWidget {
  @override
  _CriarContaState createState() => _CriarContaState();
}

class _CriarContaState extends State<CriarConta> {
  // form state para o widget Form, para poder administrar dados/propriedades dos Form fields.
  // como salvar o estado deles, verificar se é valido o input...
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // string de email e senha para eu poder acessar
  String _email, _password;

  // variaveis firebase
  FirebaseUser user;

  // variaveis de cor para o gradient do fundo
  Color gradientStart = Colors.purple[700];
  Color gradientFinal = Colors.purple[400];

  // Métodos

  // método de se cadastrar
  Future<void> signUp() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        user = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        user.sendEmailVerification();
        mostrarAviso();
        //Navigator.pushNamed(context, '/profile');
      } catch (e) {
        print(e.message);
      }
    }
  }

  // método para mostrar que um email de confirmação foi enviado no email cadastrado
  void mostrarAviso() {
    String title, body;
    title = 'Verificação de Email';
    body =
        'Você recebeu uma confirmação no seu e-mail, cheque para se cadastrar';
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title),
              content: Text(body + ' ' + user.email),
              actions: <Widget>[
                FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.pop(context, 'Ok');
                      Navigator.push(
                          context,
                          MaterialPageRoute<Future>(
                              builder: (BuildContext context) => MyApp()));
                    })
              ],
            ));
  }

  // widget build da classe, para saber qual a arvore de elementos principal que
  // a classe irá renderizar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
        ),
        body: Stack(children: <Widget>[
          // coloquei em Stack para os elementos poderem se sobrepor,
          //os elementos de login se sobreporem nesse background

          // É o container que muda a cor do fundo, o gradiente roxo. Apenas decoração
          Container(
              decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientFinal, gradientStart],
              begin: const FractionalOffset(0.0, 1.0),
              end: const FractionalOffset(0.0, 0.4),
            ),
          )),
          // Center element para poder centralizar os elemtos aqui dentro. Width and Height Factor é como uma margem, para nao ficar totalmente centralizado, apenas usei o centro de referencia para ajustar a sua posicao a partir do centro
          Container(alignment: Alignment.center, child: uIElementsTree(context)),
        ]));
  }

// Widget do estilo da UI, o fundo branco com os inputFields, botão de entrar e textos com hyperlinks
  Widget uIElementsTree(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
          width: 325,
          decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.circular(10),
              color: Colors.white70),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // dividi tudo em containers para eu poder personalizar o espaçamento entre os elementos
              Container(
                  // emailInput
                  width: 280,
                  padding: EdgeInsets.only(top: 15),
                  child: emailTextInput(context)),
              Container(
                  // senhaInput
                  width: 280,
                  padding: EdgeInsets.only(top: 15),
                  child: passwordTextInput(context)),
              Container(
                // SignUp Button
                margin: EdgeInsets.only(bottom: 10), // uma margem no final para nao ficar muito pequeno o cartao de fundo
                width: 220, // mexer no tamanho do botao
                padding: EdgeInsets.only(top: 15),
                child: RaisedButton(
                  color: Colors.deepPurple[400],
                  child: Text(
                    ('Cadastrar'),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    signUp();
                  },
                ),
              ),
            ],
          ),
        ));
  }

  // Widget do inputField do email, tudo que gerenciei nele
  Widget emailTextInput(BuildContext context) {
    return TextFormField(
      // Style (estilo do inputField)
      cursorColor: Colors.purple,
      cursorWidth: 2.0,
      decoration: InputDecoration(
          hintText: 'E-mail',
          prefixIcon: Container(
            color: Colors.black12,
            padding: EdgeInsets.only(top: 3),
            margin: EdgeInsets.only(right: 6.5),
            child: Icon(Icons.person),
          ),
          //icon: Icon(Icons.email,),
          filled: true,
          fillColor: Colors.white70),
      // Proprieties
      validator: (String input) {
        // tem que ter o arroba e nao estar vazio para ser um email váilido
        if (input.isEmpty || !input.contains('@')) {
          return 'Digie um email válido';
        }
      },
      onSaved: (String input) => _email = input,
      // o jeito que o teclado do telefone aparece é para digitar o email
      keyboardType: TextInputType.emailAddress,
    );
  }

  // Widget do inputField da senha, tudo que gerenciei nele
  Widget passwordTextInput(BuildContext context) {
    return TextFormField(
      // Style (estilo do inputField)
      obscureText: true,
      cursorColor: Colors.purple,
      decoration: InputDecoration(
          hintText: 'Senha',
          prefixIcon: Container(
            color: Colors.black12,
            padding: EdgeInsets.only(top: 3),
            margin: EdgeInsets.only(right: 6.5),
            child: Icon(Icons.lock),
          ),
          //icon: Icon(Icons.email,),
          filled: true,
          fillColor: Colors.white70),
      // Proprieties
      validator: (String input) {
        // a senha tem que ter pelo menos 6 digitos
        if (input.length < 6) {
          return 'Digite uma senha com 6 ou mais caracteres';
        }
      },
      onSaved: (String input) => _password = input,
    );
  }
}

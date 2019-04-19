import 'dart:async';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Scenes/ProfileHome.dart';
import 'Scenes/signUp.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.purple[600],
        accentColor: Colors.pink[300],
      ),
      home: LoginScreen(),
    );
  }
}

// StateFulWidget são widgets que mudam suas propriedades, não ficam estaticos. Como InputFields que mudam de estado
class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

// São os estados que vão mudar
class _LoginScreenState extends State<LoginScreen> {
  // form state para o widget Form, para poder administrar dados/propriedades dos Form fields.
  // como salvar o estado deles, verificar se é valido o input...
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Strings separadas para eu poder mexer nelas depois
  String _email, _password, _errorMessage;
  // contagem de error
  int error = 4;
  // so vai detectar o erro de autenticação quando ela for true, tenho um arquivo .txt explicando melhor como
  // era para ela funcionar
  bool detectarErro = false;
  // variaveis do Firebase (Google Firebase)
  FirebaseUser user;

  // variaveis do gradient do background do menu
  Color gradientStart = Colors.purple[700];
  Color gradientFinal = Colors.purple[400];

  // Métodos

// método para entrar no link (que é o termos e condiçoes de uso)
  Future<void> launchUrl() async {
    String url = 'http://epistemic.com.br/';
    if (await canLaunch(url)) {
      launch(url);
    } else {
      print("Nao foi possivel se comunicar com o servidor");
    }
  }

// metodo que cuida do firebaseAuth(autenticar o usuario pelo firebase)
  Future<void> signIn() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        Navigator.push(
            context,
            MaterialPageRoute<Future>(
                builder: (BuildContext context) => ProfilePage(
                      user: user,
                    )));
      } catch (e) {
        detectarErro = true;
        print(e.message);
        print(e);
        // Essa variavel serve para detectar quantas vezes o usuario errou de senha, apenas uma int que dimunui seu valor

      }
    }
  }

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
    } catch (e) {
      print(e.message);
    }
  }

// chamar o metodo quando não conseguir logar, por email errado ou senha errada
  void errorCallback() {
    error--;
    print(error);
    detectarErro = !detectarErro;
    // quando faltar 3 tentativas, mostra um alerta sobre o que vai acontecer
    if (error <= 4 && error > 0) {
      _errorMessage = 'Senha Incorreta';
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text('Senha incorreta'),
                content: Text(
                    'seu usuario sera bloqueado se errar 3 vezes a senha. Quantidade de tentativas: ' +
                        error.toString()),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop('Ok');
                    },
                  )
                ],
              ));
    }
    // Se zera as tentativas, o usuario recebe uma notificação no email para redefinição de senha
    if (error <= 0) {
      error = 0;
      _errorMessage = 'Redefina sua senha';
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text('App bloqueado'),
                content: Text(
                    'Senha errada 3 vezes, redefina sua senha ou feche o app e tente novamente.'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop('Ok');
                    },
                  ),
                  FlatButton(
                    child: Text('Redefinir sua senha'),
                    onPressed: () {
                      Navigator.of(context).pop('Ok');
                      FirebaseAuth.instance
                          .sendPasswordResetEmail(email: _email);
                      //TODO: show info on skacnBar (email send)
                      _showSnackBarConfirmation();
                    },
                  ),
                ],
              ));
      user.updatePassword('password');
    }

    //detectarErro = false;
  }

// metodo que mostra uma notificação em baixo da tela dizendo que foi mandado um email para redefinir senha
  void _showSnackBarConfirmation() {
    final snackBar = SnackBar(
      content: Text(
        'Um e-mail foi enviado no endereço ' +
            _email +
            ' para redefinição de senha',
        style: TextStyle(fontSize: 16),
      ),
      duration: Duration(seconds: 4),
    );

    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

// Dividi tudo em Widgets para ficar mais organizado e ficar mais facil de encontar as partes da UI
  @override
  Widget build(BuildContext context) {
      try{(FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password));}
          catch(e){
            
          }
    // o método principal para o flutter saber o que renderizar
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(children: <Widget>[
          // coloquei em Stack para os elementos poderem se sobrepor, os elementos de login se sobreporem nesse background
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
          Container(
              margin: EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              child: uIElementsTree(context)),
        ]));
  }

  //Widget do estilo da UI, o fundo branco com os inputFields, botão de entrar e textos com hyperlinks
  Widget uIElementsTree(BuildContext context) {
    // armazena toda a Ui, o fundo branco, os textos e os InputFields
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
              // d
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
                  // Login Button
                  width: 220, // tamanho do botao
                  padding: EdgeInsets.only(top: 15),
                  child: RaisedButton(
                      color: Colors.deepPurple[400],
                      child: Text(
                        ('Entrar'),
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () {
                        signIn(); // se nao puder detectar erro, faz login. Mas só funciona errando
                        // apenar uma vez a senha
                        if (detectarErro) {
                          // indicar que o usuário errou a senha 1*
                          // 1* tem um erro nessa parte, de que depois que errou a senha duas vezes
                          // a parte do FirebaseAuth não funciona mais, mesmo no final eu mudando
                          // a variavel detectar erro para false
                          errorCallback();
                        }

                        detectarErro = !detectarErro;
                      })),
              Container(
                // link Esqueceu sua senha
                padding: EdgeInsets.only(top: 5, bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    //resetPassword();
                    FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
                    _showSnackBarConfirmation(); // mostrar alerta que o usuario recebeu um email para resetar a senha
                  },
                  child: Text(
                    'Esqueceu sua senha? Clique Aqui para trocar a senha pelo email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red),
                  ),
                ),
              ),
              Container(
                // divisoria rosa, divide o resto do cadastre-se
                color: Colors.pink[300],
                height: 10,
              ),
              Container(
                // Link Cadastre-se
                padding: EdgeInsets.only(top: 5),
                child: GestureDetector(
                    onTap: () {
                      //Navigator.pushNamed(context, '/singUp');
                      Navigator.push(
                          context,
                          MaterialPageRoute<Future>(
                              builder: (BuildContext context) => CriarConta(),
                              fullscreenDialog: true));
                    },
                    child: Text(
                      'Cadastre-se',
                      style: TextStyle(
                          fontSize: 20,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.red),
                    )),
              ),
              FlatButton(
                padding: EdgeInsets.all(4),
                child: Text(
                  'Termos e condições de Uso',
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () {
                  launchUrl();
                  // _showSnackBarConfirmation();
                },
              )
            ],
          ),
        ));
  }

  // Widget do inputField do email, tudo que gerenciei nele
  Widget emailTextInput(BuildContext context) {
    // elementos e propriedades do InputField do e-mail
    return TextFormField(
      // Style
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
        if (input.isEmpty) {
          detectarErro = false;
          return 'Campo obrigatório*';
        }
        if (!input.contains('@')) {
          detectarErro = false;

          return 'Digite um email válido.';
        }
        //  if (input.contains('@')) {
        //   //detectarErro = true;
        //   return '...';
        // }
      },
      onSaved: (String input) => _email = input,
      // o jeito que o teclado do telefone aparece é para digitar o email
      keyboardType: TextInputType.emailAddress,
    );
  }

  // Widget do inputField da senha, tudo que gerenciei nele
  Widget passwordTextInput(BuildContext context) {
    // elementos e propriedades do InputField do e-mail
    String displayMessage; // mensagem que vai mostrar se deu erro
    return TextFormField(
      // Style
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
        if (input.isNotEmpty) {
          displayMessage = _errorMessage;
          return displayMessage;
        } else if (input.isEmpty) {
          detectarErro = false;
          return 'Campo obrigatório*';
        }
        // else if(input.length < 6){
        //   detectarErro = false;
        //   return 'A senha deve ter no mínimo 6 caracteres.';
        // }
      },
      onSaved: (String input) => _password = input,
    );
  }
}

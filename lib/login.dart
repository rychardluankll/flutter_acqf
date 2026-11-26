import 'package:flutter/material.dart';
import 'main.dart';

class User {
  String email;
  String password;

  User({
    required this.email,
    required this.password,
  });
}

List<User> registeredUsers = [];
List<User> activeSession = [];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;
  bool isRegisterMode = false;
  String errorMessage = '';
  String successMessage = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void register() {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Preencha o e-mail e a senha';
        successMessage = '';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        errorMessage = 'Digite um e-mail válido';
        successMessage = '';
      });
      return;
    }

    for (int i = 0; i < registeredUsers.length; i++) {
      if (registeredUsers[i].email == email) {
        setState(() {
          errorMessage = 'Este e-mail já está cadastrado';
          successMessage = '';
        });
        return;
      }
    }

    registeredUsers.add(
      User(email: email, password: password),
    );

    emailController.clear();
    passwordController.clear();

    setState(() {
      isRegisterMode = false;
      errorMessage = '';
      successMessage = 'Cadastro realizado! Agora faça login.';
    });
  }

  void login() {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Preencha o e-mail e a senha';
        successMessage = '';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        errorMessage = 'Digite um e-mail válido';
        successMessage = '';
      });
      return;
    }

    if (registeredUsers.isEmpty) {
      setState(() {
        errorMessage = 'Nenhum usuário cadastrado. Faça o cadastro primeiro.';
        successMessage = '';
      });
      return;
    }

    User? foundUser;
    for (int i = 0; i < registeredUsers.length; i++) {
      if (registeredUsers[i].email == email &&
          registeredUsers[i].password == password) {
        foundUser = registeredUsers[i];
        break;
      }
    }

    if (foundUser == null) {
      setState(() {
        errorMessage = 'E-mail ou senha incorretos';
        successMessage = '';
      });
      return;
    }

    activeSession.clear();
    activeSession.add(foundUser);

    setState(() {
      errorMessage = '';
      successMessage = '';
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const Home();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 70,
                color: Colors.blue[900],
              ),
              const SizedBox(height: 16),
              Text(
                'Gerenciador de Tarefas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isRegisterMode
                    ? 'Cadastre seus dados para começar'
                    : 'Faça login para continuar',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                ),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (successMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    successMessage,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isRegisterMode ? register : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    isRegisterMode ? 'Cadastrar' : 'Entrar',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    isRegisterMode = !isRegisterMode;
                    errorMessage = '';
                    successMessage = '';
                  });
                },
                child: Text(
                  isRegisterMode
                      ? 'Já tenho conta? Entrar'
                      : 'Não tem conta? Cadastrar',
                  style: TextStyle(color: Colors.blue[900]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

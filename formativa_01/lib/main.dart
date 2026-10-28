import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/mapa_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? erroFirebase;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (erro) {
    erroFirebase = erro;
  }

  runApp(MinhaAplicacao(erroFirebase: erroFirebase));
}

class MinhaAplicacao extends StatelessWidget {
  const MinhaAplicacao({super.key, this.erroFirebase});

  /// Preenchido quando o Firebase não pôde ser inicializado.
  final Object? erroFirebase;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mapa de Locais',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
        ),
      ),
      home: erroFirebase == null
          ? const MapaScreen()
          : _ErroFirebase(erro: erroFirebase!),
    );
  }
}

/// Exibida no lugar do mapa quando o app não consegue se conectar ao Firebase.
class _ErroFirebase extends StatelessWidget {
  const _ErroFirebase({required this.erro});

  final Object erro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'Não foi possível conectar ao Firebase.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('$erro', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

void mostrarSucesso(BuildContext context, String mensagem) {
  _mostrar(ScaffoldMessenger.of(context), mensagem, Colors.green.shade700);
}

void mostrarErro(BuildContext context, String mensagem) {
  _mostrar(ScaffoldMessenger.of(context), mensagem, Colors.red.shade700);
}

/// Executa uma operação nos dados e mostra mensagem de sucesso ou de erro.
///
/// O [ScaffoldMessenger] é obtido antes do `await` para que a mensagem
/// apareça mesmo se a tela que iniciou a operação já tiver sido fechada.
Future<bool> executarOperacao(
  BuildContext context, {
  required Future<void> Function() operacao,
  required String sucesso,
  required String erro,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await operacao();
    _mostrar(messenger, sucesso, Colors.green.shade700);
    return true;
  } catch (e) {
    _mostrar(messenger, '$erro\n$e', Colors.red.shade700);
    return false;
  }
}

void _mostrar(ScaffoldMessengerState messenger, String mensagem, Color cor) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

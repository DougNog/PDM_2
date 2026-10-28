import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/local.dart';
import 'dados_exemplo.dart';

/// Única classe que conversa com o Cloud Firestore. As telas nunca acessam o
/// banco diretamente: só chamam os métodos abaixo.
///
/// Os locais ficam na coleção `locais`. Cada documento tem os campos de
/// [Local.toMap] e o ID gerado automaticamente pelo Firestore.
class LocalService {
  /// Usa o Firestore do projeto configurado pelo FlutterFire.
  LocalService() : this.comBanco(bancoPadrao ?? FirebaseFirestore.instance);

  /// Usa o banco informado. Nos testes, um Firestore falso em memória.
  LocalService.comBanco(FirebaseFirestore banco)
      : _locais = banco.collection(colecao);

  static const String colecao = 'locais';

  /// Permite que os testes das telas troquem o banco usado por `LocalService()`.
  @visibleForTesting
  static FirebaseFirestore? bancoPadrao;

  final CollectionReference<Map<String, dynamic>> _locais;

  /// READ — `snapshots()` emite a lista atual e uma nova lista a cada
  /// alteração no banco, feita por este ou por outro aparelho.
  Stream<List<Local>> listarLocais() {
    return _locais.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Local.fromMap(doc.id, doc.data()))
          .toList()
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    });
  }

  /// READ — acompanha um único documento. Emite `null` se ele for excluído.
  Stream<Local?> observarLocal(String id) {
    return _locais.doc(id).snapshots().map((doc) {
      final dados = doc.data();
      return dados == null ? null : Local.fromMap(doc.id, dados);
    });
  }

  /// CREATE — `add()` cria o documento com ID automático. Retorna esse ID.
  Future<String> adicionar(Local local) async {
    final documento = await _locais.add(local.toMap());
    return documento.id;
  }

  /// UPDATE — substitui os campos do documento `local.id`. Falha se o
  /// documento não existir mais.
  Future<void> atualizar(Local local) async {
    await _locais.doc(local.id).update(local.toMap());
  }

  /// DELETE
  Future<void> excluir(String id) async {
    await _locais.doc(id).delete();
  }

  /// UPDATE parcial — altera somente o campo `favorito`.
  Future<void> alterarFavorito(String id, bool favorito) async {
    await _locais.doc(id).update({'favorito': favorito});
  }

  /// Cadastra os locais de exemplo de uma só vez. O lote (`batch`) grava
  /// todos os documentos ou nenhum.
  Future<void> cadastrarExemplos() async {
    final lote = _locais.firestore.batch();
    for (final local in locaisExemplo) {
      lote.set(_locais.doc(), local.toMap());
    }
    await lote.commit();
  }
}

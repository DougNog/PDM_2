import 'package:flutter/material.dart';

import '../models/local.dart';
import '../utils/constantes.dart';
import '../utils/validadores.dart';

/// Abre o formulário em um Bottom Sheet.
///
/// Sem [local], funciona como cadastro; com [local], como edição.
/// Retorna o local preenchido ou `null` se o usuário cancelar.
Future<Local?> mostrarFormularioLocal(
  BuildContext context, {
  Local? local,
  String? cidadePadrao,
}) {
  return showModalBottomSheet<Local>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: LocalForm(
        local: local,
        cidadePadrao: cidadePadrao,
        onSalvar: (resultado) => Navigator.pop(context, resultado),
      ),
    ),
  );
}

class LocalForm extends StatefulWidget {
  const LocalForm({
    super.key,
    this.local,
    this.cidadePadrao,
    required this.onSalvar,
  });

  final Local? local;
  final String? cidadePadrao;
  final ValueChanged<Local> onSalvar;

  @override
  State<LocalForm> createState() => _LocalFormState();
}

class _LocalFormState extends State<LocalForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nome;
  late final TextEditingController _avaliacao;
  late final TextEditingController _distancia;
  late final TextEditingController _horario;
  late final TextEditingController _descricao;
  late String _categoria;
  late String _cidade;

  bool get _editando => widget.local != null;

  @override
  void initState() {
    super.initState();
    final local = widget.local;
    _nome = TextEditingController(text: local?.nome ?? '');
    _avaliacao = TextEditingController(text: local?.avaliacao.toString() ?? '');
    _distancia = TextEditingController(text: local?.distancia.toString() ?? '');
    _horario = TextEditingController(text: local?.horario ?? '');
    _descricao = TextEditingController(text: local?.descricao ?? '');

    // Documentos criados manualmente podem ter valores fora da lista.
    _categoria = categorias.contains(local?.categoria)
        ? local!.categoria
        : categorias.first;
    final cidadeInicial = local?.cidade ?? widget.cidadePadrao;
    _cidade = cidades.contains(cidadeInicial) ? cidadeInicial! : cidades.first;
  }

  @override
  void dispose() {
    _nome.dispose();
    _avaliacao.dispose();
    _distancia.dispose();
    _horario.dispose();
    _descricao.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final dados = Local(
      id: widget.local?.id ?? '',
      nome: _nome.text.trim(),
      categoria: _categoria,
      cidade: _cidade,
      avaliacao: Validadores.lerDecimal(_avaliacao.text) ?? 0,
      distancia: Validadores.lerDecimal(_distancia.text) ?? 0,
      horario: _horario.text.trim(),
      descricao: _descricao.text.trim(),
      favorito: widget.local?.favorito ?? false,
    );
    widget.onSalvar(dados);
  }

  @override
  Widget build(BuildContext context) {
    const espaco = SizedBox(height: 12);
    const teclado = TextInputType.numberWithOptions(decimal: true);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _editando ? 'Editar local' : 'Novo local',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('campo_nome'),
              controller: _nome,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: Validadores.obrigatorio,
            ),
            espaco,
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _categoria,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final c in categorias)
                        DropdownMenuItem(value: c, child: Text(c)),
                    ],
                    onChanged: (valor) => setState(() => _categoria = valor!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _cidade,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Cidade',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final c in cidades)
                        DropdownMenuItem(value: c, child: Text(c)),
                    ],
                    onChanged: (valor) => setState(() => _cidade = valor!),
                  ),
                ),
              ],
            ),
            espaco,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('campo_avaliacao'),
                    controller: _avaliacao,
                    keyboardType: teclado,
                    decoration: const InputDecoration(
                      labelText: 'Avaliação (0 a 5)',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validadores.avaliacao,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: const Key('campo_distancia'),
                    controller: _distancia,
                    keyboardType: teclado,
                    decoration: const InputDecoration(
                      labelText: 'Distância (km)',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validadores.distancia,
                  ),
                ),
              ],
            ),
            espaco,
            TextFormField(
              key: const Key('campo_horario'),
              controller: _horario,
              decoration: const InputDecoration(
                labelText: 'Horário',
                hintText: '06:00 - 22:00 ou 24h',
                border: OutlineInputBorder(),
              ),
              validator: Validadores.horario,
            ),
            espaco,
            TextFormField(
              key: const Key('campo_descricao'),
              controller: _descricao,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              validator: Validadores.obrigatorio,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('botao_salvar'),
              onPressed: _salvar,
              icon: const Icon(Icons.save_outlined),
              label: Text(_editando ? 'Salvar alterações' : 'Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../dialogs/confirm_delete.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import '../utils/filtros.dart';
import '../utils/mensagens.dart';
import '../widgets/barra_navegacao.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import '../widgets/seletor_cidade.dart';
import 'detalhes_screen.dart';

/// Tela 2 — Resultados: lista de locais com pesquisa, filtros e CRUD.
class ResultadosScreen extends StatefulWidget {
  const ResultadosScreen({
    super.key,
    required this.cidade,
    this.pesquisa = '',
    this.somenteFavoritos = false,
  });

  final String cidade;
  final String pesquisa;
  final bool somenteFavoritos;

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final LocalService _service = LocalService();
  late final Stream<List<Local>> _locais = _service.listarLocais();
  late final TextEditingController _pesquisa =
      TextEditingController(text: widget.pesquisa);

  late String _cidade = widget.cidade;
  late bool _somenteFavoritos = widget.somenteFavoritos;
  String _categoria = todasCategorias;

  @override
  void dispose() {
    _pesquisa.dispose();
    super.dispose();
  }

  Future<void> _escolherCidade() async {
    final cidade = await selecionarCidade(
      context,
      atual: _cidade,
      incluirTodas: true,
    );
    if (cidade != null) setState(() => _cidade = cidade);
  }

  void _abrirDetalhes(Local local) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(local: local)),
    );
  }

  Future<void> _cadastrar() async {
    final novo = await mostrarFormularioLocal(
      context,
      cidadePadrao: _cidade == todasCidades ? null : _cidade,
    );
    if (novo == null || !mounted) return;
    await executarOperacao(
      context,
      operacao: () => _service.adicionar(novo),
      sucesso: '"${novo.nome}" cadastrado com sucesso.',
      erro: 'Erro ao cadastrar o local.',
    );
  }

  Future<void> _editar(Local local) async {
    final editado = await mostrarFormularioLocal(context, local: local);
    if (editado == null || !mounted) return;
    await executarOperacao(
      context,
      operacao: () => _service.atualizar(editado),
      sucesso: '"${editado.nome}" atualizado com sucesso.',
      erro: 'Erro ao atualizar o local.',
    );
  }

  Future<void> _excluir(Local local) async {
    final confirmou = await confirmarExclusao(context, local.nome);
    if (!confirmou || !mounted) return;
    await executarOperacao(
      context,
      operacao: () => _service.excluir(local.id),
      sucesso: '"${local.nome}" excluído.',
      erro: 'Erro ao excluir o local.',
    );
  }

  Future<void> _cadastrarExemplos() async {
    await executarOperacao(
      context,
      operacao: _service.cadastrarExemplos,
      sucesso: 'Locais de exemplo cadastrados.',
      erro: 'Erro ao cadastrar os locais de exemplo.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _somenteFavoritos ? 'Favoritos' : 'Resultados',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _filtros(),
          Expanded(child: _lista()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('botao_novo_local'),
        onPressed: _cadastrar,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Novo local'),
      ),
      bottomNavigationBar: BarraNavegacao(
        atual: _somenteFavoritos ? AbaNavegacao.favoritos : AbaNavegacao.mapa,
      ),
    );
  }

  Widget _filtros() {
    final bordaCampo = OutlineInputBorder(borderRadius: BorderRadius.circular(12));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          TextField(
            key: const Key('campo_pesquisa_resultados'),
            controller: _pesquisa,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Pesquisar por nome ou categoria',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _pesquisa.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(_pesquisa.clear),
                    ),
              isDense: true,
              border: bordaCampo,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            key: const Key('filtro_cidade'),
            onTap: _escolherCidade,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: const Icon(Icons.chevron_right),
                isDense: true,
                border: bordaCampo,
              ),
              child: Text(
                _cidade == todasCidades ? 'Todas as cidades' : _cidade,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chipCategoria(todasCategorias, 'Todos'),
                for (final categoria in categorias)
                  _chipCategoria(categoria, rotuloCategoria(categoria)),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: const Icon(Icons.favorite, size: 16),
                    label: const Text('Favoritos'),
                    selected: _somenteFavoritos,
                    onSelected: (valor) =>
                        setState(() => _somenteFavoritos = valor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipCategoria(String valor, String rotulo) {
    final selecionado = _categoria == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(rotulo),
        selected: selecionado,
        showCheckmark: false,
        selectedColor: Colors.grey.shade900,
        labelStyle: TextStyle(color: selecionado ? Colors.white : null),
        onSelected: (_) => setState(() => _categoria = valor),
      ),
    );
  }

  Widget _lista() {
    return StreamBuilder<List<Local>>(
      stream: _locais,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _mensagem(
            icone: Icons.error_outline,
            titulo: 'Erro ao carregar os locais.',
            detalhe: '${snapshot.error}',
          );
        }

        final todos = snapshot.data ?? [];
        if (todos.isEmpty) {
          return _mensagem(
            icone: Icons.inventory_2_outlined,
            titulo: 'Nenhum local cadastrado.',
            detalhe: 'Cadastre um novo local ou carregue os dados de exemplo.',
            acao: OutlinedButton.icon(
              key: const Key('botao_exemplos'),
              onPressed: _cadastrarExemplos,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Cadastrar dados de exemplo'),
            ),
          );
        }

        final locais = filtrarLocais(
          todos,
          texto: _pesquisa.text,
          cidade: _cidade,
          categoria: _categoria,
          somenteFavoritos: _somenteFavoritos,
        );
        if (locais.isEmpty) {
          return _mensagem(
            icone: Icons.search_off,
            titulo: 'Nenhum local encontrado.',
            detalhe: 'Tente mudar a pesquisa, a cidade ou os filtros.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: locais.length,
          itemBuilder: (context, index) {
            final local = locais[index];
            return LocalCard(
              key: ValueKey(local.id),
              local: local,
              onTap: () => _abrirDetalhes(local),
              onEditar: () => _editar(local),
              onExcluir: () => _excluir(local),
            );
          },
        );
      },
    );
  }

  Widget _mensagem({
    required IconData icone,
    required String titulo,
    required String detalhe,
    Widget? acao,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(detalhe, textAlign: TextAlign.center),
            if (acao != null) ...[const SizedBox(height: 16), acao],
          ],
        ),
      ),
    );
  }
}

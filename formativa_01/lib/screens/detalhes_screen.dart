import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import '../utils/horario.dart';
import '../utils/mapa_destaque.dart';
import '../utils/mensagens.dart';
import '../widgets/barra_navegacao.dart';
import '../widgets/imagem_placeholder.dart';

/// Tela 3 — Detalhes de um local.
///
/// Recebe o local selecionado e acompanha o registro no serviço, para que
/// a mudança de favorito (ou uma exclusão) apareça na hora.
class DetalhesScreen extends StatefulWidget {
  const DetalhesScreen({super.key, required this.local});

  final Local local;

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  static const _quantidadeFotos = 5;

  final LocalService _service = LocalService();
  late final Stream<Local?> _local = _service.observarLocal(widget.local.id);
  int _fotoAtual = 0;
  bool _salvandoFavorito = false;

  Future<void> _alternarFavorito(Local local) async {
    setState(() => _salvandoFavorito = true);
    final novoValor = !local.favorito;
    await executarOperacao(
      context,
      operacao: () => _service.alterarFavorito(local.id, novoValor),
      sucesso: novoValor
          ? 'Adicionado aos favoritos.'
          : 'Removido dos favoritos.',
      erro: 'Erro ao atualizar o favorito.',
    );
    if (mounted) setState(() => _salvandoFavorito = false);
  }

  Future<void> _compartilhar(Local local) async {
    await Clipboard.setData(
      ClipboardData(
        text: '${local.nome} — ${local.categoria} em ${local.cidade}. '
            'Horário: ${local.horario}.',
      ),
    );
    if (mounted) mostrarSucesso(context, 'Informações copiadas.');
  }

  void _verNoMapa(Local local) {
    // Volta para a tela inicial e pede para ela destacar o local.
    localDestacado.value = null;
    localDestacado.value = local;
    Navigator.of(context).popUntil((rota) => rota.isFirst);
  }

  void _acaoDemonstrativa(String acao) {
    mostrarSucesso(context, '$acao: funcionalidade demonstrativa.');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Local?>(
      stream: _local,
      initialData: widget.local,
      builder: (context, snapshot) {
        final local = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            actions: [
              if (local != null) ...[
                IconButton(
                  key: const Key('botao_favorito'),
                  tooltip: local.favorito ? 'Remover dos favoritos' : 'Favoritar',
                  onPressed:
                      _salvandoFavorito ? null : () => _alternarFavorito(local),
                  icon: Icon(
                    local.favorito ? Icons.favorite : Icons.favorite_border,
                    color: local.favorito ? Colors.red : null,
                  ),
                ),
                IconButton(
                  tooltip: 'Compartilhar',
                  onPressed: () => _compartilhar(local),
                  icon: const Icon(Icons.share_outlined),
                ),
              ],
            ],
          ),
          body: _corpo(snapshot),
          bottomNavigationBar: const BarraNavegacao(atual: AbaNavegacao.mapa),
        );
      },
    );
  }

  Widget _corpo(AsyncSnapshot<Local?> snapshot) {
    if (snapshot.hasError) {
      return Center(
        child: Text('Erro ao carregar o local.\n${snapshot.error}',
            textAlign: TextAlign.center),
      );
    }
    final local = snapshot.data;
    if (local == null) {
      return const Center(
        child: Text('Este local foi excluído.'),
      );
    }

    final textoSecundario = TextStyle(color: Colors.grey.shade700);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        _galeria(local),
        const SizedBox(height: 16),
        Text(
          local.nome,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text('${local.categoria} · ${local.cidade}', style: textoSecundario),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.star, size: 18, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              local.avaliacao.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 20,
          runSpacing: 8,
          children: [
            _info(Icons.place_outlined, '${local.distancia.toStringAsFixed(1)} km'),
            _info(
              Icons.schedule,
              descricaoHorario(local.horario, DateTime.now()),
            ),
          ],
        ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _acaoRapida(Icons.phone_outlined, 'Ligar'),
            _acaoRapida(Icons.near_me_outlined, 'Como chegar'),
            _acaoRapida(Icons.event_outlined, 'Agendar'),
          ],
        ),
        const Divider(height: 32),
        const Text('Sobre', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(local.descricao.isEmpty ? 'Sem descrição.' : local.descricao),
        const Divider(height: 32),
        Row(
          children: [
            const Expanded(
              child: Text('Fotos', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Text('Ver todas', style: textoSecundario),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.5,
                  child: ImagemPlaceholder(icone: iconeCategoria(local.categoria)),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('botao_ver_no_mapa'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.grey.shade900,
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () => _verNoMapa(local),
          icon: const Icon(Icons.location_on),
          label: const Text('Ver no mapa'),
        ),
      ],
    );
  }

  Widget _galeria(Local local) {
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: Stack(
            children: [
              PageView.builder(
                itemCount: _quantidadeFotos,
                onPageChanged: (pagina) => setState(() => _fotoAtual = pagina),
                itemBuilder: (context, _) => ImagemPlaceholder(
                  raio: 12,
                  icone: iconeCategoria(local.categoria),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_fotoAtual + 1}/$_quantidadeFotos',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _quantidadeFotos; i++)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _fotoAtual ? Colors.grey.shade800 : Colors.grey.shade400,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _info(IconData icone, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 18),
        const SizedBox(width: 4),
        Text(texto),
      ],
    );
  }

  Widget _acaoRapida(IconData icone, String rotulo) {
    return InkWell(
      onTap: () => _acaoDemonstrativa(rotulo),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Icon(icone, size: 20),
            ),
            const SizedBox(height: 6),
            Text(rotulo, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

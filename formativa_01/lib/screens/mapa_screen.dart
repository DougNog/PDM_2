import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/mapa_destaque.dart';
import '../widgets/barra_navegacao.dart';
import '../widgets/mapa_ilustrado.dart';
import '../widgets/seletor_cidade.dart';
import 'detalhes_screen.dart';
import 'resultados_screen.dart';

/// Tela 1 — Mapa principal: cidade, pesquisa e marcadores dos locais.
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final LocalService _service = LocalService();
  final TextEditingController _pesquisa = TextEditingController();
  final TransformationController _transformacao = TransformationController();
  late final Stream<List<Local>> _locais = _service.listarLocais();

  String _cidade = 'São Paulo';
  String? _selecionadoId;
  bool _satelite = false;

  @override
  void initState() {
    super.initState();
    localDestacado.addListener(_aoDestacar);
  }

  @override
  void dispose() {
    localDestacado.removeListener(_aoDestacar);
    _pesquisa.dispose();
    _transformacao.dispose();
    super.dispose();
  }

  /// Chamado quando o usuário toca em "Ver no mapa" na tela de detalhes.
  void _aoDestacar() {
    final local = localDestacado.value;
    if (local == null) return;
    setState(() {
      _cidade = local.cidade;
      _selecionadoId = local.id;
      _transformacao.value = Matrix4.identity();
    });
  }

  Future<void> _escolherCidade() async {
    final cidade = await selecionarCidade(context, atual: _cidade);
    if (cidade == null || cidade == _cidade) return;
    setState(() {
      _cidade = cidade;
      _selecionadoId = null;
      _transformacao.value = Matrix4.identity();
    });
  }

  void _abrirResultados() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultadosScreen(
          cidade: _cidade,
          pesquisa: _pesquisa.text,
        ),
      ),
    );
  }

  void _abrirDetalhes(Local local) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(local: local)),
    );
  }

  void _centralizar() {
    setState(() {
      _transformacao.value = Matrix4.identity();
      _selecionadoId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _cabecalho(),
            Expanded(child: _mapa()),
          ],
        ),
      ),
      bottomNavigationBar: const BarraNavegacao(atual: AbaNavegacao.mapa),
    );
  }

  Widget _cabecalho() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: const Key('seletor_cidade'),
            onTap: _escolherCidade,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, size: 28),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cidade selecionada',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      Row(
                        children: [
                          Text(
                            _cidade,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('campo_pesquisa_mapa'),
            controller: _pesquisa,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _abrirResultados(),
            decoration: InputDecoration(
              hintText: 'Buscar locais, endereços ou categorias...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Ver resultados',
                icon: const Icon(Icons.arrow_forward),
                onPressed: _abrirResultados,
              ),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapa() {
    return StreamBuilder<List<Local>>(
      stream: _locais,
      builder: (context, snapshot) {
        final locaisDaCidade = (snapshot.data ?? [])
            .where((local) => local.cidade == _cidade)
            .toList();

        return Stack(
          children: [
            Positioned.fill(
              child: MapaIlustrado(
                cidade: _cidade,
                locais: locaisDaCidade,
                controlador: _transformacao,
                selecionadoId: _selecionadoId,
                satelite: _satelite,
                onSelecionar: (id) => setState(() => _selecionadoId = id),
                onAbrir: _abrirDetalhes,
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 72,
              child: _statusMapa(snapshot, locaisDaCidade.length),
            ),
            Positioned(
              right: 12,
              bottom: 76,
              child: Column(
                children: [
                  _botaoRedondo(
                    icone: Icons.my_location,
                    dica: 'Minha localização',
                    onPressed: _centralizar,
                  ),
                  const SizedBox(height: 12),
                  _botaoRedondo(
                    icone: Icons.layers_outlined,
                    dica: 'Alternar camada',
                    onPressed: () => setState(() => _satelite = !_satelite),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: FilledButton.icon(
                key: const Key('botao_ver_resultados'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.grey.shade900,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _abrirResultados,
                icon: const Icon(Icons.list),
                label: Text('Ver resultados em $_cidade'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statusMapa(AsyncSnapshot<List<Local>> snapshot, int quantidade) {
    final String texto;
    final IconData icone;
    if (snapshot.hasError) {
      texto = 'Erro ao carregar os locais.';
      icone = Icons.error_outline;
    } else if (snapshot.connectionState == ConnectionState.waiting) {
      texto = 'Carregando locais...';
      icone = Icons.sync;
    } else if (quantidade == 0) {
      texto = 'Nenhum local cadastrado em $_cidade.';
      icone = Icons.info_outline;
    } else {
      texto = '$quantidade ${quantidade == 1 ? 'local' : 'locais'} em $_cidade';
      icone = Icons.place;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: snapshot.hasError ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 16),
            const SizedBox(width: 6),
            Flexible(child: Text(texto, style: const TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _botaoRedondo({
    required IconData icone,
    required String dica,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: IconButton(
        tooltip: dica,
        icon: Icon(icone),
        onPressed: onPressed,
      ),
    );
  }
}

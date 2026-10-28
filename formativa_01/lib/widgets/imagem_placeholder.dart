import 'package:flutter/material.dart';

/// Caixa cinza com ícone de imagem, como no wireframe.
class ImagemPlaceholder extends StatelessWidget {
  const ImagemPlaceholder({
    super.key,
    this.largura,
    this.altura,
    this.icone = Icons.image_outlined,
    this.raio = 8,
  });

  final double? largura;
  final double? altura;
  final IconData icone;
  final double raio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: largura,
      height: altura,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(raio),
      ),
      child: LayoutBuilder(
        builder: (context, restricoes) {
          final tamanho = restricoes.biggest.shortestSide * 0.45;
          return Center(
            child: Icon(icone, size: tamanho, color: Colors.grey.shade500),
          );
        },
      ),
    );
  }
}

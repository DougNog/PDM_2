import 'package:flutter/material.dart';

const List<String> cidades = ['São Paulo', 'Campinas', 'Jundiaí', 'Santos'];

const List<String> categorias = [
  'Academia',
  'Restaurante',
  'Hospital',
  'Farmácia',
  'Mercado',
];

/// Valores especiais usados nos filtros para "sem filtro".
const String todasCidades = 'Todas';
const String todasCategorias = 'Todos';

String rotuloCategoria(String categoria) {
  const plurais = {
    'Academia': 'Academias',
    'Restaurante': 'Restaurantes',
    'Hospital': 'Hospitais',
    'Farmácia': 'Farmácias',
    'Mercado': 'Mercados',
  };
  return plurais[categoria] ?? categoria;
}

IconData iconeCategoria(String categoria) {
  switch (categoria) {
    case 'Academia':
      return Icons.fitness_center;
    case 'Restaurante':
      return Icons.restaurant;
    case 'Hospital':
      return Icons.local_hospital;
    case 'Farmácia':
      return Icons.local_pharmacy;
    case 'Mercado':
      return Icons.shopping_cart;
    default:
      return Icons.place;
  }
}

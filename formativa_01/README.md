# Mapa de Locais — Flutter + Cloud Firestore

Aplicativo Android para localizar estabelecimentos por cidade: mapa, pesquisa,
resultados filtrados e detalhes de cada local, com cadastro, edição, exclusão e
favoritos. Os locais ficam na coleção `locais` do **Cloud Firestore**.

A documentação completa está em [docs/DOCUMENTACAO.md](docs/DOCUMENTACAO.md).

## Projeto Firebase

O app já está ligado ao projeto **`mapa-locais-flutter-e9b73`**:

- `lib/firebase_options.dart` e `android/app/google-services.json` foram gerados
  pelo `flutterfire configure` (plataforma Android).
- Banco Cloud Firestore criado em `southamerica-east1` (São Paulo), modo de
  produção, com a coleção `locais` e os 21 locais de exemplo.
- As regras de [firestore.rules](firestore.rules) estão publicadas.

## Como executar

Pré-requisitos: Flutter SDK e um emulador Android (ou celular com depuração USB).

```bash
flutter pub get
flutter run
```

Se a coleção estiver vazia, abra **Ver resultados** e toque em **Cadastrar dados
de exemplo** para gravar os 21 locais de novo.

### Publicar alterações nas regras

Depois de editar `firestore.rules` (requer `firebase login` com a conta dona do
projeto):

```bash
firebase deploy --only firestore:rules
```

### Ligar a outro projeto Firebase

1. Crie o projeto e o banco Firestore no [Firebase Console](https://console.firebase.google.com/)
   com uma conta Google pessoal (a conta institucional bloqueia a criação de projetos).
2. Rode `firebase login` e depois
   `flutterfire configure --project=<id-do-projeto> --platforms=android`.
3. Troque o projeto em `.firebaserc` e publique as regras com o comando acima.

Se o app não conseguir inicializar o Firebase, ele abre uma tela "Não foi
possível conectar ao Firebase" em vez do mapa.

## Testes automatizados

```bash
flutter test
```

São 44 testes. Eles usam um Firestore falso em memória
([fake_cloud_firestore](https://pub.dev/packages/fake_cloud_firestore)), então
rodam sem internet e sem projeto Firebase. Cobrem o model `Local`, o serviço
(ler, cadastrar, editar, excluir, favoritar e erros), as telas lendo e gravando
no banco, pesquisa e filtros, validações do formulário, cálculo de
"Aberto/Fechado", o card da lista, o formulário e o diálogo de exclusão.

## Estrutura

```
lib/
├── main.dart                   inicializa o Firebase e abre o mapa
├── firebase_options.dart       gerado pelo `flutterfire configure`
├── models/local.dart           model Local (fromMap / toMap)
├── services/
│   ├── local_service.dart      única classe que acessa o Firestore (CRUD)
│   └── dados_exemplo.dart      21 locais de exemplo
├── screens/
│   ├── mapa_screen.dart        Tela 1 — mapa principal
│   ├── resultados_screen.dart  Tela 2 — lista, pesquisa, filtros e CRUD
│   └── detalhes_screen.dart    Tela 3 — detalhes e favorito
├── widgets/                    componentes reutilizáveis (card, formulário, mapa...)
├── dialogs/confirm_delete.dart
└── utils/                      filtros, validações, horário e mensagens
firestore.rules                 regras de segurança do banco
firebase.json / .firebaserc     configuração do Firebase CLI (projeto e regras)
```

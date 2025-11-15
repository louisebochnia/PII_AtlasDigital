// import 'package:atlas_digital/src/componentes/painelAdm.dart';
// import 'package:atlas_digital/src/componentes/sub_componentes/popup_login.dart';
// import 'package:atlas_digital/src/componentes/telaConteudo.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'estado/estado_topicos.dart';
// import 'telas/pagina_conteudo.dart';
// import 'telas/pagina_galeria.dart';
// import '../app_shell.dart'; // seu AppShell com a TopNavBar/IndexedStack

// class App extends StatelessWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (_) => EstadoTopicos()..carregarMockSeVazio(),
//         ),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Atlas Digital',
//         // home: const LoginPopup(),
//         home: const PainelAdm(),
//         // home: const AppShell(), // << PaginaConteudo fica dentro do AppShell
//         routes: {
//           '/conteudos': (_) => const telaConteudo(),
//           '/galeria/celula': (_) =>
//               const Scaffold(body: Center(child: Text('Galeria: Célula'))),
//           '/galeria/epitelio': (_) =>
//               const Scaffold(body: Center(child: Text('Galeria: Epitélio'))),
//           '/galeria/tecido-conjuntivo': (_) =>
//               const Scaffold(body: Center(child: Text('Galeria: Tecido Conjuntivo'))),
//           '/galeria/musculo': (_) =>
//               const Scaffold(body: Center(child: Text('Galeria: Músculo'))),
//           '/galeria/cartilagem-osso': (_) =>
//               const Scaffold(body: Center(child: Text('Galeria: Cartilagem e Osso'))),
//         },
//       ),
//     );
//   }
// }

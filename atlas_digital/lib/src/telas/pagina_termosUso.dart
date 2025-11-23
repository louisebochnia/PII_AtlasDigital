import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/rodape.dart';
import '../estado/estado_estatisticas.dart';
import '../../temas.dart';

class PaginaTermosUso extends StatefulWidget {
  const PaginaTermosUso({super.key});

  @override
  State<PaginaTermosUso> createState() => _PaginaTermosUsoState();
}

class _PaginaTermosUsoState extends State<PaginaTermosUso> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Termos e Condições de Uso',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            const Text(
              "Seja bem-vindo ao nosso site. Leia com atenção todos os termos abaixo.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 20),

            // Introdução
            const Text(
              "Este documento, e todo o conteúdo do site é oferecido pelo Instituto Mauá de Tecnologia e pela Faculdade de Medicina do ABC, "
              "neste termo representado apenas por \"Instituto Mauá de Tecnologia\", que regulamenta todos os direitos e obrigações com "
              "todos que acessam o site, denominado neste termo como \"VISITANTE\", resguardado todos os direitos previstos na legislação, "
              "trazem as cláusulas abaixo como requisito para acesso e visita do mesmo.\n\n"
              "A permanência no website implica-se automaticamente na leitura e aceitação tácita dos presentes termos de uso a seguir. "
              "Este termo foi atualizado pela última vez em 22 de novembro de 2025.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 30),

            // Seção 1 - DA FUNÇÃO DO SITE
            Text(
              '1. DA FUNÇÃO DO SITE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Este site foi criado e desenvolvido com a função de trazer conteúdo informativo de alta qualidade, a venda de produtos físicos, "
              "digitais e a divulgação de prestação de serviço. O Instituto Mauá de Tecnologia busca através da criação de conteúdo de alta qualidade, "
              "desenvolvido por profissionais da área, trazer o conhecimento ao alcance de todos, assim como a divulgação dos próprios serviços.\n\n"
              "Nesta plataforma, poderá ser realizado tanto a divulgação de material original de alta qualidade, assim como a divulgação de produtos de e-commerce.\n\n"
              "Todo o conteúdo presente neste site foi desenvolvido buscando fontes e materiais de confiabilidade, assim como são baseados em estudos sérios e respeitados, "
              "através de pesquisa de alta nível.\n\n"
              "Todo o conteúdo é atualizado periodicamente, porém, pode conter em algum artigo, vídeo ou imagem, alguma informação que não reflita a verdade atual, "
              "não podendo o Instituto Mauá de Tecnologia ser responsabilizada de nenhuma forma ou meio por qualquer conteúdo que não esteja devidamente atualizado.\n\n"
              "É de responsabilidade do usuário de usar todas as informações presentes no site com senso crítico, utilizando apenas como fonte de informação, "
              "e sempre buscando especialistas da área para a solução concreta do seu conflito.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 25),

            // Seção 2 - DO ACEITE DOS TERMOS
            Text(
              '2. DO ACEITE DOS TERMOS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Este documento, chamado \"Termos de Uso\", aplicáveis a todos os visitantes do site, foi desenvolvido por Diego Castro Advogado – OAB/PI 15.613, "
              "modificado com permissão para este site.\n\n"
              "Este termo especifica e exige que todo usuário ao acessar o site do Instituto Mauá de Tecnologia, leia e compreenda todas as cláusulas do mesmo, "
              "visto que ele estabelece entre o Instituto Mauá de Tecnologia e o VISITANTE direitos e obrigações entre ambas as partes, "
              "aceitos expressamente pelo VISITANTE a permanecer navegando no site do Instituto Mauá de Tecnologia.\n\n"
              "Ao continuar acessando o site, o VISITANTE expressa que aceita e entende todas as cláusulas, assim como concorda integralmente com cada uma delas, "
              "sendo este aceite imprescindível para a permanência na mesma. Caso o VISITANTE discorde de alguma cláusula ou termo deste contrato, "
              "o mesmo deve imediatamente interromper sua navegação de todas as formas e meios.\n\n"
              "Este termo pode e irá ser atualizado periodicamente pelo Instituto Mauá de Tecnologia, que se resguarda no direito de alteração, "
              "sem qualquer tipo de aviso prévio e comunicação. É importante que o VISITANTE confira sempre se houve movimentação e qual foi a última atualização "
              "do mesmo no começo da página.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 25),

            // Seção 3 - DO GLOSSÁRIO
            Text(
              '3. DO GLOSSÁRIO',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Este termo pode conter algumas palavras específicas que podem não ser de conhecimento geral. Entre elas:\n\n"
              "• VISITANTE: Todo e qualquer usuário do site, de qualquer forma e meio, que acesse através de computador, notebook, tablet, "
              "celular ou quaisquer outros meios, o website ou plataforma da empresa.\n\n"
              "• NAVEGAÇÃO: O ato de visitar páginas e conteúdo do website ou plataforma da empresa.\n\n"
              "• COOKIES: Pequenos arquivos de textos gerados automaticamente pelo site e transmitido para o navegador do visitante, "
              "que servem para melhorar a usabilidade do visitante.\n\n"
              "• LOGIN: Dados de acesso do visitante ao realizar o cadastro junto ao Instituto Mauá de Tecnologia, dividido entre usuário e senha, "
              "que dá acesso à funções restritas do site.\n\n"
              "• HIPERLINKS: São links clicáveis que podem aparecer pelo site ou no conteúdo, que levam para outra página da Faculdade de Medicina do ABC ou site externo.\n\n"
              "• OFFLINE: Quando o site ou plataforma se encontra indisponível, não podendo ser acessado externamente por nenhum usuário.\n\n"
              "Em caso de dúvidas sobre qualquer palavra utilizada neste termo, o VISITANTE deverá entrar em contato com o Instituto Mauá de Tecnologia "
              "através dos canais de comunicação encontradas no site.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 25),

            // Seção 4 - DO ACESSO AO SITE
            Text(
              '4. DO ACESSO AO SITE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "O Site e plataforma funcionam normalmente 24 (vinte e quatro) horas por dia, porém podem ocorrer pequenas interrupções de forma temporária "
              "para ajustes, manutenção, mudança de servidores, falhas técnicas ou por ordem de força maior, que podem deixar o site indisponível por tempo limitado.\n\n"
              "O Instituto Mauá de Tecnologia não se responsabiliza por nenhuma perda de oportunidade ou prejuízos que esta indisponibilidade temporária "
              "possa gerar aos usuários.\n\n"
              "Em caso de manutenção que exigirem um tempo maior, o Instituto Mauá de Tecnologia irá informar previamente aos clientes da necessidade "
              "e do tempo previsto em que o site ou plataforma ficará offline.\n\n"
              "O acesso ao site só é permitido a maiores de 18 anos de idade ou que possuírem capacidade civil plena. Para acesso de menores de idade, "
              "é necessária a expressa autorização dos pais ou tutores, ficando o mesmo responsáveis sobre qualquer compra ou acesso efetuados pelo mesmo.\n\n"
              "Caso seja necessário realizar um cadastro junto a plataforma, onde o VISITANTE deverá preencher um formulário com seus dados e informações, "
              "para ter acesso a alguma parte restrita, ou realizar alguma compra.\n\n"
              "Todos os dados estão protegidos conforme a Lei Geral de Proteção de Dados, e ao realizar o cadastro junto ao site, "
              "o VISITANTE concorda integralmente com a coleta de dados conforme a Lei e com a Política de Privacidade do Instituto Mauá de Tecnologia.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 25),

            // Seção 5 - DA LICENÇA DE USO E CÓPIA
            Text(
              '5. DA LICENÇA DO USO E CÓPIA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "O visitante poderá acessar todo o conteúdo do website, como artigos, vídeos, imagens, produtos e serviços, "
              "não significando nenhum tipo de cessão de direito ou permissão de uso, ou de cópia dos mesmo.\n\n"
              "Todos os direitos são preservados, conforme a legislação brasileira, principalmente na Lei de Direitos Autorais "
              "(regulamentada na Lei nº 9.610/18), assim como no Código Civil brasileiro (regulamentada na Lei nº 10.406/02), "
              "ou quaisquer outras legislações aplicáveis.\n\n"
              "Todo o conteúdo do site é protegido por direitos autorais, e seu uso, cópia, transmissão, venda, cessão ou revenda, "
              "deve seguir a lei brasileira, tendo o Faculdade de Medicina do ABC todos os seus direitos reservados, e não permitindo "
              "a cópia ou utilização de nenhuma forma e meio, sem autorização expressa e por escrita da mesma.\n\n"
              "A Faculdade de Medicina do ABC poderá em casos concretos permitir pontualmente exceções a este direito, que serão claramente "
              "destacados no mesmo, com a forma e permissão de uso do conteúdo protegido. Este direito é revogável e limitado as especificações de cada caso.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 25),

            // Seção 6 - DAS OBRIGAÇÕES
            Text(
              '6. DAS OBRIGAÇÕES',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "O VISITANTE ao utilizar o website do Instituto Mauá de Tecnologia, concorda integralmente em:\n\n"
              "• De nenhuma forma ou meio realizar qualquer tipo de ação que tente invadir, hacker, destruir ou prejudicar a estrutura do site, "
              "plataforma do Instituto Mauá de Tecnologia ou de seus parceiros comerciais. Incluindo-se, mas não se limitando, ao envio de vírus de computador, "
              "de ataques de DDOS, de acesso indevido por falhas da mesma ou quaisquer outras forma e meio.\n\n"
              "• De não realizar divulgação indevida nos comentários do site de conteúdo de SPAM, empresas concorrentes, vírus, conteúdo que não possua "
              "direitos autorais ou quaisquer outros que não seja pertinente a discussão daquele texto, vídeo ou imagem.\n\n"
              "• Da proibição em reproduzir qualquer conteúdo do site ou plataforma sem autorização expressa, podendo responder civil e criminalmente pelo mesmo.\n\n"
              "• Com a Política de Privacidade do site, assim como tratamos os dados referentes ao cadastro e visita no site, podendo a qualquer momento e forma, "
              "requerer a exclusão dos mesmos, através do formulário de contato.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 25),

            // Seção 7 - DA MONETIZAÇÃO E PUBLICIDADE
            Text(
              '7. DA MONETIZAÇÃO E PUBLICIDADE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "O Faculdade de Medicina do ABC pode alugar ou vender espaços publicitários na plataforma, ou no site, diretamente aos anunciantes, "
              "ou através de empresas especializadas com o Adsense (Google), Taboola ou outras plataformas especializadas.\n\n"
              "Essas publicidades não significam nenhuma forma de endosso ou responsabilidade pelos mesmos, ficando o VISITANTE responsável pelas compras, "
              "visitas, acessos ou quaisquer ações referentes as estas empresas.\n\n"
              "Todas as propagandas no site ou plataforma serão claramente destacadas como publicidade, como forma de disclaimer da Faculdade de Medicina do ABC "
              "e de conhecimento do VISITANTE.\n\n"
              "Em casos de compra de produtos ou serviços, será possível a devolução em até 07 (sete) dias, conforme o Código de Defesa do Consumidor.\n\n"
              "Estes anúncios podem ser selecionados pela empresa de publicidade automaticamente, conforme as visitas recentes do VISITANTE, "
              "assim como baseado no seu histórico de busca, conforme as políticas de acesso da plataforma.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 25),

            // Seção 8 - DOS TERMOS GERAIS
            Text(
              '8. DOS TERMOS GERAIS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "O Site irá apresentar hiperlinks durante toda a sua navegação, que podem levar diretamente para outra página da Faculdade de Medicina do ABC "
              "ou para sites externos.\n\n"
              "Apesar da Faculdade de Medicina do ABC apenas criar links para sites externos de extrema confiança, caso o usuário acesse um site externo, "
              "o Instituto Mauá de Tecnologia e a Faculdade de Medicina do ABC não tem nenhuma responsabilidade pelo meio, sendo uma mera indicação de "
              "complementação de conteúdo, ficando o mesmo responsável pelo acesso, assim como sobre quaisquer ações que venham a realizar neste site.\n\n"
              "Em caso que ocorra eventuais conflitos judiciais entre o VISITANTE, o Instituto Mauá de Tecnologia e a Faculdade de Medicina do ABC, "
              "o foro elegido para a devida ação será o da Comarca da Capital do Estado de São Paulo/SP, mesmo que haja outro mais privilegiado.\n\n"
              "Este Termo de uso é valido a partir de 22 de novembro de 2025.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

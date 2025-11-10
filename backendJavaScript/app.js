//Importação das bibliotecas necessárias para o backend
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const unzipper = require('unzipper');
const { exec } = require("child_process");

//Importação dos modelos
const Subtopico = require('./models/subtopicos');
const Imagem = require('./models/imagem');
const Informacao = require('./models/informacao');
const Topico = require('./models/topicos');
const Admin = require('./models/admin');
const SubAdmin = require('./models/subadmin');
const Usuario = require('./models/usuario');
const Estatisticas = require('./models/estatisticas');
const ImagemThumbnail = require('./imagemThumbnail');


const app = express();
app.use(express.json());
app.use(cors());

// CONEXÃO COM O BANCO DE DADOS
async function conectarAoMongo() {
  await mongoose.connect(`mongodb+srv://atlas_T2Sub2_db_user:KFL0q45l6BmNdBLK@atlasdigital.qrhn0eb.mongodb.net/?retryWrites=true&w=majority&appName=AtlasDigital`)
}

// CRUD VISITANTES -----------------------------------------------------------------------------------------------

// ROTA GET - Buscar estatísticas
app.get('/estatisticas', async (req, res) => {
  try {
    console.log('BACKEND: Buscando estatísticas...');

    const estatisticas = await Estatisticas.find({})
      .sort({ data: -1 })
      .limit(30);

    const totalAcessos = estatisticas.reduce((total, estat) => total + estat.totalAcessos, 0);

    const todosUsuariosUnicos = new Set();
    estatisticas.forEach(estat => {
      estat.usuariosUnicos.forEach(userId => todosUsuariosUnicos.add(userId));
    });

    const acessosPorDia = {};
    const hoje = new Date();

    for (let i = 0; i < 7; i++) {
      const data = new Date(hoje);
      data.setDate(data.getDate() - (6 - i));
      const dataStr = data.toISOString().split('T')[0];

      const estatDia = estatisticas.find(e => e.data === dataStr);
      acessosPorDia[dataStr] = estatDia ? estatDia.totalAcessos : 0;
    }

    console.log('BACKEND: Estatísticas enviadas - Total:', totalAcessos);

    res.json({
      success: true,
      totalAcessos: totalAcessos,
      totalUsuariosUnicos: todosUsuariosUnicos.size,
      acessosPorDia: acessosPorDia,
      ultimaAtualizacao: new Date(),
      totalDiasRegistrados: estatisticas.length
    });
  } catch (error) {
    console.error('BACKEND: Erro ao buscar estatísticas:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST - Registrar visita ao site (página inicial/geral)

app.post('/estatisticas/visita', async (req, res) => {
  try {
    console.log('BACKEND: ROTA POST /estatisticas/visita CHAMADA!');

    const dataAcesso = new Date(req.body.dataAcesso || Date.now());
    const dataFormatada = dataAcesso.toISOString().split('T')[0];
    const hora = dataAcesso.getHours();
    const pagina = req.body.pagina || 'site_geral';
    const userId = req.body.userId;

    console.log('BACKEND: Processando - Data:', dataFormatada, 'Hora:', hora, 'Página:', pagina, 'User:', userId);

    let estatistica = await Estatisticas.findOne({ data: dataFormatada });

    if (estatistica) {
      console.log('BACKEND: Estatística existente. Acessos antes:', estatistica.totalAcessos);
      estatistica.totalAcessos += 1;
      estatistica.acessosPorHora[hora] = (estatistica.acessosPorHora[hora] || 0) + 1;
      estatistica.paginasAcessadas[pagina] = (estatistica.paginasAcessadas[pagina] || 0) + 1;
      estatistica.markModified('acessosPorHora');
      estatistica.markModified('paginasAcessadas');

      if (userId && !estatistica.usuariosUnicos.includes(userId)) {
        estatistica.usuariosUnicos.push(userId);
        estatistica.markModified('usuariosUnicos');
      }

      estatistica.ultimaAtualizacao = new Date();
    } else {
      console.log('BACKEND: Criando NOVA estatística');
      estatistica = new Estatisticas({
        data: dataFormatada,
        totalAcessos: 1,
        acessosPorHora: { [hora]: 1 },
        paginasAcessadas: { [pagina]: 1 },
        usuariosUnicos: userId ? [userId] : [],
        ultimaAtualizacao: new Date()
      });
    }

    await estatistica.save();
    console.log('BACKEND: Visita registrada. Acessos agora:', estatistica.totalAcessos);

    res.json({
      success: true,
      message: 'Visita registrada com sucesso!',
      estatisticaId: estatistica._id,
      totalAcessos: estatistica.totalAcessos
    });

  } catch (error) {
    console.error('BACKEND: Erro ao registrar visita:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Health check (opcional, mas útil)
app.get('/health', (req, res) => {
  console.log('Health check chamado');
  res.json({ success: true, message: 'Backend OK' });
});

// FIM CRUD VISITANTES -----------------------------------------------------------------------------------------------

// CRUD CAPITULOS ----------------------------------------------------------------------------------------------------
app.post('/subtopicos', async (req, res) => {
  try {
    const novoSubtopico = new Subtopico(req.body);
    const salvo = await novoSubtopico.save();
    res.status(201).json(salvo);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Listar todos os Subtópicos
app.get('/subtopicos', async (req, res) => {
  try {
    const subtopicos = await Subtopico.find();
    res.json(subtopicos);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Listar subtopicos de um topico
app.get('/topicos/:topicoId/subtopicos', async (req, res) => {
  try {
    const subtopicos = await Subtopico.find({ topicoId: req.params.topicoId });
    res.status(200).json(subtopicos);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao listar subtópicos', error: err.message });
  }
});

// Buscar Subtópico por ID
app.get('/subtopicos/:id', async (req, res) => {
  try {
    const subtopico = await Subtopico.findById(req.params.id);
    if (!subtopico) return res.status(404).json({ message: 'Subtópico não encontrado' });
    res.json(subtopico);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Atualizar Subtópico
app.put('/subtopicos/:id', async (req, res) => {
  try {
    const atualizado = await Subtopico.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    if (!atualizado) return res.status(404).json({ message: 'Subtópico não encontrado' });
    res.json(atualizado);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Deletar Subtópico
app.delete('/subtopicos/:id', async (req, res) => {
  try {
    const subt = await Subtopico.findById(req.params.id);
    if (!subt) return res.status(404).json({ message: 'Subtópico não encontrado' });

    // remove referência do tópico pai
    await Topico.findByIdAndUpdate(subt.topicoId, {
      $pull: { subtopicos: subt._id }
    });

    await Subtopico.findByIdAndDelete(req.params.id);

    res.json({ message: 'Subtópico deletado com sucesso' });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// FIM CRUD CAPITULOS ----------------------------------------------------------------------------------------------------

// CRUD TÓPICOS --------------------------------------------------------------------------

app.post('/topicos', async (req, res) => {
  try {
    const novoTopico = new Topico(req.body)
    const salvo = await novoTopico.save()
    res.status(201).json(salvo)
  } catch (err) {
    res.status(400).json({ message: err.message })
  }
})

app.get('/topicos', async (req, res) => {
  try {
    const topicos = await Topico.find()
    res.json(topicos)
  } catch (err) {
    res.status(500).json({ message: err.message })
  }
})

app.get('/topicos/:id', async (req, res) => {
  try {
    const topico = await Topico.findById(req.params.id)
    if (!topico) return res.status(404).json({ message: 'Tópico não encontrado' })
    res.json(topico)
  } catch (err) {
    res.status(400).json({ message: err.message })
  }
})

app.put('/topicos/:id', async (req, res) => {
  try {
    const atualizado = await Topico.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true })
    if (!atualizado) return res.status(404).json({ message: 'Tópico não encontrado' })
    res.json(atualizado)
  } catch (err) {
    res.status(400).json({ message: err.message })
  }
})

app.delete('/topicos/:id', async (req, res) => {
  try {
    const deletado = await Topico.findByIdAndDelete(req.params.id)
    if (!deletado) return res.status(404).json({ message: 'Tópico não encontrado' })
    res.json({ message: 'Tópico deletado com sucesso' })
  } catch (err) {
    res.status(400).json({ message: err.message })
  }
})

// FIM CRUD TÓPICOS ----------------------------------------------------------------------

// CRUD DE INFORMAÇÕES! ------------------------------------------------------------------

app.post('/informacao', async (req, res) => {
  try {
    const informacao = new Informacao(req.body)
    await informacao.save()
    res.status(201).json(informacao)
  } catch (err) {
    res.status(400).json({ message: err.message })
  }
})

app.get('/informacao', async (req, res) => {
  try {
    const informacoes = await Informacao.find()
    res.json(informacoes)
  } catch (err) {
    res.status(500).json({ message: err.message })
  }
})

app.get('/informacao/:id', async (req, res) => {
  try {
    const info = await Informacao.findById(req.params.id)
    if (!info) return res.status(404).json({ message: 'Não encontrado' })
    res.json(info)
  } catch (err) {
    res.status(500).json({ message: err.message })
  }
})

app.put('/informacao/:id', async (req, res) => {
  try {
    const info = await Informacao.findByIdAndUpdate(req.params.id, req.body, { new: true })
    res.json(info)
  } catch (err) {
    res.status(400).json({ message: err.message })
  }
})

app.delete('/informacao/:id', async (req, res) => {
  try {
    await Informacao.findByIdAndDelete(req.params.id)
    res.json({ message: 'Informação removida' })
  } catch (err) {
    res.status(500).json({ message: err.message })
  }
})

// FIM CRUD DE INFORMAÇÕES! --------------------------------------------------------------

// CRUD DE IMAGENS! ----------------------------------------------------------------------

// Código para salvar a imagem nos arquivos
const upload = multer({
  storage: multer.diskStorage({
    destination: 'uploads/temp/',
    filename: (req, file, cb) => {
      cb(null, Date.now() + '-' + file.originalname);
    }
  })
});

async function descompactarZip(zipPath, destino) {
  await fs.createReadStream(zipPath)
    .pipe(unzipper.Extract({ path: destino }))
    .promise();

  console.log('ZIP extraído em: ', destino);

  await fs.promises.unlink(zipPath);
}

async function listarArquivosRecursivamente(diretorio, baseDir = diretorio, arquivoList = []) {
  const itens = await fs.promises.readdir(diretorio);

  for (const item of itens) {
    const caminhoCompleto = path.join(diretorio, item);
    const stat = await fs.promises.stat(caminhoCompleto);

    if (stat.isDirectory()) {
      await listarArquivosRecursivamente(caminhoCompleto, baseDir, arquivoList);
    } else {
      const caminhoRelativo = path.relative(baseDir, caminhoCompleto);
      arquivoList.push(caminhoRelativo);
    }
  }

  return arquivoList;
}

async function prepararPastaMrxs(destino) {
  const arquivos = await listarArquivosRecursivamente(destino, destino);
  console.log('Arquivos descompactados:', arquivos);

  const mrxsFile = arquivos.find(f => f.endsWith('.mrxs'));
  const mrxsPath = path.join(destino, mrxsFile);
  const mrxsDir = path.dirname(mrxsPath);
  const mrxsBaseName = path.basename(mrxsFile, '.mrxs');

  const subpastas = await fs.promises.readdir(mrxsDir, { withFileTypes: true });
  let pastaEncontrada = null;

  for (const ent of subpastas) {
    if (ent.isDirectory()) {
      const conteudo = await fs.promises.readdir(path.join(mrxsDir, ent.name));
      const contemArquivosMRXS = conteudo.some(f =>
        f.toLowerCase().endsWith('.dat') ||
        f.toLowerCase() === 'slidesdat.ini'
      );

      if (contemArquivosMRXS) {
        pastaEncontrada = ent.name;
        break;
      }
    }
  }

  if (pastaEncontrada) {
    const origem = path.join(mrxsDir, pastaEncontrada);
    const destinoFiles = path.join(mrxsDir, `${mrxsBaseName}.mrxs.files`);

    try {
      await fs.promises.access(destinoFiles);
    } catch {
      await fs.promises.rename(origem, destinoFiles);
    }
  } else {
    console.log('Nenhuma pasta compatível encontrada');
  }

  return {
    mrxsPath: mrxsPath,
    mrxsFile: mrxsFile,
    pastaFiles: path.join(mrxsDir, `${mrxsBaseName}.mrxs.files`)
  };
}

async function preGerarTilesPrincipais(mrxsFile, mrxsPath) {
  const slideName = path.parse(mrxsFile).name;
  const tilesDir = path.join("uploads", "tiles", path.parse(mrxsFile).name,);
  await fs.promises.mkdir(tilesDir, { recursive: true });

  const python = `python python/tiles.py pre "${mrxsPath}" "${tilesDir}"`

  await new Promise((resolve, reject) => {
    exec(python, (err, stdout, stderr) => {
      if (err) return reject(stderr);
      resolve();
    });
  });

  const dziPath = path.join("uploads", "tiles", path.parse(mrxsFile).name, `${slideName}.dzi`)

  return dziPath;
}

// Códigos para o banco de dados
app.post('/images', upload.single('imagem'), async (req, res) => {
  try {

    const thumbnail = new ImagemThumbnail();

    const { filename, path: zipPath } = req.file;
    const { nomeImagem, topico, subtopico, anotacao } = req.body;

    const destino = path.join('uploads', 'images', path.parse(filename).name);
    await fs.promises.mkdir(destino, { recursive: true });

    await descompactarZip(zipPath, destino);

    const { mrxsPath, mrxsFile, pastaFiles } = await prepararPastaMrxs(destino);

    let enderecoThumbnail = null;

    try {
      const thumbnailName = `${path.parse(mrxsFile).name}.jpg`;
      enderecoThumbnail = await thumbnail.criarAPartirDeMRXS(mrxsPath, thumbnailName);
    } catch (erro) {
      console.log('Falha ao gerar thumbnail: ', erro.message);
    }

    const dziPath = await preGerarTilesPrincipais(mrxsFile, mrxsPath);

    const novaImagem = new Imagem({
      nomeArquivo: mrxsFile,
      nomeImagem: nomeImagem,
      enderecoPastaMrxs: destino,
      enderecoImagem: mrxsPath,
      enderecoThumbnail: enderecoThumbnail,
      enderecoTiles: dziPath,
      topico: topico,
      subtopico: subtopico,
      anotacao: anotacao
    });

    await novaImagem.save();

    res.status(200).json({ message: 'Imagem salva com sucesso!' });

  } catch (error) {
    console.error("Erro completo ao salvar imagem:", error);
    res.status(500).json({ error: error.message });
  }
});

app.delete('/images/:id', async (req, res) => {
  try {
    const imagem = await Imagem.findById(req.params.id);
    if (!imagem) {
      return res.json({ error: 'Imagem não encontrada' });
    }
    else {
      if (fs.existsSync(imagem.enderecoImagem)) {
        fs.unlinkSync(imagem.enderecoImagem);
      }

      if (imagem.enderecoThumbnail && fs.existsSync(imagem.enderecoThumbnail)) {
        fs.unlinkSync(imagem.enderecoThumbnail);
      }

      await Imagem.findByIdAndDelete(req.params.id);

      res.status(200).json({ message: 'Imagem apagada com sucesso!' });
    }
  }
  catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// FIM CRUD DE IMAGENS! ------------------------------------------------------------------

// CRUD DE USUÁRIOS! ----------------------------------------------------------------------

app.post('/signup', async (req, res) => {
  try {
    const email = req.body.email;
    const senha = req.body.senha;
    const cargo = req.body.cargo

    if (!email.endsWith('@fmabc.net')) {
      return res.status(403).json({ message: 'Apenas e-mails @fmabc.net são permitidos.' });
    }

    const senhaCriptografada = await bcrypt.hash(senha, 10);
    const usuario = new Usuario({ email: email, senha: senhaCriptografada, cargo: cargo });

    const respMongo = await usuario.save();
    console.log(respMongo)
    res.status(201).end()
  } catch (erro) {
    res.status(409).json({ error: erro.message });
  }
});

app.post('/login', async (req, res) => {
  const email = req.body.email;
  const senha = req.body.senha;

  const usuarioExiste = await Usuario.findOne({ email: email });

  if (!usuarioExiste) {
    return res.status(401).json({ mensagem: "Email inválido!" });
  }

  const senhaValida = await bcrypt.compare(senha, usuarioExiste.senha);

  if (!senhaValida) {
    return res.status(401).json({ mensagem: "Senha inválida!" });
  }

  const token = jwt.sign(
    { email: email },
    "id-secreto",
    { expiresIn: "7d" }
  );

  res.status(200).json({ token: token, cargo: usuarioExiste.cargo, id: usuarioExiste._id });
});

app.get('/usuarios', async (req, res) => {
  try {

    const usuarios = await Usuario.find().sort({
      cargo: 1,
      email: 1
    });

    res.status(200).json(usuarios);
  } catch (erro) {
    res.status(500).json({ message: erro.message })
  }

});

app.get('/usuario/:id', async (req, res) => {
  try {
    const usuario = await Usuario.findById(req.params.id)

    if (!usuario) return res.status(404).json({ message: 'Usuário não encontrado' })

    res.status(200).json(usuario)
  } catch (erro) {
    res.status(500).json({ message: erro.message })
  }
});

app.put('/usuario/:id', async (req, res) => {
  try {
    const usuario = await Usuario.findByIdAndUpdate(req.params.id, req.body, { new: true })

    if (!usuario) {
      return res.status(404).json({ message: 'Usuário não encontrado' })
    }

    res.json(usuario)
  } catch (err) {
    res.status(400).json({ message: err.message })
  }
})

app.delete('/usuario/:id', async (req, res) => {
  try {
    const usuario = await Usuario.findByIdAndDelete(req.params.id);

    if (!usuario) {
      return res.status(404).json({ message: 'Usuário não encontrado' })
    }

    res.json({ message: 'Informação removida' })
  } catch (erro) {
    res.status(400).json({})
  }
});

// // ===================
// // 1. Middleware de autenticação
// // ===================
// const protect = async (req, res, next) => {
//   const header = req.headers.authorization;
//   if (!header || !header.startsWith('Bearer ')) {
//     return res.status(401).json({ message: 'Token não fornecido.' });
//   }

//   try {
//     const token = header.split(' ')[1];
//     const decoded = jwt.verify(token, process.env.JWT_SECRET);

//     if (decoded.role === 'admin') {
//       req.user = await Admin.findById(decoded.id).select('-password');
//     } else {
//       req.user = await SubAdmin.findById(decoded.id).select('-password');
//     }

//     if (!req.user) return res.status(401).json({ message: 'Usuário não encontrado.' });

//     next();
//   } catch (error) {
//     res.status(401).json({ message: 'Token inválido.' });
//   }
// };

// const adminOnly = (req, res, next) => {
//   if (!req.user || req.user instanceof SubAdmin) {
//     return res.status(403).json({ message: 'Acesso restrito a administradores.' });
//   }
//   next();
// };

// // ===================
// // 2. LOGIN - Admin
// // ===================
// app.post('/api/admin/login', async (req, res) => {
//   const { email, password } = req.body;

//   if (!email.endsWith('@fmabc.net')) {
//     return res.status(403).json({ message: 'Apenas e-mails @fmabc.net são permitidos.' });
//   }

//   try {
//     const admin = await Admin.findOne({ email });
//     if (!admin) return res.status(404).json({ message: 'Admin não encontrado.' });

//     const valid = await bcrypt.compare(password, admin.password);
//     if (!valid) return res.status(401).json({ message: 'Senha incorreta.' });

//     const token = jwt.sign({ id: admin._id, role: 'admin' }, process.env.JWT_SECRET, {
//       expiresIn: '1d'
//     });

//     res.json({ token });
//   } catch (err) {
//     console.error(err);
//     res.status(500).json({ message: 'Erro interno do servidor.' });
//   }
// });

// // ===================
// // 3. LOGIN - SubAdmin
// // ===================
// app.post('/api/subadmin/login', async (req, res) => {
//   const { email, password } = req.body;

//   if (!email.endsWith('@fmabc.net')) {
//     return res.status(403).json({ message: 'Apenas e-mails @fmabc.net são permitidos.' });
//   }

//   try {
//     const subAdmin = await SubAdmin.findOne({ email });
//     if (!subAdmin) return res.status(404).json({ message: 'SubAdmin não encontrado.' });

//     const valid = await bcrypt.compare(password, subAdmin.password);
//     if (!valid) return res.status(401).json({ message: 'Senha incorreta.' });

//     const token = jwt.sign({ id: subAdmin._id, role: 'subadmin' }, process.env.JWT_SECRET, {
//       expiresIn: '1d'
//     });

//     res.json({ token });
//   } catch (err) {
//     console.error(err);
//     res.status(500).json({ message: 'Erro interno do servidor.' });
//   }
// });

// // ===================
// // 4. CRUD SubAdmins (somente Admin)
// // ===================

// // Criar SubAdmin
// app.post('/api/subadmin', protect, adminOnly, async (req, res) => {
//   const { name, username, email, password } = req.body;

//   if (!email.endsWith('@fmabc.net')) {
//     return res.status(400).json({ message: 'Somente e-mails @fmabc.net são permitidos.' });
//   }

//   try {
//     const subAdmin = new SubAdmin({
//       name,
//       username,
//       email,
//       password,
//       createdBy: req.user._id
//     });

//     await subAdmin.save();
//     res.status(201).json(subAdmin);
//   } catch (err) {
//     res.status(400).json({ message: err.message });
//   }
// });

// // Listar SubAdmins
// app.get('/api/subadmin', protect, adminOnly, async (req, res) => {
//   const subAdmins = await SubAdmin.find().populate('createdBy', 'username email');
//   res.json(subAdmins);
// });

// // Atualizar SubAdmin
// app.put('/api/subadmin/:id', protect, adminOnly, async (req, res) => {
//   try {
//     const subAdmin = await SubAdmin.findByIdAndUpdate(req.params.id, req.body, { new: true });
//     if (!subAdmin) return res.status(404).json({ message: 'SubAdmin não encontrado.' });
//     res.json(subAdmin);
//   } catch (err) {
//     res.status(400).json({ message: err.message });
//   }
// });

// // Excluir SubAdmin
// app.delete('/api/subadmin/:id', protect, adminOnly, async (req, res) => {
//   try {
//     const subAdmin = await SubAdmin.findByIdAndDelete(req.params.id);
//     if (!subAdmin) return res.status(404).json({ message: 'SubAdmin não encontrado.' });
//     res.json({ message: 'SubAdmin removido com sucesso.' });
//   } catch (err) {
//     res.status(400).json({ message: err.message });
//   }
// });

module.exports = app

if (process.env.NODE_ENV !== 'test') {
  conectarAoMongo()
    .catch(err => console.log("Erro conexão Mongo:", err))

  const PORT = 3000
  app.listen(PORT, () => console.log(`server up & running, conexão ok`))
}


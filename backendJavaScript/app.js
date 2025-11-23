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

//Importação dos modelos
const Subtopico = require('./models/subtopicos');
const ImagemModel = require('./models/imagemModel');
const Informacao = require('./models/informacao');
const Topico = require('./models/topicos');
const Usuario = require('./models/usuario');
const Estatisticas = require('./models/estatisticas');
const ImagemThumbnail = require('./imagemThumbnail');
const Imagem = require('./imagem');
const hyperlink = require('./models/hyperlink');


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

// Códigos para o banco de dados
app.post('/images', upload.single('imagem'), async (req, res) => {
  try {

    const imagem = new Imagem();
    const thumbnail = new ImagemThumbnail();

    const { filename, path: zipPath } = req.file;
    const { nomeImagem, topico, subtopico, anotacao } = req.body;

    const pastaBase = await imagem.descompactarZip(zipPath, nomeImagem);

    console.log(pastaBase)

    const resultado = await imagem.prepararPastaMrxs(pastaBase, nomeImagem);

    console.log(resultado.enderecoPastaMrxs);
    let enderecoThumbnail = null;

    console.log(`mrxsFile: ${resultado.mrxsFile}`);
    console.log(`mrxsPath: ${resultado.mrxsPath}`);

    try {
      const thumbnailName = `${path.parse(resultado.mrxsFile).name}.jpg`;
      enderecoThumbnail = await thumbnail.criarAPartirDeMRXS(resultado.mrxsPath, thumbnailName);
    } catch (erro) {
      console.log('Falha ao gerar thumbnail: ', erro.message);
    }

    const tilesDir = await imagem.preGerarTilesPrincipais(resultado.mrxsFile, resultado.mrxsPath);

    const novaImagem = new ImagemModel({
      nomeArquivo: resultado.mrxsFile,
      nomeImagem: nomeImagem,
      enderecoPastaMrxs: resultado.enderecoPastaMrxs,
      enderecoThumbnail: enderecoThumbnail,
      enderecoTiles: tilesDir,
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

app.get('/images', async (req, res) => {
  try {
    dadosImagens = await ImagemModel.find();
    res.status(200).json(dadosImagens);
  } catch (erro) {
    res.status(500).json({ message: erro.message });
  }
});

app.put('/images/:id', async (req, res) => {
  try {
    console.log(req.params.id);
    const info = await ImagemModel.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(info);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

app.delete('/images/:id', async (req, res) => {
  try {
    const imagem = await ImagemModel.findById(req.params.id);
    if (!imagem) {
      return res.json({ error: 'Imagem não encontrada' });
    }
    else {
      if (fs.existsSync(imagem.enderecoPastaMrxs)) {
        fs.rmSync(imagem.enderecoPastaMrxs, { recursive: true, force: true });
      }

      if (imagem.enderecoThumbnail && fs.existsSync(imagem.enderecoThumbnail)) {
        fs.unlinkSync(imagem.enderecoThumbnail);
      }

      if (imagem.enderecoTiles && fs.existsSync(imagem.enderecoTiles)) {
        fs.rmSync(imagem.enderecoTiles, { recursive: true, force: true });
      }

      await ImagemModel.findByIdAndDelete(imagem.id);

      res.status(200).json({ message: 'Imagem apagada com sucesso!' });
    }
  }
  catch (error) {
    res.status(500).json({ error: error.message });
  }
});

//Código para acessar os arquivos na pasta uploads a partir de uma url
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// FIM CRUD DE IMAGENS! ------------------------------------------------------------------

// CÓDIGO PARA EXIBIR OS TILES -----------------------------------------------------------

// Código para pegar os metadados da imagem
app.get('/:imageId/meta.json', async (req, res) => {
    try {
        const { imageId } = req.params;
        const tilesDir = path.join('uploads', 'tiles', imageId);
        const metaPath = path.join(tilesDir, 'meta.json');
        
        console.log(`Buscando metadados: ${metaPath}`);
        
        if (await fs.pathExists(metaPath)) {
            const meta = await fs.readJson(metaPath);
            console.log('Metadados encontrados:', Object.keys(meta.level_metas || {}).length, 'níveis');
            res.json(meta);
        } else {
            console.log('Metadados não encontrados');
            res.status(404).json({ error: 'Metadados não encontrados' });
        }
    } catch (error) {
        console.error('Erro ao carregar metadados:', error);
        res.status(500).json({ error: error.message });
    }
});

// Código para os tiles
app.get('/tiles/:imageId/:level/:x/:y', async (req, res) => {
    try {
        const { imageId, level, x, y } = req.params;
        //const imagem
        // const tilesDir = imagem.
        // const tilePath = path.join(tilesDir, `level_${level}`, `${x}_${y}.jpg`);
        
        console.log(`🔍 Buscando tile: ${tilePath}`);
        
        // Se o tile já existe, serve diretamente
        if (await fs.existsSync(tilePath)) {
            console.log('Tile pré-gerado encontrado');
            res.sendFile(path.resolve(tilePath));
            return;
        }
        
        // Se não existe, gera sob demanda
        console.log('Tile não encontrado, gerando sob demanda...');
        const mrxsPath = path.join('uploads', 'images', imageId, `${imageId}.mrxs`);
        
        if (fs.existsSync(mrxsPath)) {
            console.log('Arquivo MRXS não encontrado:', mrxsPath);
            return res.status(404).json({ error: 'Imagem MRXS não encontrada' });
        }
        
        console.log(`Chamando Python para gerar tile: level=${level}, x=${x}, y=${y}`);
        
        // Chama o Python para gerar o tile
        const pythonProcess = spawn('python', [
            'python/gerar_tiles.py',
            'tile',
            mrxsPath,
            tilesDir,
            level,
            x,
            y
        ]);
        
        let tileOutput = '';
        let errorOutput = '';

        pythonProcess.stdout.on('data', (data) => {
            tileOutput += data.toString();
        });
        
        pythonProcess.stderr.on('data', (data) => {
            errorOutput += data.toString();
            console.error('Erro Python:', data.toString());
        });
        
        pythonProcess.on('close', (code) => {
            if (code === 0 && tileOutput.includes('TILE_PATH:')) {
                const generatedPath = tileOutput.split('TILE_PATH:')[1].trim();
                console.log('Tile gerado com sucesso:', generatedPath);
                
                if (fs.existsSync(generatedPath)) {
                    res.sendFile(path.resolve(generatedPath));
                } else {
                    console.log('Arquivo gerado não encontrado:', generatedPath);
                    res.status(500).json({ error: 'Falha ao gerar tile' });
                }
            } else {
                console.log('Falha no processo Python. Código:', code);
                console.log('Saída:', tileOutput);
                console.log('Erros:', errorOutput);
                res.status(500).json({ 
                    error: 'Falha ao gerar tile',
                    details: errorOutput 
                });
            }
        });
        
    } catch (error) {
        console.error('❌ Erro ao processar tile:', error);
        res.status(500).json({ error: error.message });
    }
});

// Código para ver se uma imagem tem tiles
app.get('/tiles/:imageId/status', async (req, res) => {
    try {
        const { imageId } = req.params;
        const tilesDir = path.join('uploads', 'tiles', imageId);
        const metaPath = path.join(tilesDir, 'meta.json');
        
        const exists = await fs.existsSync(metaPath);
        res.json({ 
            hasTiles: exists,
            imageId: imageId
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// FIM DO CÓDIGO PARA EXIBIR OS TILES ----------------------------------------------------

// CRUD DE USUÁRIOS! ---------------------------------------------------------------------

app.post('/signup', async (req, res) => {
  try {
    const email = req.body.email;
    const senha = req.body.senha;
    const cargo = req.body.cargo;

    if (!email.endsWith('@fmabc.net')) {
      return res.status(403).json({ message: 'Apenas e-mails @fmabc.net são permitidos.' });
    }

    const usuario = new Usuario({ 
      email: email, 
      senha: senha, 
      cargo: cargo 
    });

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

  const senhaValida = (senha === usuarioExiste.senha); 

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

// Crud Hyperlinks
app.post('/hyperlink', async (req, res) => {
  try {
    const hyperlink = new hyperlink(req.body)
    await hyperlink.save()
    res.status(201).json(hyperlink)
  } catch (err) {
    res.status(400).json({ message: err.message })
  }
})

app.get('/hyperlink', async (req, res) => {
  try {
    const hyperlink = await hyperlink.find()
    res.json(hyperlink)
  } catch (err) {
    res.status(500).json({ message: err.message })
  }
})

app.get('/hyperlink/:id', async (req, res) => {
  try {
    const info = await hyperlink.findById(req.params.id)
    if (!info) return res.status(404).json({ message: 'Não encontrado' })
    res.json(info)
  } catch (err) {
    res.status(500).json({ message: err.message })
  }
})

app.put('/hyperlink/:id', async (req, res) => {
  try {
    const info = await hyperlink.findByIdAndUpdate(req.params.id, req.body, { new: true })
    res.json(info)
  } catch (err) {
    res.status(400).json({ message: err.message })
  }
})

app.delete('/hyperlink/:id', async (req, res) => {
  try {
    await hyperlink.findByIdAndDelete(req.params.id)
    res.json({ message: 'Link removido' })
  } catch (err) {
    res.status(500).json({ message: err.message })
  }
})

module.exports = app

if (process.env.NODE_ENV !== 'test') {
  conectarAoMongo()
    .catch(err => console.log("Erro conexão Mongo:", err))

  const PORT = 3000
  app.listen(PORT, () => console.log(`server up & running, conexão ok`))
}


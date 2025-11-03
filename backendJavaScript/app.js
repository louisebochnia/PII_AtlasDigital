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
const Imagem = require('./models/imagem');
const Informacao = require('./models/informacao');
const Topico = require('./models/topicos');
const Admin = require('./models/admin');
const SubAdmin = require('./models/subadmin');

const app = express() ;
app.use(express.json());
app.use(cors());

// CONEXÃO COM O BANCO DE DADOS
async function conectarAoMongo() {
  await mongoose.connect(`mongodb+srv://atlas_T2Sub2_db_user:KFL0q45l6BmNdBLK@atlasdigital.qrhn0eb.mongodb.net/?retryWrites=true&w=majority&appName=AtlasDigital`)
}

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
    destination: 'uploads/images/',
    filename: (req, file, cb) => {
      cb(null, Date.now() + '-' + file.originalname);
    }
  })
});

// Códigos para o banco de dados
app.post('/images', upload.single('imagem'), async (req, res) => {
  try {
    const novaImagem = new Imagem({
      nomeArquivo: req.file.filename,
      enderecoImagem: req.file.path,
      topico: req.body.topico,
      anotacao: req.body.anotacao
    });

    await novaImagem.save();

    res.status(200).json({ message: 'Imagem salva com sucesso!' });
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/images/:id', async (req, res) => {
  try {
    const imagem = await Imagem.findById(req.params.id);
    if(!imagem) {
      return res.json({error: 'Imagem não encontrada'});
    }
    else{
      if(fs.existsSync(imagem.enderecoImagem)) {
        fs.unlinkSync(imagem.enderecoImagem);
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

// ===================
// 1. Middleware de autenticação
// ===================
const protect = async (req, res, next) => {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Token não fornecido.' });
  }

  try {
    const token = header.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    if (decoded.role === 'admin') {
      req.user = await Admin.findById(decoded.id).select('-password');
    } else {
      req.user = await SubAdmin.findById(decoded.id).select('-password');
    }

    if (!req.user) return res.status(401).json({ message: 'Usuário não encontrado.' });

    next();
  } catch (error) {
    res.status(401).json({ message: 'Token inválido.' });
  }
};

const adminOnly = (req, res, next) => {
  if (!req.user || req.user instanceof SubAdmin) {
    return res.status(403).json({ message: 'Acesso restrito a administradores.' });
  }
  next();
};

// ===================
// 2. LOGIN - Admin
// ===================
app.post('/api/admin/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email.endsWith('@fmabc.net')) {
    return res.status(403).json({ message: 'Apenas e-mails @fmabc.net são permitidos.' });
  }

  try {
    const admin = await Admin.findOne({ email });
    if (!admin) return res.status(404).json({ message: 'Admin não encontrado.' });

    const valid = await bcrypt.compare(password, admin.password);
    if (!valid) return res.status(401).json({ message: 'Senha incorreta.' });

    const token = jwt.sign({ id: admin._id, role: 'admin' }, process.env.JWT_SECRET, {
      expiresIn: '1d'
    });

    res.json({ token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Erro interno do servidor.' });
  }
});

// ===================
// 3. LOGIN - SubAdmin
// ===================
app.post('/api/subadmin/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email.endsWith('@fmabc.net')) {
    return res.status(403).json({ message: 'Apenas e-mails @fmabc.net são permitidos.' });
  }

  try {
    const subAdmin = await SubAdmin.findOne({ email });
    if (!subAdmin) return res.status(404).json({ message: 'SubAdmin não encontrado.' });

    const valid = await bcrypt.compare(password, subAdmin.password);
    if (!valid) return res.status(401).json({ message: 'Senha incorreta.' });

    const token = jwt.sign({ id: subAdmin._id, role: 'subadmin' }, process.env.JWT_SECRET, {
      expiresIn: '1d'
    });

    res.json({ token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Erro interno do servidor.' });
  }
});

// ===================
// 4. CRUD SubAdmins (somente Admin)
// ===================

// Criar SubAdmin
app.post('/api/subadmin', protect, adminOnly, async (req, res) => {
  const { name, username, email, password } = req.body;

  if (!email.endsWith('@fmabc.net')) {
    return res.status(400).json({ message: 'Somente e-mails @fmabc.net são permitidos.' });
  }

  try {
    const subAdmin = new SubAdmin({
      name,
      username,
      email,
      password,
      createdBy: req.user._id
    });

    await subAdmin.save();
    res.status(201).json(subAdmin);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Listar SubAdmins
app.get('/api/subadmin', protect, adminOnly, async (req, res) => {
  const subAdmins = await SubAdmin.find().populate('createdBy', 'username email');
  res.json(subAdmins);
});

// Atualizar SubAdmin
app.put('/api/subadmin/:id', protect, adminOnly, async (req, res) => {
  try {
    const subAdmin = await SubAdmin.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!subAdmin) return res.status(404).json({ message: 'SubAdmin não encontrado.' });
    res.json(subAdmin);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Excluir SubAdmin
app.delete('/api/subadmin/:id', protect, adminOnly, async (req, res) => {
  try {
    const subAdmin = await SubAdmin.findByIdAndDelete(req.params.id);
    if (!subAdmin) return res.status(404).json({ message: 'SubAdmin não encontrado.' });
    res.json({ message: 'SubAdmin removido com sucesso.' });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

module.exports = app

if (process.env.NODE_ENV !== 'test') {
  conectarAoMongo()
    .catch(err => console.log("Erro conexão Mongo:", err))

  const PORT = 3000
  app.listen(PORT, () => console.log(`server up & running, conexão ok`))
}


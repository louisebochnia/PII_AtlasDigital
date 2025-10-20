//Importação das bibliotecas necessárias para o backend
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const multer = require('multer');
const path = require('path');
const axios = require('axios');
const bcrypt = require('bcryptjs');

const AdminSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  password: {
    type: String,
    required: true
  }
});

// Criptografa a senha antes de salvar
AdminSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Método para verificar senha
AdminSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('Admin', AdminSchema);

//Importação dos modelos
const Imagem = require('./models/imagem');
const Informacao = require('./models/informacao');
const Topico = require('./models/topicos');

const app = express() ;
app.use(express.json());
app.use(cors());

async function conectarAoMongo() {
  await mongoose.connect(`mongodb+srv://atlas_T2Sub2_db_user:KFL0q45l6BmNdBLK@atlasdigital.qrhn0eb.mongodb.net/?retryWrites=true&w=majority&appName=AtlasDigital`)
}

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
})

// Códigos para o banco de dados
app.post('/api/images/upload', upload.single('imagem')), async (req, res) => {
  try {
    const novaImagem = new Imagem({
      nomeArquivo: req.file.filenamename,
      enderecoImagem: req.file.path,
      topico: req.body.topico,
      anotacao: req.body.anotacao
    });

    await novaImagem.save();
  } catch (error) {
    res.json({
      error: error.message
    });
  }
}

// FIM CRUD DE IMAGENS! ------------------------------------------------------------------

module.exports = app

if (process.env.NODE_ENV !== 'test') {
  conectarAoMongo()
    .catch(err => console.log("Erro conexão Mongo:", err))

  const PORT = 3000
  app.listen(PORT, () => console.log(`server up & running, conexão ok`))
}

// Criptografa a senha antes de salvar
AdminSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Método para verificar senha
AdminSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('Admin', AdminSchema);

const request = require('supertest');
const mongoose = require('mongoose');
const express = require('express');
const Topico = require('./models/topico');

// Cria um app temporário para os testes ---------------------------------------------------------------------
const app = express();
app.use(express.json());

// Simula as rotas (copiadas do backend) ---------------------------------------------------------------------
app.post('/topicos', async (req, res) => {
  try {
    const novoTopico = new Topico(req.body);
    const salvo = await novoTopico.save();
    res.status(201).json(salvo);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

app.get('/topicos', async (req, res) => {
  const topicos = await Topico.find();
  res.json(topicos);
});

// --------------------------------------------------------------------------------------------------------------

beforeAll(async () => {
  await mongoose.connect('mongodb://127.0.0.1:27017/testes_topicos', {
    useNewUrlParser: true,
    useUnifiedTopology: true
  });
});

afterAll(async () => {
  await mongoose.connection.db.dropDatabase(); // limpa o banco após o teste---------------------------------------------
  await mongoose.connection.close();
});

// ------------------------------------------------
// TESTES
// ------------------------------------------------

describe('CRUD de Tópicos', () => {

  it('Deve criar um novo tópico (POST)', async () => {
    const novo = {
      topico: 'Citologia',
      subtopicos: 'Uga, Buga',
      resumo: 'Resumo teste'
    };

    const res = await request(app).post('/topicos').send(novo);
    expect(res.statusCode).toBe(201);
    expect(res.body.topico).toBe('Matemática');
  });

  it('Deve listar os tópicos (GET)', async () => {
    const res = await request(app).get('/topicos');
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

});

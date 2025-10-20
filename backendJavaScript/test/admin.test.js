const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const Admin = require('../models/Admin');
const app = require('../app');
const request = require('supertest');
const bcrypt = require('bcryptjs');

let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const uri = mongoServer.getUri();
  await mongoose.connect(uri);
});

afterAll(async () => {
  await mongoose.connection.dropDatabase();
  await mongoose.connection.close();
  await mongoServer.stop();
});

beforeEach(async () => {
  await Admin.deleteMany();
});

describe('Modelo Admin', () => {
  it('deve criar um admin com sucesso e criptografar a senha', async () => {
    const admin = new Admin({ username: 'admin1', password: 'senha123' });
    const savedAdmin = await admin.save();

    expect(savedAdmin._id).toBeDefined();
    expect(savedAdmin.username).toBe('admin1');

    // Verifica se a senha foi criptografada
    expect(savedAdmin.password).not.toBe('senha123');
    const senhaConfere = await bcrypt.compare('senha123', savedAdmin.password);
    expect(senhaConfere).toBe(true);
  });

  it('não deve criar admin sem username ou password', async () => {
    const admin = new Admin({});

    let err;
    try {
      await admin.save();
    } catch (error) {
      err = error;
    }

    expect(err).toBeDefined();
    expect(err.name).toBe('ValidationError');
  });

  it('deve verificar corretamente o método matchPassword', async () => {
    const admin = new Admin({ username: 'admin2', password: 'segredo' });
    await admin.save();

    const isMatch = await admin.matchPassword('segredo');
    const isWrong = await admin.matchPassword('errada');

    expect(isMatch).toBe(true);
    expect(isWrong).toBe(false);
  });

  it('não deve re-hashar a senha se não for modificada', async () => {
    const admin = new Admin({ username: 'admin3', password: 'teste' });
    await admin.save();

    const senhaHashAntes = admin.password;
    admin.username = 'novoNome';
    await admin.save();

    const senhaHashDepois = admin.password;
    expect(senhaHashAntes).toBe(senhaHashDepois);
  });
});

describe('API Admin', () => {
  let idCriado;

  beforeEach(async () => {
    const res = await request(app)
      .post('/admin')
      .send({ username: 'admin_api', password: 'senha_api' });
    idCriado = res.body._id;
  });

  it('deve criar um admin via API (POST)', async () => {
    const res = await request(app)
      .post('/admin')
      .send({ username: 'novo_admin', password: '123456' });

    expect(res.statusCode).toBe(201);
    expect(res.body._id).toBeDefined();
    expect(res.body.username).toBe('novo_admin');
  });

  it('deve listar todos os admins via API (GET)', async () => {
    const res = await request(app).get('/admin');
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThan(0);
  });

  it('deve atualizar um admin via API (PUT)', async () => {
    const res = await request(app)
      .put(`/admin/${idCriado}`)
      .send({ username: 'admin_atualizado' });

    expect(res.statusCode).toBe(200);
    expect(res.body.username).toBe('admin_atualizado');
  });

  it('deve deletar um admin via API (DELETE)', async () => {
    const res = await request(app).delete(`/admin/${idCriado}`);
    expect(res.statusCode).toBe(200);

    const admin = await Admin.findById(idCriado);
    expect(admin).toBeNull();
  });
});

const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const request = require('supertest');
const fs = require('fs');

//models importados
const Imagem = require('../models/imagem');

let mongoServer;
let app;

jest.mock('multer', () => {
  const multer = jest.fn(() => ({
    single: jest.fn(() => (req, res, next) => {
      req.file = {
        filename: `test-${Date.now()}.mrxs`,
        path: 'uploads/images/test-file.mrxs',
        originalname: 'test-image.mrxs',
        mimetype: 'image/mrxs',
        size: 1024
      };

      req.body = {
        topico: 'Teste Tópico',
        anotacao: 'Descrição teste'
      };

      next();
    })
  }));

  multer.diskStorage = jest.fn(() => ({}));

  return multer;
});


beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const uri = mongoServer.getUri();

  await mongoose.connect(uri);

  app = require('../app');
});

afterAll(async () => {
  await mongoose.connection.dropDatabase();
  await mongoose.connection.close();
  await mongoServer.stop();
  
  if (fs.existsSync('uploads')) {
      fs.rmSync('uploads', { recursive: true, force: true });
  }
})

beforeEach(async () => {
  const collections = mongoose.connection.collections;
  for (const key in collections) {
      await collections[key].deleteMany();
  }
});

describe('Upload de Imagens - API', () => {
    
  it('deve salvar imagem no banco de dados', async () => {
    const res = await request(app)
      .post('/images')
      .field('topico', 'Teste Tópico')
      .field('anotacao', 'Descrição teste')
      .attach('imagem', Buffer.from('fake content'), 'test-image.mrxs');

    expect(res.status).toBe(200);
    expect(res.body.message).toBe('Imagem salva com sucesso!');

    const imagemSalva = await Imagem.findOne();

    expect(imagemSalva).not.toBeNull();
    expect(imagemSalva.nomeArquivo).toMatch(/^test-\d+\.mrxs$/);
    expect(imagemSalva.enderecoImagem).toBe('uploads/images/test-file.mrxs');
    expect(imagemSalva.topico).toBe('Teste Tópico');
    expect(imagemSalva.anotacao).toBe('Descrição teste');
  });

  it('deve remover imagem no banco de dados', async () => {
    await request(app)
      .post('/images')
      .field('topico', 'Teste Tópico')
      .field('anotacao', 'Descrição teste')
      .attach('imagem', Buffer.from('fake content'), 'test-image.mrxs');
    
    const imagemSalva = await Imagem.findOne();

    const resDel = await request(app)
      .delete(`/images/${imagemSalva._id}`);

    expect(resDel.status).toBe(200);
    expect(resDel.body.message).toContain('apagada');

    const imagemAposDelete = await Imagem.findById(imagemSalva._id);
    expect(imagemAposDelete).toBeNull();

    expect(fs.existsSync(imagemSalva.enderecoImagem)).toBe(false);
  });

  it('não deve remover uma imagem caso o id não exista', async () => {
    await request(app)
      .post('/images')
      .field('topico', 'Teste')
      .attach('imagem', Buffer.from('test'), 'test.mrxs');

    const imagemId = (await Imagem.findOne())._id;
    const countAntes = await Imagem.countDocuments();

    const resDel = await request(app)
      .delete('/images/123123-0');

    expect(resDel.status).toBe(500);
    
    const countDepois = await Imagem.countDocuments();
    expect(countDepois).toBe(countAntes);

    const imagemAindaExiste = await Imagem.findById(imagemId);
    expect(imagemAindaExiste).not.toBeNull();
  });
});
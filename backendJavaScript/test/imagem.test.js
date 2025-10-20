const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

//models importados
const Imagem = require('../models/imagem');

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
    await Imagem.deleteMany();
})

describe('Modelo Imagem', () => {
    it('deve criar uma imagem com sucesso', async () => {
        const imagemData = {
            nomeArquivo: 'test-image.mrxs',
            enderecoImagem: 'uploads/images/test-image.mrxs',
            topico: 'Tecido Epitelial',
            anotacao: 'Imagem de teste'
        };

        const imagem = new Imagem(imagemData);
        const savedImagem = await imagem.save();

        expect(savedImagem._id).toBeDefined();
        expect(savedImagem.nomeArquivo).toBe('test-image.mrxs');
        expect(savedImagem.enderecoImagem).toBe('uploads/images/test-image.mrxs');
        expect(savedImagem.topico).toBe('Tecido Epitelial');
        expect(savedImagem.anotacao).toBe('Imagem de teste'); 
    });
    

    it('não deve criar imagem sem nomeArquivo', async () => {
        const imagemData = {
        enderecoImagem: 'uploads/images/test.mrxs',
        topico: 'Teste'
        };

        const imagem = new Imagem(imagemData);
        
        let error;
        try {
        await imagem.save();
        } catch (err) {
        error = err;
        }

        expect(error).toBeDefined();
        expect(error.name).toBe('ValidationError');
    });

    it('não deve criar imagem sem enderecoImagem', async () => {
        const imagemData = {
        nomeArquivo: 'test.mrxs',
        topico: 'Teste'
        };

        const imagem = new Imagem(imagemData);
        
        let error;
        try {
        await imagem.save();
        } catch (err) {
        error = err;
        }

        expect(error).toBeDefined();
        expect(error.name).toBe('ValidationError');
    });
});


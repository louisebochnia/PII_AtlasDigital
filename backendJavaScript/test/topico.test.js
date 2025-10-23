const mongoose = require('mongoose')
const { MongoMemoryServer } = require('mongodb-memory-server')
const Topico = require('../models/topicos') // modelo Topico
const app = require('../app')
const request = require('supertest')

let mongoServer

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create()
  const uri = mongoServer.getUri()
  await mongoose.connect(uri)
})

afterAll(async () => {
  await mongoose.connection.dropDatabase()
  await mongoose.connection.close()
  await mongoServer.stop()
})

beforeEach(async () => {
  await Topico.deleteMany() // limpa a coleção antes de cada teste
})

describe('Modelo Topico', () => {
  it('deve criar um tópico com sucesso', async () => {
    const topico = new Topico({ 
      topico: 'Teste',  
      resumo: 'Resumo teste' 
    })
    const saved = await topico.save()

    expect(saved._id).toBeDefined()
    expect(saved.topico).toBe('Teste')
  })

  it('não deve criar um tópico sem campo obrigatório', async () => {
    const topico = new Topico({}) // nenhum campo

    let err
    try {
      await topico.save()
    } catch (error) {
      err = error
    }

    expect(err).toBeDefined()
    expect(err.name).toBe('ValidationError')
  })

  it('deve listar todos os tópicos', async () => {
    await Topico.create({ topico: 'Topico 1', resumo: 'Resumo 1' })
    await Topico.create({ topico: 'Topico 2', resumo: 'Resumo 2' })

    const topicos = await Topico.find({}).sort({ _id: 1 })
    expect(topicos.length).toBe(2)
    expect(topicos[0].topico).toBe('Topico 1')
    expect(topicos[1].topico).toBe('Topico 2')
  })

  it('deve deletar um tópico', async () => {
    const topico = await Topico.create({ 
      topico: 'Para deletar', 
      resumo: 'Resumo' 
    })
    await Topico.findByIdAndDelete(topico._id)

    const topicos = await Topico.find({})
    expect(topicos.length).toBe(0)
  })
})

describe('API Topico', () => {
  let idCriado

  // criar um tópico antes de cada teste de API
  beforeEach(async () => {
    const res = await request(app)
      .post('/topicos')
      .send({ topico: 'Biologia', resumo: 'Estudo da vida.' })
    idCriado = res.body._id
  })

  it('deve criar um novo tópico (POST)', async () => {
    const res = await request(app)
      .post('/topicos')
      .send({
        topico: 'Química',
        resumo: 'Estudo da matéria'
      })
    expect(res.statusCode).toBe(201)
    expect(res.body._id).toBeDefined()
  })

  it('deve listar todos os tópicos (GET)', async () => {
    const res = await request(app).get('/topicos')
    expect(res.statusCode).toBe(200)
    expect(Array.isArray(res.body)).toBe(true)
    expect(res.body.length).toBeGreaterThan(0)
  })

  it('deve atualizar um tópico (PUT)', async () => {
    const res = await request(app)
      .put(`/topicos/${idCriado}`)
      .send({ resumo: 'Resumo atualizado' })
    expect(res.statusCode).toBe(200)
    expect(res.body.resumo).toBe('Resumo atualizado')
  })

  it('deve deletar um tópico (DELETE)', async () => {
    const res = await request(app).delete(`/topicos/${idCriado}`)
    expect(res.statusCode).toBe(200)

    const topico = await Topico.findById(idCriado)
    expect(topico).toBeNull()
  })
})

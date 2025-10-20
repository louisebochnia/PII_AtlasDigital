const mongoose = require('mongoose')
const { MongoMemoryServer } = require('mongodb-memory-server')
const Informacao = require('../models/informacao')
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
  await Informacao.deleteMany() // limpa a coleção antes de cada teste
})

describe('Modelo Informacao', () => {
  it('deve criar uma informação com sucesso', async () => {
    const info = new Informacao({ informacao: 'Teste de informação' })
    const savedInfo = await info.save()

    expect(savedInfo._id).toBeDefined()
    expect(savedInfo.informacao).toBe('Teste de informação')
  })

  it('não deve criar uma informação sem o campo informacao', async () => {
    const info = new Informacao({})

    let err
    try {
      await info.save()
    } catch (error) {
      err = error
    }

    expect(err).toBeDefined()
    expect(err.name).toBe('ValidationError')
  })

  it('deve listar todas as informações', async () => {
    await Informacao.create({ informacao: 'Info 1' })
    await Informacao.create({ informacao: 'Info 2' })

    const infos = await Informacao.find({}).sort({ _id: 1 })
    expect(infos.length).toBe(2)
    expect(infos[0].informacao).toBe('Info 1')
    expect(infos[1].informacao).toBe('Info 2')
  })

  it('deve deletar uma informação', async () => {
    const info = await Informacao.create({ informacao: 'Para deletar' })
    await Informacao.findByIdAndDelete(info._id)

    const infos = await Informacao.find({})
    expect(infos.length).toBe(0)
  })
})

describe('API Informacao', () => {
  let idCriado

  // Criar uma informação antes de cada teste de API
  beforeEach(async () => {
    const res = await request(app)
      .post('/informacao')
      .send({ informacao: 'Info inicial' })
    idCriado = res.body._id
  })

  it('deve criar uma informação via API (POST)', async () => {
    const res = await request(app)
      .post('/informacao')
      .send({ informacao: 'Nova info via API' })

    expect(res.statusCode).toBe(201)
    expect(res.body._id).toBeDefined()
  })

  it('deve listar todas as informações via API (GET)', async () => {
    const res = await request(app).get('/informacao')
    expect(res.statusCode).toBe(200)
    expect(Array.isArray(res.body)).toBe(true)
    expect(res.body.length).toBeGreaterThan(0)
  })

  it('deve atualizar uma informação via API (PUT)', async () => {
    const res = await request(app)
      .put(`/informacao/${idCriado}`)
      .send({ informacao: 'Info atualizada via API' })

    expect(res.statusCode).toBe(200)
    expect(res.body.informacao).toBe('Info atualizada via API')
  })

  it('deve deletar uma informação via API (DELETE)', async () => {
    const res = await request(app).delete(`/informacao/${idCriado}`)
    expect(res.statusCode).toBe(200)

    const info = await Informacao.findById(idCriado)
    expect(info).toBeNull()
  })
})

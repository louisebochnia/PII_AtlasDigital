const mongoose = require('mongoose')
const { MongoMemoryServer } = require('mongodb-memory-server')
const Usuario = require('../models/usuario')
const app = require('../app')
const request = require('supertest')
const bcrypt = require('bcrypt')
const jwt = require('jsonwebtoken')

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
  await Usuario.deleteMany()
})

describe('Rotas de Autenticação e Usuários', () => {
  describe('POST /signup', () => {
    it('deve criar um usuário com email @fmabc.net com sucesso', async () => {
      const userData = {
        email: 'teste@fmabc.net',
        senha: 'senha123',
        cargo: 'medico'
      }

      const res = await request(app)
        .post('/signup')
        .send(userData)

      expect(res.statusCode).toBe(201)
      
      const usuario = await Usuario.findOne({ email: 'teste@fmabc.net' })
      expect(usuario).toBeDefined()
      expect(usuario.email).toBe('teste@fmabc.net')
      expect(usuario.cargo).toBe('medico')
      expect(usuario.senha).not.toBe('senha123')
    })

    it('não deve criar usuário com email que não seja @fmabc.net', async () => {
      const userData = {
        email: 'teste@gmail.com',
        senha: 'senha123',
        cargo: 'medico'
      }

      const res = await request(app)
        .post('/signup')
        .send(userData)

      expect(res.statusCode).toBe(403)
      expect(res.body.message).toBe('Apenas e-mails @fmabc.net são permitidos.')
    })

    it('deve retornar erro 409 em caso de conflito (email duplicado)', async () => {
      await Usuario.create({
        email: 'existente@fmabc.net',
        senha: await bcrypt.hash('senha123', 10),
        cargo: 'medico'
      })

      const userData = {
        email: 'existente@fmabc.net',
        senha: 'outrasenha',
        cargo: 'enfermeiro'
      }

      const res = await request(app)
        .post('/signup')
        .send(userData)

      expect(res.statusCode).toBe(409)
    })
  })

  describe('POST /login', () => {
    let usuarioId

    beforeEach(async () => {
      const senhaCriptografada = await bcrypt.hash('senha123', 10)
      const usuario = await Usuario.create({
        email: 'usuario@fmabc.net',
        senha: senhaCriptografada,
        cargo: 'medico'
      })
      usuarioId = usuario._id
    })

    it('deve fazer login com credenciais válidas', async () => {
      const loginData = {
        email: 'usuario@fmabc.net',
        senha: 'senha123'
      }

      const res = await request(app)
        .post('/login')
        .send(loginData)

      expect(res.statusCode).toBe(200)
      expect(res.body.token).toBeDefined()
      expect(res.body.cargo).toBe('medico')
      expect(res.body.id).toBe(usuarioId.toString())
      
      const decoded = jwt.verify(res.body.token, 'id-secreto')
      expect(decoded.email).toBe('usuario@fmabc.net')
      expect(decoded.exp).toBeDefined()
    })

    it('não deve fazer login com email inválido', async () => {
      const loginData = {
        email: 'inexistente@fmabc.net',
        senha: 'senha123'
      }

      const res = await request(app)
        .post('/login')
        .send(loginData)

      expect(res.statusCode).toBe(401)
      expect(res.body.mensagem).toBe('Email inválido!')
    })

    it('não deve fazer login com senha inválida', async () => {
      const loginData = {
        email: 'usuario@fmabc.net',
        senha: 'senhaerrada'
      }

      const res = await request(app)
        .post('/login')
        .send(loginData)

      expect(res.statusCode).toBe(401)
      expect(res.body.mensagem).toBe('Senha inválida!')
    })

    it('deve retornar erro para email com domínio inválido', async () => {
      const loginData = {
        email: 'usuario@gmail.com',
        senha: 'senha123'
      }

      const res = await request(app)
        .post('/login')
        .send(loginData)

      expect(res.statusCode).toBe(401)
      expect(res.body.mensagem).toBe('Email inválido!')
    })
  })

  describe('GET /usuarios', () => {
    beforeEach(async () => {
      await Usuario.create([
        {
          email: 'medico1@fmabc.net',
          senha: await bcrypt.hash('senha123', 10),
          cargo: 'medico'
        },
        {
          email: 'enfermeiro1@fmabc.net',
          senha: await bcrypt.hash('senha123', 10),
          cargo: 'enfermeiro'
        },
        {
          email: 'medico2@fmabc.net',
          senha: await bcrypt.hash('senha123', 10),
          cargo: 'medico'
        }
      ])
    })

    it('deve listar todos os usuários ordenados por cargo e email', async () => {
      const res = await request(app)
        .get('/usuarios')

      expect(res.statusCode).toBe(200)
      expect(Array.isArray(res.body)).toBe(true)
      expect(res.body.length).toBe(3)
      
      expect(res.body[0].cargo).toBe('enfermeiro')
      expect(res.body[0].email).toBe('enfermeiro1@fmabc.net')
      expect(res.body[1].cargo).toBe('medico')
      expect(res.body[1].email).toBe('medico1@fmabc.net')
      expect(res.body[2].cargo).toBe('medico')
      expect(res.body[2].email).toBe('medico2@fmabc.net')
    })

    it('deve retornar array vazio quando não há usuários', async () => {
      await Usuario.deleteMany()
      
      const res = await request(app)
        .get('/usuarios')

      expect(res.statusCode).toBe(200)
      expect(res.body).toEqual([])
    })
  })

  describe('GET /usuario/:id', () => {
    let usuarioId

    beforeEach(async () => {
      const usuario = await Usuario.create({
        email: 'teste@fmabc.net',
        senha: await bcrypt.hash('senha123', 10),
        cargo: 'medico'
      })
      usuarioId = usuario._id
    })

    it('deve retornar um usuário específico por ID', async () => {
      const res = await request(app)
        .get(`/usuario/${usuarioId}`)

      expect(res.statusCode).toBe(200)
      expect(res.body.email).toBe('teste@fmabc.net')
      expect(res.body.cargo).toBe('medico')
      expect(res.body._id).toBe(usuarioId.toString())
    })

    it('deve retornar 404 para usuário não encontrado', async () => {
      const fakeId = new mongoose.Types.ObjectId()
      
      const res = await request(app)
        .get(`/usuario/${fakeId}`)

      expect(res.statusCode).toBe(404)
      expect(res.body.message).toBe('Usuário não encontrado')
    })

    it('deve retornar 500 para ID inválido', async () => {
      const res = await request(app)
        .get('/usuario/id-invalido')

      expect(res.statusCode).toBe(500)
    })
  })

  describe('PUT /usuario/:id', () => {
    let usuarioId

    beforeEach(async () => {
      const usuario = await Usuario.create({
        email: 'original@fmabc.net',
        senha: await bcrypt.hash('senha123', 10),
        cargo: 'medico'
      })
      usuarioId = usuario._id
    })

    it('deve atualizar um usuário com sucesso', async () => {
      const updateData = {
        cargo: 'enfermeiro'
      }

      const res = await request(app)
        .put(`/usuario/${usuarioId}`)
        .send(updateData)

      expect(res.statusCode).toBe(200)
      expect(res.body.cargo).toBe('enfermeiro')
      expect(res.body.email).toBe('original@fmabc.net')
    })

    it('deve atualizar múltiplos campos com sucesso', async () => {
      const updateData = {
        cargo: 'administrador',
        email: 'novoemail@fmabc.net'
      }

      const res = await request(app)
        .put(`/usuario/${usuarioId}`)
        .send(updateData)

      expect(res.statusCode).toBe(200)
      expect(res.body.cargo).toBe('administrador')
      expect(res.body.email).toBe('novoemail@fmabc.net')
    })

    it('deve retornar erro ao tentar atualizar usuário inexistente', async () => {
      const fakeId = new mongoose.Types.ObjectId()
      const updateData = { cargo: 'enfermeiro' }

      const res = await request(app)
        .put(`/usuario/${fakeId}`)
        .send(updateData)

      expect(res.statusCode).toBe(404)
    })
  })

  describe('DELETE /usuario/:id', () => {
    let usuarioId

    beforeEach(async () => {
      const usuario = await Usuario.create({
        email: 'deletar@fmabc.net',
        senha: await bcrypt.hash('senha123', 10),
        cargo: 'medico'
      })
      usuarioId = usuario._id
    })

    it('deve deletar um usuário com sucesso', async () => {
      const res = await request(app)
        .delete(`/usuario/${usuarioId}`)

      expect(res.statusCode).toBe(200)
      expect(res.body.message).toBe('Informação removida')

      const usuario = await Usuario.findById(usuarioId)
      expect(usuario).toBeNull()
    })

    it('deve retornar erro ao tentar deletar usuário inexistente', async () => {
      const fakeId = new mongoose.Types.ObjectId()

      const res = await request(app)
        .delete(`/usuario/${fakeId}`)

      expect(res.statusCode).toBe(404)
    })

    it('não deve encontrar usuário após deleção', async () => {
      await request(app).delete(`/usuario/${usuarioId}`)
      
      const res = await request(app)
        .get(`/usuario/${usuarioId}`)

      expect(res.statusCode).toBe(404)
      expect(res.body.message).toBe('Usuário não encontrado')
    })
  })
})
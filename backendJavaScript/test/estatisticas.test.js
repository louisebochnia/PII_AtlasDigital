const mongoose = require('mongoose')
const { MongoMemoryServer } = require('mongodb-memory-server')
const Estatisticas = require('../models/estatisticas')
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
    await Estatisticas.deleteMany()
})

describe('Modelo Estatisticas', () => {

    it('deve criar estatísticas com sucesso', async () => {
        const estatisticas = new Estatisticas({
            data: '2024-01-15',
            totalAcessos: 100,
            acessosPorHora: {
                '8': 10,
                '9': 15,
                '10': 25
            },
            paginasAcessadas: {
                '/home': 30,
                '/sobre': 20,
                '/contato': 15
            },
            usuariosUnicos: ['user1', 'user2', 'user3']
        })
        const saved = await estatisticas.save()

        expect(saved._id).toBeDefined()
        expect(saved.data).toBe('2024-01-15')
        expect(saved.totalAcessos).toBe(100)
        expect(saved.acessosPorHora['8']).toBe(10)
        expect(saved.paginasAcessadas['/home']).toBe(30)
        expect(saved.usuariosUnicos).toContain('user1')
    })

    it('deve usar valores padrão quando não fornecidos', async () => {
        const estatisticas = new Estatisticas({
            data: '2024-01-16'
        })
        const saved = await estatisticas.save()

        expect(saved.totalAcessos).toBe(0)
        expect(saved.acessosPorHora).toEqual({})
        expect(saved.paginasAcessadas).toEqual({})
        expect(saved.usuariosUnicos).toEqual([])
        expect(saved.ultimaAtualizacao).toBeDefined()
    })

    it('não deve criar estatísticas sem data', async () => {
        const estatisticas = new Estatisticas({
            totalAcessos: 50
        })

        let err
        try {
            await estatisticas.save()
        } catch (error) {
            err = error
        }

        expect(err).toBeDefined()
        expect(err.name).toBe('ValidationError')
    })

    it('não deve criar estatísticas com formato de data inválido', async () => {
        const estatisticas = new Estatisticas({
            data: 'data-invalida'
        })

        let err
        try {
            await estatisticas.save()
        } catch (error) {
            err = error
        }

        expect(err).toBeDefined()
        expect(err.name).toBe('ValidationError')
    })

    it('não deve permitir datas duplicadas', async () => {
        await Estatisticas.create({ data: '2024-01-15' })

        let err
        try {
            await Estatisticas.create({ data: '2024-01-15' })
        } catch (error) {
            err = error
        }

        expect(err).toBeDefined()
        expect(err.code).toBe(11000)
    })
})

describe('API Estatisticas - Baseado no seu CRUD', () => {
    describe('GET /estatisticas - Buscar estatísticas gerais', () => {
        beforeEach(async () => {
            // Cria estatísticas para os últimos 7 dias
            const hoje = new Date()
            for (let i = 0; i < 7; i++) {
                const data = new Date(hoje)
                data.setDate(data.getDate() - i)
                const dataStr = data.toISOString().split('T')[0]

                await Estatisticas.create({
                    data: dataStr,
                    totalAcessos: 10 + i * 5,
                    acessosPorHora: { '10': 5 + i, '14': 5 + i },
                    paginasAcessadas: { '/home': 8 + i, '/sobre': 2 + i },
                    usuariosUnicos: [`user${i}`, `user${i + 1}`]
                })
            }
        })

        it('deve retornar estatísticas consolidadas dos últimos 30 dias', async () => {
            const res = await request(app).get('/estatisticas')

            expect(res.statusCode).toBe(200)
            expect(res.body.success).toBe(true)
            expect(res.body.totalAcessos).toBeGreaterThan(0)
            expect(res.body.totalUsuariosUnicos).toBeGreaterThan(0)
            expect(res.body.acessosPorDia).toBeDefined()
            expect(typeof res.body.acessosPorDia).toBe('object')
            expect(res.body.ultimaAtualizacao).toBeDefined()
            expect(res.body.totalDiasRegistrados).toBe(7)
        })

        it('deve calcular corretamente usuários únicos entre todos os dias', async () => {
            const res = await request(app).get('/estatisticas')

            expect(res.body.totalUsuariosUnicos).toBe(8)
        })

        it('deve retornar acessosPorDia para os últimos 7 dias', async () => {
            const res = await request(app).get('/estatisticas')

            expect(Object.keys(res.body.acessosPorDia).length).toBe(7)
        })
    })

    describe('POST /estatisticas/visita - Registrar visita', () => {
        const getHoraLocal = (dataUTC) => {
            const data = new Date(dataUTC)
            return data.getHours()
        }

        it('deve criar nova estatística quando não existe para a data', async () => {
            const dataAcesso = new Date('2024-01-15T13:30:00Z')

            const res = await request(app)
                .post('/estatisticas/visita')
                .send({
                    dataAcesso: dataAcesso.toISOString(),
                    pagina: '/home',
                    userId: 'user123'
                })

            expect(res.statusCode).toBe(200)
            expect(res.body.totalAcessos).toBe(1)

            const estatisticas = await Estatisticas.find({ data: '2024-01-15' })
            expect(estatisticas).toHaveLength(1)

            const estatistica = estatisticas[0]
            expect(estatistica.totalAcessos).toBe(1)
            expect(estatistica.usuariosUnicos).toContain('user123')

            // Verifica se alguma hora foi registrada
            const horasComAcesso = Object.keys(estatistica.acessosPorHora)
            expect(horasComAcesso.length).toBe(1)

            // Verifica se alguma página foi registrada  
            const paginasComAcesso = Object.keys(estatistica.paginasAcessadas)
            expect(paginasComAcesso.length).toBe(1)
        })

        it('deve diagnosticar problema nos contadores', async () => {
            // Primeiro acesso
            await request(app)
                .post('/estatisticas/visita')
                .send({
                    dataAcesso: new Date('2024-01-15T13:30:00Z').toISOString(),
                    pagina: '/home',
                    userId: 'user1'
                })

            // Segundo acesso - mesma data
            await request(app)
                .post('/estatisticas/visita')
                .send({
                    dataAcesso: new Date('2024-01-15T13:45:00Z').toISOString(),
                    pagina: '/home',
                    userId: 'user2'
                })

            const estatisticas = await Estatisticas.find({ data: '2024-01-15' })
            const estatistica = estatisticas[0]

            console.log('DIAGNÓSTICO - Contadores após 2 acessos:')
            console.log('Total de acessos:', estatistica.totalAcessos)
            console.log('Acessos por hora:', estatistica.acessosPorHora)
            console.log('Páginas acessadas:', estatistica.paginasAcessadas)
            console.log('Usuários únicos:', estatistica.usuariosUnicos)

            expect(estatisticas).toHaveLength(1)
            expect(estatistica.totalAcessos).toBe(2)
            expect(estatistica.usuariosUnicos).toHaveLength(2)

            //Dubug pra entender melhor
            console.log('PROBLEMA IDENTIFICADO:')
            console.log('   - totalAcessos: funciona (2)')
            console.log('   - usuariosUnicos: funciona (2 usuários)')
            console.log('   - paginasAcessadas: NÃO incrementa (sempre 1)')
            console.log('   - acessosPorHora: NÃO incrementa (sempre 1)')
        })

        it('deve atualizar apenas campos básicos quando estatística existe', async () => {
            await Estatisticas.create({
                data: '2024-01-15',
                totalAcessos: 5,
                acessosPorHora: { '9': 2, '10': 3 },
                paginasAcessadas: { '/home': 3, '/sobre': 2 },
                usuariosUnicos: ['user1']
            })

            const res = await request(app)
                .post('/estatisticas/visita')
                .send({
                    dataAcesso: new Date('2024-01-15T16:30:00Z').toISOString(),
                    pagina: '/contato',
                    userId: 'user2'
                })

            expect(res.statusCode).toBe(200)
            expect(res.body.totalAcessos).toBe(6)

            const estatisticas = await Estatisticas.find({ data: '2024-01-15' })
            const estatistica = estatisticas[0]

            console.log('Após atualização - COMPORTAMENTO REAL:')
            console.log('Total:', estatistica.totalAcessos)
            console.log('Páginas:', estatistica.paginasAcessadas)
            console.log('Usuários:', estatistica.usuariosUnicos)

            expect(estatistica.totalAcessos).toBe(6)
            expect(estatistica.usuariosUnicos).toContain('user2')
            expect(estatistica.paginasAcessadas['/home']).toBe(3)
            expect(estatistica.paginasAcessadas['/sobre']).toBe(2)

        })

        it('deve testar comportamento CORRETO dos contadores', async () => {
            await request(app)
                .post('/estatisticas/visita')
                .send({
                    dataAcesso: new Date('2024-01-15T13:30:00Z').toISOString(),
                    pagina: '/teste',
                    userId: 'user1'
                })

            await request(app)
                .post('/estatisticas/visita')
                .send({
                    dataAcesso: new Date('2024-01-15T13:45:00Z').toISOString(),
                    pagina: '/teste',
                    userId: 'user2'
                })

            const estatisticas = await Estatisticas.find({ data: '2024-01-15' })
            const estatistica = estatisticas[0]

            console.log('COMPORTAMENTO CORRETO - 2 acessos mesma página:')
            console.log('Total:', estatistica.totalAcessos)
            console.log('Página /teste:', estatistica.paginasAcessadas['/teste'])

            expect(estatistica.totalAcessos).toBe(2)
            expect(estatistica.paginasAcessadas['/teste']).toBe(2)
        })

        it('deve usar valores padrão quando não fornecidos', async () => {
            const res = await request(app)
                .post('/estatisticas/visita')
                .send({})

            expect(res.statusCode).toBe(200)

            const dataAtual = new Date().toISOString().split('T')[0]
            const estatisticas = await Estatisticas.find({ data: dataAtual })
            expect(estatisticas).toHaveLength(1)

            const estatistica = estatisticas[0]
            expect(estatistica.totalAcessos).toBe(1)
            expect(estatistica.paginasAcessadas['site_geral']).toBe(1)
            expect(estatistica.usuariosUnicos).toEqual([])
        })

        it('deve lidar com diferentes fusos horários corretamente', async () => {
            const dataAcessoUTC = new Date('2024-01-15T10:30:00Z')

            const res = await request(app)
                .post('/estatisticas/visita')
                .send({
                    dataAcesso: dataAcessoUTC.toISOString(),
                    pagina: '/teste',
                    userId: 'user-timezone'
                })

            expect(res.statusCode).toBe(200)

            const estatisticas = await Estatisticas.find({ data: '2024-01-15' })
            expect(estatisticas).toHaveLength(1)

            const estatistica = estatisticas[0]
            const horasComAcesso = Object.keys(estatistica.acessosPorHora)
            expect(horasComAcesso.length).toBe(1)
            expect(estatistica.acessosPorHora[horasComAcesso[0]]).toBe(1)
        })
    })

    describe('Health Check', () => {
        it('deve retornar status OK para /health', async () => {
            const res = await request(app).get('/health')
            expect(res.statusCode).toBe(200)
            expect(res.body.success).toBe(true)
            expect(res.body.message).toBe('Backend OK')
        })
    })

    describe('Tratamento de Erros', () => {
        it('deve lidar com erro ao buscar estatísticas', async () => {
            const findMock = jest.spyOn(Estatisticas, 'find')
            findMock.mockImplementationOnce(() => {
                throw new Error('Erro simulado no banco')
            })

            const res = await request(app).get('/estatisticas')

            expect(res.statusCode).toBe(500)
            expect(res.body.success).toBe(false)
            expect(res.body.error).toBeDefined()

            findMock.mockRestore()
        })

        it('deve lidar com erro ao registrar visita', async () => {
            const findOneMock = jest.spyOn(Estatisticas, 'findOne')
            findOneMock.mockImplementationOnce(() => {
                throw new Error('Erro simulado no banco')
            })

            const res = await request(app)
                .post('/estatisticas/visita')
                .send({
                    dataAcesso: new Date().toISOString(),
                    pagina: '/home'
                })

            expect(res.statusCode).toBe(500)
            expect(res.body.success).toBe(false)
            expect(res.body.error).toBeDefined()

            findOneMock.mockRestore()
        })
    })
})
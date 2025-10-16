const express = require('express')
const cors = require('cors')
const mongoose = require('mongoose')

const app = express() //construindo uma aplicação express
app.use(express.json())
app.use(cors())

async function conectarAoMongo() {
    await mongoose.connect(`mongodb+srv://atlas_T2Sub2_db_user:KFL0q45l6BmNdBLK@atlasdigital.qrhn0eb.mongodb.net/`);
}

app.listen(3000, () => {
    try {
        conectarAoMongo()
        console.log("server up & running, conexão ok")
    }
    catch (e) {
        console.log('erro de conexão', e)
    }
})
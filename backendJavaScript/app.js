const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const multer = require('multer');
const path = require('path');
const axios = require('axios');

const app = express() //construindo uma aplicação express
app.use(express.json())
app.use(cors())

async function conectarAoMongo() {
    await mongoose.connect(`mongodb+srv://atlas_T2Sub2_db_user:<db_password>@atlasdigital.qrhn0eb.mongodb.net/?retryWrites=true&w=majority&appName=AtlasDigital`);
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

// CRUD Imagens

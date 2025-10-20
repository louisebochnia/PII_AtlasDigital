const mongoose = require('mongoose');

const UsuarioSchema = new mongoose.Schema({
    nome: { 
        type: String, 
        required: true 
    },
    email: {
        type: String, 
        required: true
    },
    senha: {
        type: String, 
        required: true
    },
    cargo: {
        type: String,
        required: true
    }
});
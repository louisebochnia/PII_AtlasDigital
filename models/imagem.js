const mongoose = require('mongoose');

const ImagemSchema = new mongoose.Schema({
    enderecoImagem: { 
        type: String, 
        required: true 
    },
    descricao: {
        type: String, 
        required: true
    }
});
const mongoose = require('mongoose');

const ImagemSchema = new mongoose.Schema({
    enderecoImagem: { 
        type: String, 
        required: true 
    },
    topico: {
        type: String, 
        required: true
    },
    anotacao: {
        type: String, 
        required: true
    },
    links: {
        type: Array,
        required: true
    }
});
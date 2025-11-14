const mongoose = require('mongoose');

const ImagemSchema = new mongoose.Schema({
    nomeArquivo: {
        type: String,
        required: true
    },
    nomeImagem: {
        type: String,
        required: true
    },
    enderecoPastaMrxs:{
        type: String,
        required: true
    },
    enderecoThumbnail: {
        type: String,
        required: true
    },
    enderecoTiles: {
        type: String,
        required: true
    },
    topico: {
        type: String, 
        required: true
    },
    subtopico: {
        type: String,
        required: true
    },
    anotacao: {
        type: String, 
        required: true
    },
    hiperlinks: [
        {
        palavra: String,
        link: String
        }
    ]
});

module.exports = mongoose.model('Imagem', ImagemSchema);
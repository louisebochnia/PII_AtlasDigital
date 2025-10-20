const mongoose = require('mongoose');

const ImagemSchema = new mongoose.Schema({
    nomeArquivo: {
        type: String,
        required: true
    },
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
    uploadDate: { 
        type: Date, 
        default: Date.now },
    hiperlinks: [
        {
        palavra: String,
        link: String
        }
    ]
});

module.exports = mongoose.model('Imagem', ImagemSchema);
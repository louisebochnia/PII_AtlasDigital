const mongoose = require('mongoose');

const informacaoSchema = new mongoose.Schema({
    informacao: { 
        type: String, 
        required: true 
    }
});

module.exports = mongoose.model('Informacao', informacaoSchema);
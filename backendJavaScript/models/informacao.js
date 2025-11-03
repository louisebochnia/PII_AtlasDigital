const mongoose = require('mongoose');

const InformacaoSchema = new mongoose.Schema({
  indice: { 
    type: Number, 
    required: true 
  },
  informacao: {  // Campo deve se chamar "informacao"
    type: String, 
    required: true 
  }
}, { _id: true }); // permitir que MongoDB gere _id automático

module.exports = mongoose.model('Informacao', InformacaoSchema);
// subtopicos.js
const mongoose = require('mongoose');
const InformacaoSchema = require('./informacao').schema; 

const SubtopicoSchema = new mongoose.Schema({
  indice: { 
    type: Number, required: true 
  },

  titulo: { 
    type: String, required: true 
  },

  capaUrl: { 
    type: String, default: null 
  },
  
  informacoes: [InformacaoSchema] 
}, { timestamps: true });

module.exports = mongoose.model('Subtopico', SubtopicoSchema);



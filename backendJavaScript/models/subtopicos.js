// subtopico.js
const mongoose = require('mongoose');
const InformacaoSchema = require('./informacao').schema; 

const SubtopicoSchema = new mongoose.Schema({
  indice: { 
    type: Number, 
    required: true
  },
  titulo: { 
    type: String, 
    required: true 
  },
  // capaUrl: { 
  //   type: String 
  // },
  topicoId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Topico', 
    required: true 
  },
  informacoes: [InformacaoSchema] // Array de informações
}, { timestamps: true });

module.exports = mongoose.model('Subtopico', SubtopicoSchema);



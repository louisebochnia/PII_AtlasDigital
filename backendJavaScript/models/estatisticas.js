const mongoose = require('mongoose');

const estatisticasSchema = new mongoose.Schema({
  data: {
    type: String,
    required: true,
    unique: true,
    match: /^\d{4}-\d{2}-\d{2}$/
  },
  totalAcessos: {
    type: Number,
    required: true,
    default: 0
  },
  acessosPorHora: {
    type: Object, 
    default: {}
  },
  paginasAcessadas: {
    type: Object,  
    default: {}
  },
  usuariosUnicos: {
    type: [String],
    default: []
  },
  ultimaAtualizacao: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Estatisticas', estatisticasSchema);
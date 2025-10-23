const mongoose = require('mongoose');

const CapituloSchema = new mongoose.Schema({
  indice: {
    type: Number,
    required: true
  },
  titulo: {
    type: String,
    required: true
  },
  capaUrl: {
    type: String,
    default: null
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Capitulo', CapituloSchema);


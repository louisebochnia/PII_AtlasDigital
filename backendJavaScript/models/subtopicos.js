const mongoose = require('mongoose');

const SubTopicoSchema = new mongoose.Schema({
  nome: {
    type: String,
    required: true
  }
});

module.exports = mongoose.model('SubTopico', SubTopicoSchema);

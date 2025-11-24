const mongoose = require('mongoose');

const HyperlinkSchema = new mongoose.Schema({
  link: { 
    type: String, 
    required: true
  },
    nome: { 
    type: String, 
    required: true
  }
}, {timestamps: true, _id: true });

module.exports = mongoose.model('hyperlink', HyperlinkSchema);
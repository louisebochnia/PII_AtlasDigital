const mongoose = require('mongoose');

const HyperlinkSchema = new mongoose.Schema({
  link: { 
    type: String, 
    required: true,
    match : /^https?:\/\/.+/ 
  },
    nome: { 
    type: String, 
    required: true,
    enum : ['linkedin','instagram','facebook','youtube','quiz'] 
  }
}, {timestamps: true, _id: true });

module.exports = mongoose.model('hyperlink', HyperlinkSchema);
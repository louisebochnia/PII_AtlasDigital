const mongoose = require('mongoose');

const TopicosSchema = new mongoose.Schema({
  topico: { 
    type: String, 
    required: true 
  },
  
  resumo: {
    type: String, 
    required: true
  },

  //agora são apenas referências (ObjectIds)
  subtopicos: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Subtopico'
    }
  ]
});

module.exports = mongoose.model('Topico', TopicosSchema);

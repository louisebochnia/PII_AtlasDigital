const mongoose = require('mongoose');
const CapituloSchema = require('./subtopicos').schema;

const TopicosSchema = new mongoose.Schema({
    topico: { 
        type: String, 
        required: true 
    },
    
    resumo: {
        type: String, 
        required: true
    },

    subtopicos: [CapituloSchema]
});

module.exports = mongoose.model('Topico', TopicosSchema);
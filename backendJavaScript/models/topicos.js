const mongoose = require('mongoose');

const TopicosSchema = new mongoose.Schema({
    topico: { 
        type: String, 
        required: true 
    },
    
    resumo: {
        type: String, 
        required: true
    }
});

module.exports = mongoose.model('Topico', TopicosSchema);
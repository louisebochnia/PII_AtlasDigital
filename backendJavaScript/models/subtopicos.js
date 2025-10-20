const mongoose = require('mongoose');

const SubTopicosSchema = new mongoose.Schema({

    subtopicos: {
        type: String, 
        required: true
    }
    
});

module.exports = mongoose.model('Topico', SubTopicosSchema);
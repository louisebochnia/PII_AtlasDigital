const mongoose = require('mongoose');

const TopicosSchema = new mongoose.Schema({
    topico: { 
        type: String, 
        required: true 
    },
    subtopicos: {
        type: String, 
        required: true
    },
    resumo: {
        type: String, 
        required: true
    }
});
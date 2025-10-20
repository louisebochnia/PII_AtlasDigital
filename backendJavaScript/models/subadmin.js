// models/SubAdmin.js
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const SubAdminSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true, // <-- garante que não haja e-mails repetidos
    trim: true,
    lowercase: true, // normaliza o e-mail
    match: [/.+\@.+\..+/, 'Por favor, insira um e-mail válido'] // validação básica
  },
  password: {
    type: String,
    required: true
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Admin',
    required: true
  }
});

// Criptografa a senha antes de salvar
SubAdminSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

SubAdminSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('SubAdmin', SubAdminSchema);

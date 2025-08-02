const mongoose = require('mongoose');

const mongoURI = 'mongodb://localhost:27017/torneo_express'; // Cambia según tu configuración

mongoose.connect(mongoURI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('Conexión a MongoDB exitosa');
})
.catch((error) => {
  console.error('Error conectando a MongoDB:', error);
});

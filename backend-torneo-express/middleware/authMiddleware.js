function authMiddleware(req, res, next) {
  console.log("Auth middleware ejecutado");

  next(); 
}

module.exports = authMiddleware;

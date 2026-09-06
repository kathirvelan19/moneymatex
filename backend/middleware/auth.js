const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'monematex_secure_jwt_secret_key_2026_xyz';

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Authentication token is required.' });
  }

  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token.' });
    }
    req.userId = decoded.userId;
    req.userEmail = decoded.email;
    next();
  });
}

module.exports = {
  authenticateToken,
  JWT_SECRET,
};

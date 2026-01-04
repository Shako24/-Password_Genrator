function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization']; // Get header
  const token = authHeader && authHeader.split(' ')[1]; // Remove "Bearer"
  
  if (!token) return res.status(401).json({ error: 'Token missing' });

  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ error: 'Token invalid' });
    
    // decoded is the payload you set when signing the token
    // Example: { user_id: 5, iat: 1710243848, exp: 1710247448 }
    req.user_id = decoded.user_id; 

    next(); // Move to the next route handler
  });
}

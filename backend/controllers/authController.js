import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import pool from '../db/connection.js';

const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';

export const register = async (req, res) => {
  const { username, password, public_key } = req.body;
  console.log(req.body);
  try {
    const hashed = await bcrypt.hash(password, 10);
    
    const now = new Date(); // current time
    const TWO_MONTHS = 60 * 24 * 60 * 60 * 1000; //  60 days
    const futureTimestamp = new Date(now.getTime() + TWO_MONTHS);

    console.log("username: ", username);
    console.log("publicKey: ", public_key);

    // Save User Public Key For Secure Password Storage
    const rsa_key_result = await pool.query(
      'INSERT INTO RSA_KEY(public_key, key_version, created_at, expires_at) VALUES ($1,$2,$3,$4) RETURNING id',
      [public_key, '1', now, futureTimestamp]
    );

    const rsa_key_id = rsa_key_result.rows[0].id;
    console.log('Key inserted: ', rsa_key_id);

    // Add User in DB
    const result = await pool.query(
      'INSERT INTO users (username, password, rsa_key_id) VALUES ($1, $2, $3) RETURNING id, username',
      [username, hashed, rsa_key_id]
    );
    const token = jwt.sign({ id: result.rows[0].id }, JWT_SECRET, { expiresIn: '1h' });
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.log(err)
    res.status(400).json({ error: 'User already exists or invalid input' });
  }
};

export const login = async (req, res) => {
  const { username, password } = req.body;
  try {
    const result = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
    const user = result.rows[0];

    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({ error: 'Invalid username or password' });
    }

    const token = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '1h' });
    res.json({ token });
  } catch (err) {
    res.status(500).json({ error: 'Login failed' });
  }
};

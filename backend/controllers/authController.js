import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import pool from '../db/connection.js';
import generate_rsa_keys from '../utils/rsa_encryption.js';

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) throw new Error('JWT_SECRET environment variable is required');

if (!process.env.RSA_PUBLIC_KEY || !process.env.RSA_PRIVATE_KEY) {
  generate_rsa_keys();
}

export const register = async (req, res) => {
  const { username, password, public_key } = req.body;
  try {
    const hashed = await bcrypt.hash(password, 10);

    const now = new Date();
    const TWO_MONTHS = 60 * 24 * 60 * 60 * 1000;
    const futureTimestamp = new Date(now.getTime() + TWO_MONTHS);

    const rsa_key_result = await pool.query(
      'INSERT INTO rsa_key(public_key, key_version, created_at, expires_at) VALUES ($1,$2,$3,$4) RETURNING id',
      [public_key, '1', now, futureTimestamp]
    );
    const rsa_key_id = rsa_key_result.rows[0].id;

    const result = await pool.query(
      'INSERT INTO users (username, password, rsa_key_id) VALUES ($1, $2, $3) RETURNING id',
      [username, hashed, rsa_key_id]
    );
    if (!result.rows[0]) throw new Error('User not found');

    const token = jwt.sign({ id: result.rows[0].id }, JWT_SECRET, { expiresIn: '1h' });
    res.status(201).json({ success: true, data: { token } });
  } catch (err) {
    console.error('Register error:', err.message);
    res.status(400).json({ success: false, error: 'User already exists or invalid input' });
  }
};

export const login = async (req, res) => {
  const { username, password } = req.body;
  try {
    const result = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
    const user = result.rows[0];

    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({ success: false, error: 'Invalid username or password' });
    }

    const token = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '1h' });

    // Read from process.env so auto-generated keys are picked up
    const server_public_key = Buffer.from(process.env.RSA_PUBLIC_KEY, 'base64').toString('utf8');

    res.json({ success: true, data: { token, server_public_key } });
  } catch (err) {
    console.error('Login error:', err.message);
    res.status(500).json({ success: false, error: 'Login failed' });
  }
};

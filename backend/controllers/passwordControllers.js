import { generate_password } from '../utils/password_generator.js';
import { DuplicateEntry, WrongPassword } from '../api/error.js';
import { aes_encrypt } from '../utils/aes_encryption.js';
import { rsa_decrypt } from '../utils/rsa_encryption.js';
import pool from '../db/connection.js';

async function get_user_public_key(user_id) {
  const result = await pool.query(
    `SELECT r.public_key FROM rsa_key r
     JOIN users u ON u.rsa_key_id = r.id
     WHERE u.id = $1 AND r.expires_at > NOW()`,
    [user_id]
  );
  return result.rows[0]?.public_key || null;
}

export const generate_password_controller = async (req, resp) => {
  try {
    const password = await generate_password(req.body.password_length);
    resp.json({ success: true, data: { password } });
  } catch (error) {
    if (error instanceof WrongPassword || error instanceof DuplicateEntry) {
      resp.status(404).json({ success: false, error: error.message });
    } else {
      console.error('generate_password error:', error.message);
      resp.status(500).json({ success: false, error: 'Internal Server Error' });
    }
  }
};

export const save_password_controller = async (req, resp) => {
  const { site_name, username, password: encryptedPassword } = req.body;
  const user_id = req.user_id; // always from verified token, never from body

  try {
    // 1. Decrypt incoming RSA-encrypted password with server private key
    const plaintext = rsa_decrypt(encryptedPassword);

    // 2. Get client's RSA public key from DB
    const public_key = await get_user_public_key(user_id);
    if (!public_key) {
      return resp.status(400).json({ success: false, error: 'User public key not found or expired' });
    }

    // 3. AES-encrypt plaintext, encrypt AES key with client public key
    const { encrypted_password, encrypted_key } = await aes_encrypt(plaintext, public_key);

    // 4. Insert into aes_password, get id
    const aesResult = await pool.query(
      'INSERT INTO aes_password (cipher_text, encrypted_key) VALUES ($1, $2) RETURNING id',
      [encrypted_password, encrypted_key]
    );
    const password_id = aesResult.rows[0].id;

    // 5. Insert into password_store
    const sql = 'INSERT INTO password_store (site, user_name, password_id, user_id) VALUES ($1, $2, $3, $4)';
    await pool.query(sql, [site_name, username, password_id, user_id]);

    resp.status(201).json({ success: true, data: { site_name, username } });
  } catch (error) {
    console.error('save_password error:', error.message);
    resp.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

export const update_password_controller = async (req, resp) => {
  const { site, username, password: encryptedPassword } = req.body;
  const user_id = req.user_id;

  try {
    // 1. Find the existing password_store row (scoped to this user to prevent IDOR)
    const storeResult = await pool.query(
      'SELECT password_id FROM password_store WHERE site = $1 AND user_name = $2 AND user_id = $3',
      [site, username, user_id]
    );
    if (!storeResult.rows.length) {
      return resp.status(404).json({ success: false, error: 'Password entry not found' });
    }
    const password_id = storeResult.rows[0].password_id;

    // 2. Decrypt incoming RSA-encrypted password with server private key
    const plaintext = rsa_decrypt(encryptedPassword);

    // 3. Get client's RSA public key from DB
    const public_key = await get_user_public_key(user_id);
    if (!public_key) {
      return resp.status(400).json({ success: false, error: 'User public key not found or expired' });
    }

    // 4. AES-encrypt new plaintext
    const { encrypted_password, encrypted_key } = await aes_encrypt(plaintext, public_key);

    // 5. Update aes_password row in place
    await pool.query(
      'UPDATE aes_password SET cipher_text = $1, encrypted_key = $2 WHERE id = $3',
      [encrypted_password, encrypted_key, password_id]
    );

    resp.json({ success: true, data: { site, username } });
  } catch (error) {
    console.error('update_password error:', error.message);
    resp.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

export const show_password_controller = async (req, resp) => {
  const { site } = req.body;
  const user_id = req.user_id;

  try {
    const result = await pool.query(
      `SELECT ps.user_name AS "userName", ap.cipher_text, ap.encrypted_key
       FROM password_store ps
       JOIN aes_password ap ON ap.id = ps.password_id
       WHERE ps.site = $1 AND ps.user_id = $2`,
      [site, user_id]
    );
    resp.json({ success: true, data: result.rows });
  } catch (error) {
    console.error('show_password error:', error.message);
    resp.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

export const show_sites_controller = async (req, resp) => {
  const user_id = req.user_id;

  try {
    const result = await pool.query(
      'SELECT DISTINCT site FROM password_store WHERE user_id = $1 ORDER BY site',
      [user_id]
    );
    resp.json({ success: true, data: result.rows });
  } catch (error) {
    console.error('show_sites error:', error.message);
    resp.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};

export const show_selected_sites_controller = async (req, resp) => {
  const { sites } = req.body; // array of site names
  const user_id = req.user_id;

  try {
    const result = await pool.query(
      `SELECT ps.site, ps.user_name AS "userName", ap.cipher_text, ap.encrypted_key
       FROM password_store ps
       JOIN aes_password ap ON ap.id = ps.password_id
       WHERE ps.site = ANY($1) AND ps.user_id = $2`,
      [sites, user_id]
    );
    resp.json({ success: true, data: result.rows });
  } catch (error) {
    console.error('show_selected_sites error:', error.message);
    resp.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};
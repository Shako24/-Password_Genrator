import crypto from 'crypto';
import { rsa_encrypt } from './rsa_encryption.js';

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 12;

export async function aes_encrypt(text, publicKey) {
  const iv = crypto.randomBytes(IV_LENGTH);
  const key = crypto.randomBytes(32);

  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
  const encryptedBuffer = Buffer.concat([cipher.update(text, 'utf8'), cipher.final()]);
  const authTag = cipher.getAuthTag();

  // Format: base64(iv):base64(ciphertext+authTag)
  const ivB64 = iv.toString('base64');
  const combined = Buffer.concat([encryptedBuffer, authTag]).toString('base64');
  const encrypted_password = `${ivB64}:${combined}`;

  const encrypted_key = rsa_encrypt(key, publicKey);

  return {
    encrypted_password,
    encrypted_key: Buffer.from(encrypted_key, 'binary').toString('base64'),
  };
}

export function aes_decrypt(encrypted_password, key) {
  const [ivB64, combinedB64] = encrypted_password.split(':');
  const iv = Buffer.from(ivB64, 'base64');
  const combined = Buffer.from(combinedB64, 'base64');

  const authTag = combined.slice(combined.length - 16);
  const ciphertext = combined.slice(0, combined.length - 16);

  const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
  decipher.setAuthTag(authTag);

  let decrypted = decipher.update(ciphertext, null, 'utf8');
  decrypted += decipher.final('utf8');

  return decrypted;
}

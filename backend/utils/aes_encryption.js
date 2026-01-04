import express from 'express';
import { crypto } from 'crypto';
import { json } from 'body-parser';
import { rsa_encrpyt } from rsa_encrpyt.js;
const app = express();
app.use(json());

const ALGORITHM = 'aes-256-gcm';
const KEY_LENGTH = 32;
const IV_LENGTH = 12; // GCM recommends 12-byte IVs
const SALT_LENGTH = 16;
const ITERATIONS = 100000;
const DIGEST = 'sha256';



// 🔐 Derive key using password and salt
/*
function deriveKey(password, salt) {
    return pbkdf2Sync(password, salt, ITERATIONS, KEY_LENGTH, DIGEST);
}
*/

// 🔒 AES-GCM Encryption Endpoint
async function aes_encrypt(text, publicKey) {
    // const { text, publicKey } = req.body;

    // const salt = crypto.randomBytes(SALT_LENGTH);
    const iv = crypto.randomBytes(IV_LENGTH);
    // const key = deriveKey(password, salt);
    const key = crypto.randomBytes(32); 

    const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
    const encryptedBuffer = Buffer.concat([cipher.update(text, 'utf8'), cipher.final()]);
    const authTag = cipher.getAuthTag();

    // Combine encrypted + authTag

    const combined = Buffer.concat([encryptedBuffer, authTag]);
    const combinedB64 = combined.toString('base64');
    const ivB64 = iv.toString('base64');

    const final = Buffer.concat([combinedB64,":",ivB64]);

    // Encrpyt Key with RSA public key
    const key_encrypted = rsa_encrpyt(key, publicKey);
     
    const result = {
        encrypted: final.toString('base64'),
        key: key_encrypted.toString('base64')
    };

    return result;
}

// 🔓 AES-GCM Decryption Endpoint
function aes_decrypt(encrypted, password, salt) {
    // const { encrypted, password, salt, iv } = req.body;
    const key = deriveKey(password, Buffer.from(salt, 'base64'));

    const data = Buffer.from(encrypted, 'base64');
    const iv = data.slice(0,12);
    const authTag = data.slice(data.length - 16);
    const ciphertext = data.slice(0, data.length - 16);

    const decipher = crypto.createDecipheriv(ALGORITHM, key, Buffer.from(iv, 'base64'));
    decipher.setAuthTag(authTag);

    let decrypted = decipher.update(ciphertext, null, 'utf8');
    decrypted += decipher.final('utf8');

    return decrypted;
    // res.json({ decrypted });
}

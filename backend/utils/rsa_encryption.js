import fs from 'fs';
import pkg from 'node-forge';
const { pki, util } = pkg;

const RSA_PRIVATE_KEY_B64 = process.env.RSA_PRIVATE_KEY;
if (!RSA_PRIVATE_KEY_B64) throw new Error('RSA_PRIVATE_KEY environment variable is required');

export function rsa_encrypt(text, publicKey) {
  const pubKey = pki.publicKeyFromPem(publicKey);
  const encrypted = pubKey.encrypt(
    typeof text === 'string' ? text : util.createBuffer(text).data,
    'RSA-OAEP'
  );
  return encrypted;
}

export function rsa_decrypt(text) {
  const privateKeyPem = Buffer.from(RSA_PRIVATE_KEY_B64, 'base64').toString('utf8');
  const privKey = pki.privateKeyFromPem(privateKeyPem);
  const decrypted = privKey.decrypt(util.decode64(text), 'RSA-OAEP');
  return decrypted;
}

export default function generate_rsa_keys() {
  const rsaKeypair = pki.rsa.generateKeyPair(2048);
  const publicKeyPem = pki.publicKeyToPem(rsaKeypair.publicKey);
  const privateKeyPem = pki.privateKeyToPem(rsaKeypair.privateKey);

  const privateBase64 = Buffer.from(privateKeyPem).toString('base64');
  const publicBase64 = Buffer.from(publicKeyPem).toString('base64');

  let env = fs.readFileSync('.env', 'utf8');
  env = env.replace(/RSA_PRIVATE_KEY=.*/g, `RSA_PRIVATE_KEY="${privateBase64}"`);
  env = env.replace(/RSA_PUBLIC_KEY=.*/g, `RSA_PUBLIC_KEY="${publicBase64}"`);
  fs.writeFileSync('.env', env);
}

import fs from 'fs';
import pkg from 'node-forge';
const { pki, util } = pkg;

export default function generate_rsa_keys() {
  console.log('RSA keys not found — generating new 2048-bit keypair...');
  const rsaKeypair = pki.rsa.generateKeyPair(2048);
  const publicKeyPem = pki.publicKeyToPem(rsaKeypair.publicKey);
  const privateKeyPem = pki.privateKeyToPem(rsaKeypair.privateKey);

  const privateBase64 = Buffer.from(privateKeyPem).toString('base64');
  const publicBase64 = Buffer.from(publicKeyPem).toString('base64');

  // Make available to the current process immediately
  process.env.RSA_PRIVATE_KEY = privateBase64;
  process.env.RSA_PUBLIC_KEY = publicBase64;

  // Persist to .env for future restarts
  if (fs.existsSync('.env')) {
    let env = fs.readFileSync('.env', 'utf8');
    env = env.includes('RSA_PRIVATE_KEY=')
      ? env.replace(/RSA_PRIVATE_KEY=.*/g, `RSA_PRIVATE_KEY="${privateBase64}"`)
      : env + `\nRSA_PRIVATE_KEY="${privateBase64}"`;
    env = env.includes('RSA_PUBLIC_KEY=')
      ? env.replace(/RSA_PUBLIC_KEY=.*/g, `RSA_PUBLIC_KEY="${publicBase64}"`)
      : env + `\nRSA_PUBLIC_KEY="${publicBase64}"`;
    fs.writeFileSync('.env', env);
    console.log('RSA keys saved to .env');
  }
}

export function rsa_encrypt(text, publicKey) {
  const pubKey = pki.publicKeyFromPem(publicKey);
  const encrypted = pubKey.encrypt(
    typeof text === 'string' ? text : util.createBuffer(text).data,
    'RSA-OAEP'
  );
  return encrypted;
}

export function rsa_decrypt(text) {
  // Read from process.env each call so generate_rsa_keys() takes effect without restart
  const b64 = process.env.RSA_PRIVATE_KEY;
  if (!b64) throw new Error('RSA_PRIVATE_KEY not set — call generate_rsa_keys() first');
  const privateKeyPem = Buffer.from(b64, 'base64').toString('utf8');
  const privKey = pki.privateKeyFromPem(privateKeyPem);
  return privKey.decrypt(util.decode64(text), 'RSA-OAEP');
}

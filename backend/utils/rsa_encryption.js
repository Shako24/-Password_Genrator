import crypto from 'crypto';
import pkg from 'node-forge';
const { pki } = pkg;
import bodyParser from 'body-parser';


/////////////////////////////////////////////
// Client Side RSA Encryption
/////////////////////////////////////////////
export function rsa_encrypt(text, publicKey) {
    
    const pubKey = forge.pki.publicKeyFromPem(publicKey);
    const encrypted = pubKey.encrypt(text, 'RSA-OAEP');

    return encrypted;
}


/////////////////////////////////////////////
// Server Side RSA Encryption
/////////////////////////////////////////////

export default function generate_rsa_keys() {
    let rsaKeypair = pki.rsa.generateKeyPair(2048);

    const publicKeyPem = pki.publicKeyToPem(rsaKeypair.publicKey);
    const privateKeyPem = pki.privateKeyToPem(rsaKeypair.privateKey);

    const privateBase64 = Buffer.from(privateKeyPem).toString("base64");
    const publicBase64 = Buffer.from(publicKeyPem).toString("base64");

    let env = fs.readFileSync(".env", "utf8");
    env = env.replace(/RSA_PRIVATE_KEY=.*/g, `RSA_PRIVATE_KEY="${privateBase64}"`);
    env = env.replace(/RSA_PUBLIC_KEY=.*/g, `RSA_PUBLIC_KEY="${publicBase64}"`);
    fs.writeFileSync(".env", env);

}

export function rsa_decrypt(text) {
    const privateKey = Buffer.from(process.env.RSA_PRIVATE_KEY, "base64").toString("utf8");

    const privKey = forge.pki.privateKeyFromPem(privateKey);
    const decrypted = privKey.decrypt(forge.util.decode64(text), 'RSA-OAEP');

    return decrypted;
}
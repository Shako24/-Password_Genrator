import { decrypt_password, encrypt_password } from '../python_scripts/pythonRun.js';

// Define a function that returns a Promise
export function decryptPasswordAsync(enPassword, decPass) {
  return new Promise((resolve, reject) => {
    decrypt_password([enPassword, decPass], (error, output) => {
      if (error) {
        reject(error);
      } else {
        resolve(output);
      }
    });
  });
}


// Define a function that returns a Promise
export function encryptPasswordAsync(password, decPass) {
  return new Promise((resolve, reject) => {
    encrypt_password([password, decPass], (error, output) => {
      if (error) {
        reject(error);
      } else {
        resolve(output);
      }
    });
  });
}

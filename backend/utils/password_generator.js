import { randomInt } from 'crypto';

export const generate_password = async (passwordLength) => {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  const numbers = '0123456789';
  const symbols = '.,-*_&^$#!?';

  let password = '';
  let count = 0;

  while (password.length < passwordLength) {
    // Add 5-11 letters
    const letterCount = randomInt(5, 12);
    for (let i = 0; i < letterCount && count < passwordLength; i++) {
      password += letters[randomInt(0, letters.length)];
      count++;
    }

    // Add 1 symbol
    if (count < passwordLength) {
      password += symbols[randomInt(0, symbols.length)];
      count++;
    }

    // Add 0-2 numbers
    const numCount = randomInt(0, 3);
    for (let i = 0; i < numCount && count < passwordLength; i++) {
      password += numbers[randomInt(0, numbers.length)];
      count++;
    }
  }

  return password;
};

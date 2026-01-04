


export const generate_password = async (passwordLength) => {

    const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    const numbers = "0123456789";
    const symbols = ".,-*_&^$#!?";

    let password = "";
    let count = 0;
    
    while (password.length < passwordLength) {
        let randCounter = count + (Math.floor(Math.random() * 10) % 7);
        if (randCounter < 5) {
            randCounter += 5;
        }

        for (let i = count; i < randCounter; i++) {
            if (count < passwordLength) {
                const key = Math.floor(Math.random() * 52);
                password += letters[key];
                count++;
            }
        }

        if (count < passwordLength) {
            const key = Math.floor(Math.random() * 11);
            password += symbols[key % symbols.length];
            count++;
        }

        randCounter = count + (Math.floor(Math.random() * 3) % 3);
        for (let i = count; i < randCounter; i++) {
            if (count < passwordLength) {
                const key = Math.floor(Math.random() * 10);
                password += numbers[key];
                count++;
            }
        }
    }
    console.log('password: ', password);    

    return password;

}
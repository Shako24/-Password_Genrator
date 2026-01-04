// import { readFileSync } from 'node:fs';
import readFileSync from 'node:fs';

export default function readPassword() {
  try {
    const fileContent = readFileSync('password-access-encrypted.txt', 'utf8');
    const lines = fileContent.split('\n');
    let site = [];
    let username = [];
    let password = [];
    
    
    for (let i = 0; i < lines.length; i += 2) {
      
      if (lines[i] !== ""){ 
        console.log("Lines:" + lines[i]+"end");
        const [siteLine, usernameAndPasswordLine] = lines[i].split(' (');
        site.push(siteLine);
        console.log("SiteLine: " + siteLine);
        const [usernameLine, passwordLine, temppassword] = usernameAndPasswordLine.split(' ');
        console.log("usernameAndPasswordLine: " + usernameAndPasswordLine);
        username.push(usernameLine.slice(0,-1));
        password.push(temppassword);
      }
    }

    console.log('Passsword Printing completed');

    return { site, username, password };
  } catch (error) {
    console.error('Error reading the file:', error);
    return { site: [], username: [], password: [] };
  }
}


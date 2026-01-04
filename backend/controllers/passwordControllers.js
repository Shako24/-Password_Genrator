/**
 * FUNCTION: Generate Password
 * METHOD: POST
 * PURPOSE: Generate a new password and encrypts the password and saves in DB 
*/
import { generate_password } from '../utils/password_generator.js';
import { DuplicateEntry, WrongPassword } from '../api/error.js';

export const generate_password_controller = async (req,resp) => {
    const requestBody = req.body;
    let output, respBody, password;

    console.log('Received requestBody: ',requestBody);

    // password = await generate_password(12);

    try {
      const password = await generate_password(requestBody.password_length);

      respBody = {'password: ': password};

      resp.json(respBody);

    } catch (error) {
      if (error instanceof WrongPassword) {
        resp.status(404).send({
          name: error.name,
          message: error.message
        });
      }
      else if (error instanceof DuplicateEntry) {
        resp.status(404).send({
          name: error.name,
          message: error.message
        });
      } else {
        console.error(`Error: ${error.message}`);
        resp.status(500).send({
          name: 'Internal Server Error',
          message: 'Internal Server Error'
        });
      }
    }
}
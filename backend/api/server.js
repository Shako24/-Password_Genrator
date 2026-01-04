
import express, { json, response, urlencoded } from 'express';
import { DuplicateEntry, WrongPassword } from './error.js';
import authRoutes from '../routes/authRoutes.js';
import passwordRoutes from '../routes/passwordRoutes.js';
import generate_rsa_keys from '../utils/rsa_encryption.js';
import '../config.js';

const app = express();

// const port = 8080;

const port = process.env.PORT || 8080

// Middleware to parse JSON and URL-encoded data
app.use(json());
app.use(urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.send("Hello World!");
});

// Define a route to handle POST requests
app.post('/post-example', (req, res) => {
    const postData = req.body; // Access the data from the POST request body
    console.log('Received POST data:', postData);
    res.status(201).send('Data received successfully'); // Send a response
});

/**
 * Routes: Auth Routes
*/
app.use('/auth', authRoutes);
app.use('/password', passwordRoutes);

app.get('/generate-rsa-keys', async(req, resp) => {
    generate_rsa_keys();
  }
);

app.listen(port, () => {
  console.log(`Listening the app on http://192.168.0.169:${port} ...`);
});



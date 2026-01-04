import express from 'express';
import { generate_password_controller,  } from '../controllers/passwordControllers.js';

const router = express.Router();

router.post('/generate-password', generate_password_controller);
// router.post('/encrypt-password', )

export default router;
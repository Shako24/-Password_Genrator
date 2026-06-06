import express from 'express';
import {
  generate_password_controller,
  save_password_controller,
  update_password_controller,
  show_password_controller,
  show_sites_controller,
  show_selected_sites_controller,
} from '../controllers/passwordControllers.js';
import { authenticateToken } from '../middleware/authenticate.js';

const router = express.Router();

router.post('/generate-password', authenticateToken, generate_password_controller);
router.post('/save-password', authenticateToken, save_password_controller);
router.put('/save-password', authenticateToken, update_password_controller);
router.post('/show-password', authenticateToken, show_password_controller);
router.get('/show-sites', authenticateToken, show_sites_controller);
router.post('/show-selected-sites', authenticateToken, show_selected_sites_controller);

export default router;

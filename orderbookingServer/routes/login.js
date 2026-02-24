const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
require('dotenv').config();
const auth = require('./middleware/auth');
const db = require('./db'); // your mssql pool wrapper
const crypto = require('crypto');

var bodyParser = require('body-parser');

function generateRefreshToken() {
  return crypto.randomBytes(64).toString('hex');
}

// Create tokens helper
function createAccessToken(payload) {
  return jwt.sign(payload, process.env.JWT_SECRET_KEY, { expiresIn: '15m' }); // production: 15m
}
function createRefreshTokenPayload(mobile) {
  const token = generateRefreshToken();
  return token;
}


router.post('/Createlogin', async (req, res) => {
  try {
    const { mobile, deviceDetails } = req.body;

    if (!mobile)
      return res.status(400).json({ error: 'Mobile number required' });

    const refreshToken = createRefreshTokenPayload(mobile);
    const expiresAt = new Date(Date.now() + 7 * 24 * 3600 * 1000);

    const result = await db.request()
      .input('operation', 'insert')
      .input('user_mobile', mobile)
      .input('refresh_token', refreshToken)
      .input('device_info', deviceDetails)
      .input('expires_at', expiresAt)
      .execute('ManageRefreshToken');

    const roleId = result.recordset?.[0]?.role_id;

    const accessToken = createAccessToken({
      mobile
    });

    return res.json({
      accessToken,
      refreshToken,
      roleId,
      mobile
    });

  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: err.message });
  }
});

router.post('/refreshAccessToken', async (req, res) => {
  console.log("inside the refreshAccessToken route");
  try {
    const { refreshToken } = req.body;

    if (!refreshToken)
      return res.status(400).json({ error: 'Refresh token required' });

    const result = await db.request()
      .input('operation', 'get')
      .input('refresh_token', refreshToken)
      .execute('ManageRefreshToken');

    const rows = result.recordset || [];


    if (!rows.length)
      return res.status(403).json({ error: 'Invalid refresh token' });

    const row = rows[0];
    const mobile = row.user_mobile;
    const roleId = row.role_id;

    jwt.verify(refreshToken, process.env.REFRESH_KEY, (err, decoded) => {
      if (err) {
        return res.status(403).json({ error: 'Invalid refresh token' });
      }
    });

    // revoke old
    await db.request()
      .input('operation', 'revoke')
      .input('refresh_token', refreshToken)
      .execute('ManageRefreshToken');

    // create new
    const newAccessToken = createAccessToken({
      mobile
    });

    const newRefreshToken = createRefreshTokenPayload(mobile);

    const newExpiresAt = new Date(Date.now() + 7 * 24 * 3600 * 1000);

    await db.request()
      .input('operation', 'insert')
      .input('user_mobile', mobile)
      .input('refresh_token', newRefreshToken)
      .input('device_info', row.device_info)
      .input('expires_at', newExpiresAt)
      .execute('ManageRefreshToken');


    return res.json({
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      roleId,
      mobile
    });

  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});
router.post('/logout', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token required'
      });
    }

    const result = await db.request()
      .input('operation', 'revoke')
      .input('refresh_token', refreshToken)
      .execute('ManageRefreshToken');

    const revokedCount = result.recordset[0]?.revoked_count || 0;

    if (revokedCount > 0) {
      return res.json({
        success: true,
        message: 'Logout successful'
      });
    } else {
      return res.status(400).json({
        success: false,
        message: 'Invalid refresh token or already revoked'
      });
    }

  } catch (err) {
    console.error(err);
    return res.status(500).json({
      success: false,
      message: 'Logout failed'
    });
  }
});


router.get('/checkPhone', async (req, res) => {
  try {
    const { mobile_no } = req.query;

    const result = await db.request()
      .input('operation', 'check_phone')
      .input('mobile_no', mobile_no)
      .execute('sp_admin_login');

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router; 
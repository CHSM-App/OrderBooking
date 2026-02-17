
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
require('dotenv').config();
const auth = require('./middleware/auth');
const db = require('./db'); // your mssql pool wrapper
const crypto = require('crypto');

var bodyParser = require('body-parser');

function generateRefreshToken() {
  // opaque random token for DB storage + never reveal secret structure
  return crypto.randomBytes(64).toString('hex');
}

// Create tokens helper
function createAccessToken(payload) {
  return jwt.sign(payload, process.env.JWT_SECRET_KEY, { expiresIn: '15m' }); // production: 15m
}
function createRefreshTokenPayload(mobile) {
  // we don't sign this with jwt secret; we'll store opaque token in db
  const token = generateRefreshToken();
  // You can optionally also sign metadata as a jwt for additional checks.
  return token;
}

/*router.post('/Createlogin', async (req, res) => {
  try {
    const { mobile, deviceDetails } = req.body;

    if (!mobile)
      return res.status(400).json({ error: 'Mobile number required' });

    const accessToken = createAccessToken({ mobile });
    const refreshToken = createRefreshTokenPayload(mobile);
    const expiresAt = new Date(Date.now() + 7 * 24 * 3600 * 1000);

    const result = await db.request()
      .input('operation', 'insert')
      .input('user_mobile', mobile)
      .input('refresh_token', refreshToken)
      .input('device_info', deviceDetails)
      .input('expires_at', expiresAt)
      .execute('ManageRefreshToken');

    const userId = result.recordset?.[0]?.id;

    return res.json({
      accessToken,
      refreshToken,
      userId: userId
    });

  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: err.message });
  }
});/*


/**
 * Refresh access token
 * Expect { refresh_token } in req.body
 * Implements rotation: revoke old refresh token, issue new one
 */
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
      mobile,
      roleId
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

    // revoke old
    await db.request()
      .input('operation', 'revoke')
      .input('refresh_token', refreshToken)
      .execute('ManageRefreshToken');

    // create new
    const newAccessToken = createAccessToken({
      mobile,
      roleId
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
    console.error(err);
    return res.status(500).json({ error: err.message });
  }
});



router.post('/logout', async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) return res.status(400).json({ error: 'Refresh token required' });

    await db.request()
	  .input('operation', 'revoke')
		.input('refresh_token', refreshToken)
		.execute('ManageRefreshToken');
    return res.json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Logout failed' });
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

const API_URL = "http://papi.messagebot.in/SendSmsV2";
const API_TOKEN = "L2Uj2dK9ARQrfUy2";
const SOURCE_ID = "SMSALA"; // your approved sender ID

router.post("/send-sms", async (req, res) => {
  const { phone, message, dltEntityId, dltTemplateId } = req.body;

  if (!phone || !message) {
    return res.status(400).json({ error: "phone and message are required" });
  }

  const payload = [
    {
      apiToken: API_TOKEN,
      messageType: "3",            // Transactional
      messageEncoding: "1",        // Text
      destinationAddress: phone,   // e.g. 91XXXXXXXXXX
      sourceAddress: SOURCE_ID,
      messageText: message,
      dltEntityId,
      dltEntityTemplateId: dltTemplateId
    }
  ];

  try {
    const response = await axios.post(API_URL, payload, {
      headers: { "Content-Type": "application/json" }
    });

    return res.json({
      success: true,
      providerResponse: response.data
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      error: err.message,
      details: err.response?.data
    });
  }
});






module.exports = router; 
const express = require('express');
const router = express.Router();

// v2 skeleton: add new endpoints here without breaking v1
router.get('/health', (req, res) => {
  res.status(200).json({ ok: true, version: 'v2' });
});

router.all('*', (req, res) => {
  res.status(501).json({
    ok: false,
    version: 'v2',
    message: 'Endpoint not implemented in v2 yet'
  });
});

module.exports = router;

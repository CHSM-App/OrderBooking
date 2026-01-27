var express = require('express');
var router = express.Router();

var db = require('./db');


router.get('/userRouter', async function (req, res) {
    try {
        res.send('Hello World! from Users route');
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


router.get("/select", async function (req, res, next) {
  try {
    const result = await db.request()
	.input('operation','select')
	.execute('sp_product');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
router.get('/employeeList',  async (req, res) => {
  try {
    const result = await db.request()
      .input("operation", "fetchEmployeeList")
      .execute("sp_employee_login");

    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/regionList',  async (req, res) => {
  try {
    const result = await db.request()
      .input("operation", "fetchRegionList")
      .execute("sp_region");

    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});




router.get('/employeeDetails/:emp_id',  async (req, res) => {
  try {
    const { emp_id } = req.params;

    const result = await db.request()
      .input("operation", "fetchEmployeeDetails")
      .input("emp_id", emp_id)
      .execute("sp_employee_login");

    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/adminDetails/:mobile_no',  async (req, res) => {
  try {
    const { mobile_no } = req.params;

    const result = await db.request()
      .input("operation", "fetchAdminDetails")
      .input("mobile_no", mobile_no)
      .execute("sp_admin_login");

    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/fetchEmployeeInfo/:mobile_no',  async (req, res) => {
  try {
    const { mobile_no } = req.params;

    const result = await db.request()
      .input("operation", "GetEmployeeInformation")
      .input("emp_mobile", mobile_no)
      .execute("sp_employee_login");

    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
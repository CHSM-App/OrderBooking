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


router.get('/getOrders/:emp_id', async (req, res) => {
	console.log(req.params);
	const { emp_id } = req.params;

  try {
    const result = await db.request()
      .input('operation', 'getOrders')
	  .input('employee_id', emp_id)
      .execute('sp_orders');

    const rows = result.recordset;
    console.log(rows);

    if (!rows || rows.length === 0) {
      return res.status(200).json({
        success: true,
        data: []
      });
    }

    // Group by order_id
    const ordersMap = {};

    for (const row of rows) {
      const orderId = row.order_id;

      // If order not created yet, create base structure
      if (!ordersMap[orderId]) {
        ordersMap[orderId] = {
          order_id: row.order_id,
          order_date: row.order_date,
          shop_id: row.shop_id,
          shop_name: row.shop_name,
          employee_id: row.employee_id,
          order_total_price: row.order_total_price,
          items: []
        };
      }

      // Push item
      ordersMap[orderId].items.push({
        order_item_id: row.order_item_id,
        product_id: row.product_id,
        product_name: row.product_name,
        product_type: row.product_type,
        sub_item_id: row.sub_item_id,
        quantity: row.quantity,
        product_price: row.product_price,
        item_total_price: row.item_total_price,
        available_unit: row.available_unit
      });
    }

    // Convert map → array
    const response = Object.values(ordersMap);

    res.status(200).json({
      success: true,
      data: response
    });

  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message
    });
  }
});


module.exports = router;
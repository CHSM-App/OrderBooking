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

//EMPLOYEE ALL FETCH API 
router.get('/employeeList/:company_id',  async (req, res) => {
  try {
	   const { company_id } = req.params;
       const result = await db.request()
      	  .input("operation", "fetchEmployeeList")
	   	  .input("company_id", company_id)
     	  .execute("sp_employee_login");

    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/getEmployeeVisits/:emp_id',  async (req, res) => {
  try {
	   const { emp_id } = req.params;
       const result = await db.request()
      	  .input("operation", "getEmployeeVisits")
	   	  .input("emp_id", emp_id)
     	  .execute("sp_employee_location");

    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.get('/getEmployeeAttendance/:emp_id',  async (req, res) => {
  try {
	   const { emp_id } = req.params;
       const result = await db.request()
      	  .input("operation", "empAttendance")
	   	  .input("emp_id", emp_id)
     	  .execute("sp_employee_checkin");

    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/checkMobile/:company_id/:emp_mobile', async (req, res) => {
  try {
    const { company_id, emp_mobile } = req.params;

    const result = await db.request()
      .input('operation', 'checkMobileExists')
      .input('company_id', company_id)
      .input('emp_mobile', emp_mobile)
      .execute('sp_employee_login');

    const row = result.recordset[0];

    const isExists = row?.isExists ? true : false;
    const status = row?.status ?? 0;

    res.status(200).json({ 
      exists: isExists,
      status: status
    });

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

//REGIONLIST 
router.get('/regionList/:company_id',  async (req, res) => {
  try {
	   const { company_id } = req.params;
	  
    const result = await db.request()
      .input("operation", "fetchRegionList")
	  .input("company_id", company_id)
      .execute("sp_region");

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




router.get('/current/:emp_id', async (req, res) => {
  try {
    const { emp_id } = req.params;

    const result = await db.request()
      .input('operation', 'fetchTodayAttendance')
      .input('emp_id', emp_id)
      .execute('sp_employee_checkin');

    res.status(200).json(result.recordset);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


//PRODUCT ALL API
router.get('/productList/:company_id', async (req, res) => {
  try {
    const { company_id } = req.params;

    const result = await db.request()
      .input('operation', 'fetchProductList')
      .input('company_id', company_id)
      .execute('sp_product');
    const rows = result.recordset;
    const productsMap = {};
    for (const row of rows) {
      const productId = row.product_id;

      // create product once
      if (!productsMap[productId]) {
        productsMap[productId] = {
          product_id: row.product_id,
          product_name: row.product_name,
          product_type: row.product_type,
          created_by: row.created_by,
          subtypes: [],
        };
      }

      // add unit if exists
      if (row.sub_item_id != null) {
        productsMap[productId].subtypes.push({
          sub_item_id: row.sub_item_id,
          measuring_unit: row.measuring_unit,
          available_unit: row.available_unit,
          price: row.price,
        });
      }
    }
    // send grouped result
    res.status(200).json(Object.values(productsMap));

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.get('/productDetails/:product_id/:admin_id', async (req, res) => {
  try {
    const { product_id, admin_id } = req.params;
    const result = await db.request()
      .input('operation', 'fetchProductDetails')
      .input('product_id', product_id)
      .input('created_by', admin_id)
      .execute('sp_product');

    res.status(200).json({
      product: result.recordsets[0]?.[0] || null,
      subitems: result.recordsets[1] || []
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.get('/shopList/:company_id',  async (req, res) => {
		const { company_id } = req.params;
  try {
    const result = await db.request()
      .input("operation", "getShopList")
	   .input("company_id", company_id)
      .execute("sp_shop_details");

    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/employeeShopList/:company_id/:region_id',  async (req, res) => {
		const { company_id, region_id } = req.params;
  try {
    const result = await db.request()
      .input("operation", "employeeShopList")
	   .input("company_id", company_id)
	    .input("region_id", region_id)
      .execute("sp_shop_details");

    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.get('/employeeVisits/:emp_id',  async (req, res) => {
	const { emp_id } = req.params;
  try {
    const result = await db.request()
      .input("operation", "getCoOrdinates")
		.input("emp_id", emp_id)
      .execute("sp_employee_location");

    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/getAttendanceReport/:company_id',  async (req, res) => {
	const { company_id } = req.params;
  try {
    const result = await db.request()
      .input("operation", "getAttendanceReport")
		.input("company_id", company_id)
      .execute("sp_employee_login");

    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});



router.get('/ /:emp_id', async (req, res) => {

  const { emp_id } = req.params;

  try {
    const result = await db.request()
      .input('operation', 'getOrdersLocation')
	  .input('employee_id', emp_id)
      .execute('sp_orders');

      const rows = result.recordset;

    if (!rows || rows.length === 0) {
      return res.status(200).json([]);
    }

    const locationMap = {};

    for (const row of rows) {

      const locationId = row.location_id;
      const orderId = row.order_id;

      // 🔹 Create Location Level
      if (!locationMap[locationId]) {
        locationMap[locationId] = {
          location_id: row.location_id,
		emp_id: row.employee_id,
	shop_id: row.shop_id,
			shop_name: row.shop_name,
          latitude: row.latitude,
          longitude: row.longitude,
          punchIn: row.punchIn,
          punchOut: row.punchOut,
          orders: []
        };
      }

      const location = locationMap[locationId];

      // 🔹 Find if order already exists inside this location
      let order = location.orders.find(o => o.order_id === orderId);

      if (!order && orderId) {
        order = {
          order_id: row.order_id,
          order_date: row.order_date,
	employee_id: row.employee_id,
          shop_name: row.shop_name,
			 shop_id: row.shop_id,
          emp_name: row.emp_name,
          total_price: row.order_total_price,
          address: row.address,
          owner_name: row.owner_name,
          mobile_no: row.mobile_no,
          items: []
        };

        location.orders.push(order);
      }

      // 🔹 Push subproduct (item)
      if (order && row.order_item_id) {
        order.items.push({
          order_item_id: row.order_item_id,
          product_id: row.product_id,
          product_name: row.product_name,
          product_type: row.product_type,
          sub_item_id: row.sub_item_id,
          quantity: row.quantity,
          price: row.product_price,
          total_price: row.item_total_price,
          product_unit: row.available_unit?.toString()
        });
      }
    }

    const response = Object.values(locationMap);

    res.status(200).json(response);

  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message
    });
  }
});



router.get('/getOrders/:emp_id', async (req, res) => {
	
	const { emp_id } = req.params;

  try {
    const result = await db.request()
      .input('operation', 'getOrders')
	  .input('employee_id', emp_id)
      .execute('sp_orders');

    const rows = result.recordset;

  if (!rows || rows.length === 0) {
  return res.status(200).json([]);
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
		  emp_name: row.emp_name,
          total_price: row.order_total_price,
		  address: row.address,
		  owner_name: row.owner_name,
		  mobile_no: row.mobile_no,
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
        price: row.product_price,
        total_price: row.item_total_price,
        product_unit: row.available_unit.toString()
      });
    }

    // Convert map → array
    const response = Object.values(ordersMap);

res.status(200).json(response);

  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message
    });
  }
});


router.get('/getAllOrders/:company_id', async (req, res) => {
	
	const { company_id } = req.params;

  try {
    const result = await db.request()
      .input('operation', 'getOrderList')
	  .input('company_id', company_id)
      .execute('sp_orders');

    const rows = result.recordset;

 	if (!rows || rows.length === 0) {
  return res.status(200).json([]);
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
          total_price: row.order_total_price,
		  company_id: row.company_id,
		  address: row.address,
		  emp_name: row.emp_name,
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
        price: row.product_price,
        total_price: row.item_total_price,
        product_unit: row.available_unit.toString()
      });
    }

    // Convert map → array
    const response = Object.values(ordersMap);

res.status(200).json(response);

  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message
    });
  }
});
router.get('/productReport/:company_id', async (req, res) => {
  const { company_id } = req.params;

  try {
    const result = await db.request()
      .input('operation', 'productwise_report')
      .input('company_id', company_id)
      .execute('sp_product');

    //const response = Object.values(productMap);
    const response = result.recordset;
    res.status(200).json(response);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});


module.exports = router;
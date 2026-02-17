var express = require('express');
var router = express.Router();
var db = require('./db');
const sql = require("mssql");
const { createBatches, callGraphhopper } = require("./distCal");



//Add Employee
router.post('/employee', async (req, res) => {
  try {
    const {
      emp_id,
      emp_name,
      emp_mobile,
      role_id,
      emp_address,
      emp_email,
      region_id,
      image_url,
      id_proof,
      admin_id,
      company_id
    } = req.body;

    //  Validation: Mobile number should not be null or empty
    if (!emp_mobile || emp_mobile.trim() === "") {
      return res.status(400).json({
        success: false,
        message: "Mobile number is required and cannot be null"
      });
    }

    const request = db.request();
    const operation =
      emp_id && emp_id > 0 ? "Update" : "Insert";

    request.input("operation", operation);
    request.input("emp_name", emp_name);
    request.input("emp_mobile", emp_mobile);
    request.input("role_id", role_id);
    request.input("emp_address", emp_address);
    request.input("emp_email", emp_email);
    request.input("region_id", region_id);
    request.input("image_url", image_url || null);
    request.input("id_proof", id_proof || null);
    request.input("admin_id", admin_id || null);
    request.input("company_id", company_id || null);

    // 🔥 Only for update
    if (operation === "Update") {
      request.input("emp_id", emp_id);
    }

    const result = await request.execute("sp_employee_login");
    const returnedEmpId = result.recordset?.[0]?.emp_id;

    return res.status(200).json({
      success: true,
      emp_id: returnedEmpId,
      message:
        operation === "Update"
          ? "Employee updated successfully"
          : "Employee added successfully"
    });

  } catch (err) {
    console.error("Error in /employee API:", err);
    return res.status(500).json({
      success: false,
      error: err.message
    });
  }
});


// Add / Update Admin
router.post('/addAdminDetails', async (req, res) => {
  try {
    const {
      admin_id,
      admin_name,
      company_name,
      mobile_no,
      address,
      email,
      gstin_no,
      role_id
    } = req.body;

    const request = db.request();
    const operation = admin_id && admin_id > 0 ? "Update" : "Insert";

    request.input("operation", operation);
    request.input("admin_name", admin_name);
    request.input("company_name", company_name);
    request.input("mobile_no", mobile_no);
    request.input("address", address);
    request.input("email", email);
    request.input("gstin_no", gstin_no);
    request.input("role_id", role_id);

    // Only for update
    if (operation === "Update") {
      request.input("admin_id", admin_id);
    }

    const result = await request.execute("sp_admin_login");

    // 🔥 Get values returned from SP
    const returnedAdminId = result.recordset?.[0]?.admin_id;
    const returnedCompanyId = result.recordset?.[0]?.company_id;

    return res.status(200).json({
      success: true,
      admin_id: returnedAdminId,
      company_id: returnedCompanyId, // ✅ C00001
      message:
        operation === "Update"
          ? "Admin Details updated successfully"
          : "Admin Details added successfully"
    });

  } catch (err) {
    console.error("Error in /addAdminDetails API:", err);
    return res.status(500).json({
      success: false,
      error: err.message
    });
  }
});



router.post("/addRegion", async (req, res) => {
  try {
    const { region_id, region_name, pincode, district, state, created_by, company_id } = req.body;

    if (!region_name || !company_id) {
      return res.status(400).json({ success: false, message: "region_name and company_id are required" });
    }

    const request = db.request();
    const operation = region_id && region_id > 0 ? "Update" : "Insert";

    request.input("operation", operation);
    request.input("region_name", region_name);
    request.input("pincode", pincode || null);
    request.input("district", district || null);
    request.input("state", state || null);
    request.input("created_by", created_by || null);
    request.input("company_id", company_id);

    if (operation === "Update") request.input("region_id", region_id);

    const result = await request.execute("sp_region");
    const spResult = result.recordset?.[0];

    if (!spResult) {
      return res.status(500).json({ success: false, message: "No response from stored procedure" });
    }

    // Return success or failure based on SP status
    // SP status = 0 -> failure
    // SP status = 1 -> success (even if region used in tables, message includes table names)
    const isSuccess = spResult.status === 1;

    return res.status(200).json({
      success: isSuccess,
      region_id: spResult.region_id || region_id,
      message: spResult.message || (isSuccess ? "Operation completed" : "Something went wrong"),
    });

  } catch (err) {
    console.error("Error in /addRegion API:", err);
    return res.status(500).json({ success: false, message: err.message });
  }
});


//Add Shop
router.post("/addShopDetails", async (req, res) => {
  try {
    const {
      shop_id,
      shop_name,
      owner_name,
      address,
      mobile_no,
      email,
      region_id,
      created_by,
      company_id
    } = req.body;

    const request = db.request();
    const operation = shop_id && shop_id > 0 ? "Update" : "Insert";
    request.input("operation", operation);
    request.input("shop_name", shop_name);
    request.input("owner_name", owner_name);
    request.input("address", address);
    request.input("mobile_no", mobile_no);
    request.input("email", email);
    request.input("region_id", region_id);
    request.input("created_by", created_by);
    request.input("company_id", company_id);
    if (operation === "Update") {
      request.input("shop_id", shop_id);
    }

    const result = await request.execute("sp_shop_details");
    const returnedShopId = result.recordset?.[0]?.shop_id;
    return res.status(200).json({
      success: true,
      shop_id: returnedShopId,
      message:
        operation === "Update"
          ? "Shop updated successfully"
          : "Shop added successfully"
    });

  } catch (err) {
    console.error("Error in /addShop API:", err);
    return res.status(500).json({
      success: false,
      error: err.message
    });
  }
});


// Add / Update Product with Sub Types
router.post("/addProduct", async (req, res) => {
  try {
    const {
      product_id,
      product_name,
      product_type,
      created_by,
      company_id,   // NEW: company_id required
      subtypes // array [{ measuring_unit, available_unit, price }]
    } = req.body;

    // Validation
    if (!product_name || !product_type || !created_by || !company_id) {
      return res.status(400).json({
        success: false,
        error: "product_name, product_type, created_by, and company_id are required"
      });
    }

    // Validate subtypes array
    if (!Array.isArray(subtypes) || subtypes.length === 0) {
      return res.status(400).json({
        success: false,
        error: "subtypes must be a non-empty array"
      });
    }

    // Validate each subtype has required fields
    for (let i = 0; i < subtypes.length; i++) {
      const subtype = subtypes[i];
      if (!subtype.measuring_unit || subtype.available_unit == null || subtype.price == null) {
        return res.status(400).json({
          success: false,
          error: `Invalid subtype at index ${i}: measuring_unit, available_unit, and price are required`
        });
      }
    }

    const request = db.request();

    // Determine operation
    // const operation = product_id && product_id > 0 ? "Update" : "InsertWithSubTypes";
    const operation = "InsertWithSubTypes";

    request.input("operation", operation);
    request.input("product_id", product_id || null);
    request.input("product_name", product_name);
    request.input("product_type", product_type);
    request.input("created_by", created_by);
    request.input("company_id", company_id);  // NEW: pass company_id

    // Convert subtypes array to JSON string
    const subtypesJson = JSON.stringify(subtypes);
    request.input("subtypes_json", subtypesJson);

    console.log("Executing sp_product with operation:", operation);
    console.log("Subtypes JSON:", subtypesJson);

    const result = await request.execute("sp_product");

    const returnedProductId = result.recordset?.[0]?.product_id;

    if (!returnedProductId) {
      return res.status(500).json({
        success: false,
        error: "Failed to get product_id from stored procedure"
      });
    }

    return res.status(200).json({
      success: true,
      product_id: returnedProductId,
      message: operation === "Update" ? "Product updated successfully" : "Product added successfully"
    });

  } catch (err) {
    console.error("Error in /addProduct API:", err);
    return res.status(500).json({
      success: false,
      error: err.message || "An error occurred while processing the request"
    });
  }
});



router.post("/addLocation", async (req, res) => {
  try {
    const {
      lat,
      lng,
      punch_out,   // datetime
      punch_in,
      employee_id,
      accuracy,
      shop_id,
    } = req.body;


    const request = db.request();
    request.input("operation", "INSERT");
    request.input("latitude", lat);
    request.input("longitude", lng);
    request.input("punchIn", punch_in);
    request.input("punchOut", punch_out);
    request.input("emp_id", employee_id);
    request.input("accuracy", accuracy);
    request.input("shop_id", shop_id);

    const result = await request.execute("sp_employee_location");
    const location_id = result.recordset?.[0]?.location_id;

    return res.status(200).json({
      success: true,
      location_id,
      message: "Location added successfully",
    });

  } catch (err) {
    console.error("Error in /addLocation:", err);
    return res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});


router.post('/addOrder', async (req, res) => {
  try {
    const {
      employee_id,
      shop_id,
      order_date,
      total_price,
      company_id,
      items
    } = req.body;

    // Basic validation (don’t skip this)
    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: "Order items are required"
      });
    }

    /* -----------------------------
       STEP 1: INSERT ORDER
       ----------------------------- */
    const orderRequest = db.request();
    orderRequest.input("operation", "INSERT_ORDER");
    orderRequest.input("employee_id", employee_id);
    orderRequest.input("shop_id", shop_id);
    orderRequest.input("order_date", order_date);
    orderRequest.input("order_total_price", total_price);
    orderRequest.input("company_id", company_id);

    const orderResult = await orderRequest.execute("sp_orders");
    const order_id = orderResult.recordset?.[0]?.order_id;

    if (!order_id) {
      throw new Error("Failed to create order");
    }

    /* -----------------------------
       STEP 2: INSERT ORDER ITEMS
       ----------------------------- */
    for (const item of items) {
      const itemRequest = db.request();

      itemRequest.input("operation", "INSERT_ORDER_ITEM");
      itemRequest.input("order_id", order_id);
      itemRequest.input("product_id", item.product_id);
      itemRequest.input("sub_item_id", item.sub_item_id);
      itemRequest.input("quantity", item.quantity);
      itemRequest.input("item_total_price", item.total_price);

      await itemRequest.execute("sp_orders");
    }

    return res.status(200).json({
      success: true,
      order_id,
      message: "Order placed successfully"
    });

  } catch (err) {
    console.error("Error in /order API:", err);
    return res.status(500).json({
      success: false,
      error: err.message
    });
  }
});



router.post('/checkIn/:emp_id/:latitude/:longitude', async (req, res) => {
  try {
    const { emp_id, latitude, longitude } = req.params;



    const result = await db.request()
      .input('operation', 'checkIn')
      .input('latitude', latitude)
      .input('longitude', longitude)
      .input('emp_id', emp_id)
      .execute('sp_employee_checkin');

    const { message } = result.recordset;

    return res.status(200).json(result.recordset[0]);

  } catch (err) {
    return res.status(500).json({
      message: 'Something went wrong'
    });
  }
});


router.post('/checkOut/:emp_id/:latitude/:longitude', async (req, res) => {

  try {

    const { emp_id, latitude, longitude } = req.params;

    // 1️⃣ Get locations from DB
    const coordintaesResult = await db.request()
      .input('operation', 'getLocations')
      .input('emp_id', emp_id)
      .execute('sp_employee_checkin');


    let coordinates = coordintaesResult.recordset.map(row =>
      `${row.latitude},${row.longitude}`
    );


    // 2️⃣ Add checkout location
    coordinates.push(`${latitude},${longitude}`);
      let totalDistance = 0;
      let totalTime = 0;
      let totalDistanceKm = 0;

      console.log(coordinates);
    if (coordinates.length >= 2) {


      // 3️⃣ Create batches
      const batches = createBatches(coordinates);

      // 4️⃣ Call Graphhopper for each batch


      for (const batch of batches) {

        const result = await callGraphhopper(batch);

        totalDistance += result.distance;

        totalTime += result.time;

      }

      console.log(`total distance is ${totalDistance}`);

      totalDistanceKm = totalDistance / 1000;
    }

    // 5️⃣ Checkout with distance
    const checkoutResult = await db.request()
      .input('operation', 'checkOut')
      .input('emp_id', emp_id)
      .input('latitude', latitude)
      .input('longitude', longitude)
      .input('total_distance_km', totalDistanceKm)
      .execute('sp_employee_checkin');


    const response = checkoutResult.recordset[0];


    // 6️⃣ Final response
    res.json({

      success: true,

      total_distance_km: totalDistanceKm.toFixed(2),

      total_time_minutes: (totalTime / 60000).toFixed(2),

      checkout_location: {

        latitude,

        longitude

      },

      data: response

    });


  }

  catch (error) {

    console.error(error);

    res.status(500).json({

      success: false,

      message: error.message

    });

  }

});




module.exports = router; 

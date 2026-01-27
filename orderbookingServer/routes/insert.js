var express = require('express');
var router = express.Router();
var db = require('./db');

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
      id_proof
    } = req.body;

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

//Add Admin 
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
    const operation =
      admin_id && admin_id > 0 ? "Update" : "Insert";
    request.input("operation", operation);
    request.input("admin_name", admin_name);
	request.input("company_name", company_name);
    request.input("mobile_no", mobile_no);
    request.input("address", address);
    request.input("email", email);
    request.input("gstin_no", gstin_no);
    request.input("role_id", role_id);

    // 🔥 Only for update
    if (operation === "Update") {
      request.input("admin_id", admin_id);
    }
    const result = await request.execute("sp_admin_login");
    const returnedAdminId = result.recordset?.[0]?.admin_id;
    return res.status(200).json({
      success: true,
      admin_id: returnedAdminId,
      message:
        operation === "Update"
          ? "Admin Details updated successfully"
          : "Admin Details added successfully"
    });

  } catch (err) {
    console.error("Error in /admin API:", err);
    return res.status(500).json({
      success: false,
      error: err.message
    });
  }
});

//Add Region

router.post("/addRegion", async (req, res) => {
  try {
    const {
      region_id,
      region_name,
      pincode,
      district,
      state,
      created_by
    } = req.body;

    const request = db.request();
    const operation = region_id && region_id > 0 ? "Update" : "Insert";
    request.input("operation", operation);
    request.input("region_name", region_name);
    request.input("pincode", pincode);
    request.input("district", district);
    request.input("state", state);
    request.input("created_by", created_by);
    // Only for update
    if (operation === "Update") {
      request.input("region_id", region_id);
    }

    const result = await request.execute("sp_region");
    const returnedRegionId = result.recordset?.[0]?.region_id;
    return res.status(200).json({
      success: true,
      region_id: returnedRegionId,
      message:
        operation === "Update"
          ? "Region updated successfully"
          : "Region added successfully"
    });

  } catch (err) {
    console.error("Error in /addRegion API:", err);
    return res.status(500).json({
      success: false,
      error: err.message
    });
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
      created_by
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




module.exports = router; 
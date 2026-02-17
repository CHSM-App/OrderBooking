var express = require('express');
var router = express.Router();
var db = require('./db');
var sql = require('mssql');  // <--- add this line


// DELETE SHOP (ADMIN)
router.delete("/deleteShop/:shop_id", async (req, res) => {
  try {
    const { shop_id } = req.params;

    if (!shop_id) {
      return res.status(400).json({
        success: false,
        message: "shop_id is required"
      });
    }

    const request = db.request();
    request.input("operation", "DeleteShop"); // make sure SP supports this
    request.input("shop_id", parseInt(shop_id));

    const result = await request.execute("sp_shop_details"); 

    const affectedRows = result.recordset?.[0]?.affectedRows || 0;

    if (affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Shop not found"
      });
    }

    return res.status(200).json({
      success: true,
      message: "Shop deleted successfully"
    });

  } catch (err) {
    console.error("Error in deleteShop API:", err);

    return res.status(500).json({
      success: false,
      message: err.message || "Failed to delete shop"
    });
  }
});


// DELETE MULTIPLE SUBTYPES (ADMIN)
router.delete("/deleteProductSubTypes", async (req, res) => {
  try {
    const sub_item_ids = req.body;

    if (!Array.isArray(sub_item_ids) || sub_item_ids.length === 0) {
      return res.status(400).json({
        success: false,
        message: "sub_item_ids must be a non-empty array"
      });
    }

    let lastProductId = null;

    for (const id of sub_item_ids) {
      const request = db.request();
      request.input("operation", "DeleteSubType");
      request.input("sub_item_id", parseInt(id));

      const result = await request.execute("sp_product");

      lastProductId = result.recordset?.[0]?.product_id;
    }

    return res.status(200).json({
      success: true,
      product_id: lastProductId,
      message:
        "Subtype deleted successfully. Product deactivated if no subtypes left."
    });

  } catch (err) {
    console.error("Error in deleteSubTypes API:", err);

    return res.status(500).json({
      success: false,
      message: err.message || "Failed to delete subtype"
    });
  }
});


// DELETE EMPLOYEE (ADMIN)
router.delete("/deleteEmployee/:emp_id", async (req, res) => {
  try {
    const { emp_id } = req.params;

    if (!emp_id) {
      return res.status(400).json({
        success: false,
        message: "emp_id is required"
      });
    }

    const request = db.request();
    request.input("operation", "DeleteEmployee");
    request.input("emp_id", parseInt(emp_id));

   const result = await request.execute("sp_employee_login");

const affectedRows =
  result.recordset?.[0]?.affectedRows || 0;

if (affectedRows === 0) {
  return res.status(404).json({
    success: false,
    message: "Employee not found"
  });
}

return res.status(200).json({
  success: true,
  message: "Employee deleted successfully"
});
  
  } catch (err) {
    console.error("Error in deleteEmployee API:", err);

    return res.status(500).json({
      success: false,
      message: err.message || "Failed to delete employee"
    });
  }
});
router.delete('/deleteRegion/:region_id/:company_id', async (req, res) => {
  try {
    const regionId = parseInt(req.params.region_id);
    const companyId = req.params.company_id;

    if (!regionId || isNaN(regionId) || !companyId) {
      return res.status(400).json({
        status: 0,
        message: "Valid region_id and company_id are required"
      });
    }

    const pool = await db;

    const result = await pool.request()
      .input('operation', sql.NVarChar, 'Delete')
      .input('region_id', sql.Int, regionId)
      .input('company_id', sql.NVarChar, companyId)
      .execute('sp_region');

    const response = result.recordset?.[0];

    if (!response) {
      return res.status(500).json({
        status: 0,
        message: "No response from stored procedure"
      });
    }

    res.json({
      status: response.status,
      message: response.message
    });

  } catch (err) {
    console.error("Delete region error:", err.message, err);
    res.status(500).json({
      status: 0,
      message: err.message || "Server error while deleting region"
    });
  }
});



module.exports = router; 
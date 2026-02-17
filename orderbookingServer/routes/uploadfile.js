var express = require('express');
var router = express.Router();
var fs = require('fs-extra');
var multer = require('multer');
var path = require('path');
var db = require('./db'); // Your DB connection

const storage = multer.diskStorage({
    destination: function(req, file, cb){
        cb(null, 'uploads/');
    },
    filename: function(req, file, cb){
        cb(null, `${Date.now()}-${file.originalname}`);
    }
});
const upload = multer({ storage: storage });

// POST upload Employee ID Proof
router.post('/EmployeeIdProof', upload.array('image', 10), async function(req, res){
    if(!req.files || req.files.length === 0){
        return res.status(400).json({ error: 'No file uploaded' });
    }

    try{
        const empId = req.body.emp_id;
        const empDir = path.join(__dirname, "EmployeeIdProof", empId.toString());
        await fs.ensureDir(empDir);

        const movedFiles = [];
        for(const file of req.files){
            const src = path.join('uploads', file.filename);
            const dest = path.join(empDir, file.filename);
            await fs.move(src, dest, { overwrite: true });
            movedFiles.push(file.filename);
        }

        // Build public URLs
        const fileUrls = movedFiles.map(f => `https://orderbooking.vengurlatech.com/upload/EmployeeIdProof/${empId}/${f}`);

        // --- Save URLs to database ---
        for(const url of fileUrls){
            await db.request()
                .input('operation', 'UploadIdProof') // assuming your stored procedure uses this
                .input('id_proof', url)
                .input('emp_id', parseInt(empId))
                .execute('sp_employee_login'); // adjust SP name if needed
        }

        res.status(200).json({ 
            success: true, 
            message: "Employee ID Proof uploaded successfully",
            files: movedFiles,
            urls: fileUrls
        });

    } catch(err){
        console.error('Upload error:', err);
        res.status(500).json({ error: err.message });
    }
});

// GET Employee ID Proof
router.get('/EmployeeIdProof/:id/:file', async function(req, res){
    const filePath = path.join(__dirname, "EmployeeIdProof", req.params.id, req.params.file);
    res.sendFile(filePath, (err)=>{
        if(err){
            res.status(404).json({ error: "File not found" });
        }
    });
});

module.exports = router;

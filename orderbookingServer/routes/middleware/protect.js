const auth = require('./auth');

module.exports = function protect(req, res, next) {
  auth(req, res, function () {
    if (!req.user) {
      return;  // stop route execution if token invalid/expired
    }
    next();     // continue to Router
  });
};



// const auth = require('./auth');

// function normalizeRoleId(req, res) {
//   const roleId = req.user?.roleId ?? req.user?.role_id;
//   if (roleId == null) {
//     res.status(403).json({ msg: 'Role not authorized' });
//     return null;
//   }

//   const roleIdNum = Number(roleId);
//   if (Number.isNaN(roleIdNum)) {
//     res.status(403).json({ msg: 'Role not authorized' });
//     return null;
//   }

//   req.user.roleId = roleIdNum;
//   return roleIdNum;
// }

// function protect(req, res, next) {
//   auth(req, res, function () {
//     if (!req.user) {
//       return; // stop route execution if token invalid/expired
//     }

//     const roleId = normalizeRoleId(req, res);
//     if (roleId == null) {
//       return;
//     }

//     next(); // continue to Router
//   });
// }

// function adminOnly(req, res, next) {
//   const roleId = normalizeRoleId(req, res);
//   if (roleId == null) {
//     return;
//   }

//   if (roleId !== 1) {
//     return res.status(403).json({ msg: 'Admin access only' });
//   }

//   next();
// }

// function empOnly(req, res, next) {
//   const roleId = normalizeRoleId(req, res);
//   if (roleId == null) {
//     return;
//   }

//   if (roleId !== 2) {
//     return res.status(403).json({ msg: 'Employee access only' });
//   }

//   next();
// }

// function adminOrEmp(req, res, next) {
//   const roleId = normalizeRoleId(req, res);
//   if (roleId == null) {
//     return;
//   }

//   if (roleId !== 1 && roleId !== 2) {
//     return res.status(403).json({ msg: 'Admin or employee access only' });
//   }

//   next();
// }

// protect.adminOnly = adminOnly;
// protect.empOnly = empOnly;
// protect.adminOrEmp = adminOrEmp;

// module.exports = protect;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:order_booking_app/core/constant.dart';
import 'package:order_booking_app/domain/models/attendance.dart';
import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/models/employeeMap.dart';
import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/domain/models/login_info.dart';
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/domain/models/employee_visit.dart';
import 'package:order_booking_app/domain/models/product.dart';
// import 'package:order_booking_app/domain/models/product_details_response.dart';
import 'package:order_booking_app/domain/models/product_response.dart';
import 'package:order_booking_app/domain/models/product_data.dart';
import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/domain/models/token_response.dart';
import 'package:order_booking_app/domain/models/visite.dart';
import 'package:retrofit/retrofit.dart';
part 'api_service.g.dart';

@RestApi(baseUrl: baseUrl) // <-- replace with your base URL
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  //ADMIN API

  //GET API
  @GET("/")
  Future<HttpResponse> checkHealth();

  @GET("users/checkMobile/{company_id}/{emp_mobile}/{emp_id}")
  Future<dynamic> checkMobileExists(
    @Path("emp_mobile") String empMobile,
    @Path("company_id") String companyId,
    @Path("emp_id") int empId,
  );

  @GET("users/employeeList/{company_id}")
  Future<List<EmployeeLogin>> getEmployeeList(
    @Path("company_id") String companyId,
  );

  @GET("users/employeeDetails/{emp_id}")
  Future<List<EmployeeLogin>> fetchEmployeeDetails(@Path("emp_id") int empId);

  @GET("users/adminDetails/{mobile_no}")
  Future<List<AdminLogin>> fetchAdminDetails(
    @Path("mobile_no") String mobileNo,
  );

  @GET("users/fetchAdmins/{company_id}")
  Future<List<AdminLogin>> fetchAdmins(@Path("company_id") String companyId);

  @GET("users/shopList/{company_id}")
  Future<List<ShopDetails>> getShopList(@Path("company_id") String companyId);

  @GET("users/regionList/{company_id}")
  Future<List<Region>> fetchRegionList(@Path("company_id") String companyId);

  //Login Check
  @GET("login/checkPhone")
  Future<List<LoginInfo>> CheckPhone(@Query("mobile_no") String mobileNo);

  @GET("users/getAllOrders/{company_id}")
  Future<List<Order>> getOrderList(@Path("company_id") String companyId);

  @GET("users/getAttendanceReport/{company_id}")
  Future<List<AttendanceReport>> getAttendanceReport(
    @Path("company_id") String companyId,
  );

  @GET("users/getEmployeeLocationOrders/{emp_id}")
  Future<List<EmployeeVisit>> getEmployeeVisitLocation(
    @Path("emp_id") int empId,
  );

  @GET("users/getEmployeeAttendance/{emp_id}")
  Future<List<CheckInStatusRequest>> getAttendance(@Path("emp_id") int emp_id);

  //POST API
  @POST("login/CreateLogin")
  Future<TokenResponse> createLogin(@Body() TokenResponse tokenResponse);

  @POST("login/refreshAccessToken")
  Future<TokenResponse> refreshAccessToken(@Body() TokenResponse tokenResponse);

  @POST("insert/employee")
  Future<dynamic> addEmployee(@Body() EmployeeLogin employeeLogin);

  @POST("login/logout")
  Future<dynamic> logOut(@Body() TokenResponse tokenResponse);

  @POST("login/addAdminDetails")
  Future<dynamic> addAdminDetails(@Body() AdminLogin adminLogin);

  @POST("insert/addMultipleAdmins")
  Future<dynamic> addUpdateAdmin(@Body() AdminLogin admin);

  @POST("insert/deleteAdmin/{admin_id}")
  Future<dynamic> deleteAdmin(@Path("admin_id") int adminId);

  @POST("insert/addRegion")
  Future<dynamic> addRegion(@Body() Region region);

  @POST("insert/addProduct")
  Future<ProductResponse> addOrUpdateProduct(@Body() Product product);

  @DELETE("index/deleteProductSubTypes")
  Future<ProductResponse> deleteProductSubType(@Body() List<int> sub_item_ids);

  @DELETE("index/deleteEmployee/{emp_id}")
  Future<EmployeeLogin> deleteEmployee(@Path("emp_id") int empId);

  @MultiPart()
  @POST("upload/EmployeeIdProof")
  Future<dynamic> uploadEmployeeIdProof(
    @Part(name: "image") File images,
    @Part(name: "emp_id") String empId,
  );

  @MultiPart()
  @POST("upload/shopImage")
  Future<dynamic> uploadShopImage(
    @Part(name: "image") File image,
    @Part(name: "shop_id") String shopId,
  );

  // DELETE API
  @DELETE("index/deleteRegion/{region_id}/{company_id}")
  Future<dynamic> deleteRegion(
    @Path("region_id") int regionId,
    @Path("company_id") String companyId,
  );

  //EMPLOYEE API------------------------------------------------------------------------------------------------------------

  //GET API
  @GET("users/fetchEmployeeInfo/{mobile_no}")
  Future<List<EmployeeLogin>> fetchEmployeeInfo(
    @Path("mobile_no") String mobileNo,
  );

  @GET("users/employeeShopList/{company_id}/{region_id}/{type}")
  Future<List<ShopDetails>> getEmpShopList(
    @Path("company_id") String companyId,
    @Path("region_id") int regionID,
    @Path("type") int type,
  );

  @GET("users/current/{emp_id}")
  Future<List<CheckInStatusRequest>> fetchTodayAttendance(
    @Path("emp_id") int empId,
  );

  //Products
  @GET("users/productList/{company_id}")
  Future<List<Product>> fetchProductList(@Path("company_id") String companyId);

  @GET("users/getOrders/{emp_id}")
  Future<List<Order>> getOrders(@Path("emp_id") int empId);

  @GET("users/employeeVisits/{emp_id}")
  Future<List<EmployeeVisit>> getEmployeeVisits(@Path("emp_id") int empId);

  @GET("users/getEmployeeVisits/{emp_id}")
  Future<List<EmployeeMap>> getEmployeeVisit(@Path("emp_id") int empId);

  @GET("users/productReport/{company_id}")
  Future<List<ProductData>> productReport(@Path("company_id") String companyId);

  //POST API
  @MultiPart()
  @POST("insert/addShopDetails")
  Future<dynamic> addShopDetails(
    @Part(name: "shop_id") int? shopId,
    @Part(name: "shop_name") String? shopName,
    @Part(name: "owner_name") String? ownerName,
    @Part(name: "address") String? address,
    @Part(name: "mobile_no") String? mobileNo,
    @Part(name: "email") String? email,
    @Part(name: "region_id") int? regionId,
    @Part(name: "created_by") int? createdBy,
    @Part(name: "company_id") String? companyId,
    @Part(name: "latitude") double? latitude,
    @Part(name: "longitude") double? longitude,
    @Part(name: "type") int? type,
    @Part(name: "image") File? image,
  );

  @POST("insert/addLocation")
  Future<dynamic> addLocation(@Body() VisitPayload shopDetails);

  @POST("insert/checkIn/{emp_id}/{latitude}/{longitude}")
  Future<CheckInStatusRequest> checkIn(
    @Path("emp_id") int empId,
    @Path("latitude") double latitude,
    @Path("longitude") double longitude,
  );

  @POST("insert/checkOut/{emp_id}/{latitude}/{longitude}")
  Future<CheckInStatusRequest> checkOut(
    @Path("emp_id") int empId,
    @Path("latitude") double latitude,
    @Path("longitude") double longitude,
  );

  @POST("insert/addOrder")
  Future<dynamic> addOrder(@Body() Order product);

  @POST("insert/markDelivered")
  Future<dynamic> markDelivered(@Body() List<Map<String, dynamic>> payload);

  // DELETE API
  @DELETE("index/deleteShop/{shop_id}")
  Future<dynamic> deleteShop(@Path("shop_id") int shopId);
}

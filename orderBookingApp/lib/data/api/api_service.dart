import 'dart:io';

import 'package:dio/dio.dart';
import 'package:order_booking_app/core/constant.dart';
import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/domain/models/employee.dart';
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
  @GET("/")
  Future<HttpResponse> checkHealth();

  //POST METHODS
  @POST("login/CreateLogin")
  Future<TokenResponse> createLogin(@Body() TokenResponse tokenResponse);

  @POST("login/refreshAccessToken")
  Future<TokenResponse> refreshAccessToken(@Body() TokenResponse tokenResponse);

  @POST("insert/employee")
  Future<dynamic> addEmployee(@Body() EmployeeLogin employeeLogin);

  @GET("users/checkMobile/{company_id}/{emp_mobile}")
  Future<dynamic> checkMobileExists(
    @Path("emp_mobile") String empMobile,
    @Path("company_id") String companyId,
  );

  @POST("insert/addAdminDetails")
  Future<dynamic> addAdminDetails(@Body() AdminLogin adminLogin);

  @POST("insert/addRegion")
  Future<dynamic> addRegion(@Body() Region region);

  @POST("insert/addShopDetails")
  Future<dynamic> addShopDetails(@Body() ShopDetails shopDetails);

  @POST("insert/addLocation")
  Future<dynamic> addLocation(@Body() VisitPayload shopDetails);

  @POST("insert/addProduct")
  Future<ProductResponse> addOrUpdateProduct(@Body() Product product);

  @POST("insert/checkIn/{emp_id}/{latitude}/{longitude}")
  Future<CheckInStatusRequest> checkIn(
    @Path("emp_id") int empId,
    @Path("latitude") double latitude,
    @Path("longitude") double longitude,
  );

  @POST("insert/checkOut/{emp_id}/{latitude}/{longitude}")
  Future<CheckInStatusRequest> checkOut(@Path("emp_id") int empId,
    @Path("latitude") double latitude,
    @Path("longitude") double longitude,);

  //GET METHODS
  @GET("users/employeeList/{company_id}")
  Future<List<EmployeeLogin>> getEmployeeList(
    @Path("company_id") String companyId,
  );

  @GET("users/employeeDetails/{emp_id}")
  Future<List<EmployeeLogin>> fetchEmployeeDetails(@Path("emp_id") int empId);

  @GET("users/fetchEmployeeInfo/{mobile_no}")
  Future<List<EmployeeLogin>> fetchEmployeeInfo(
    @Path("mobile_no") String mobileNo,
  );

  @GET("users/adminDetails/{mobile_no}")
  Future<List<AdminLogin>> fetchAdminDetails(
    @Path("mobile_no") String mobileNo,
  );

  @GET("users/shopList/{company_id}")
  Future<List<ShopDetails>> getShopList(@Path("company_id") String companyId);

  @GET("users/employeeShopList/{company_id}/{region_id}")
  Future<List<ShopDetails>> getEmpShopList(
    @Path("company_id") String companyId,
    @Path("region_id") int regionID,
  );

  @GET("users/regionList/{company_id}")
  Future<List<Region>> fetchRegionList(@Path("company_id") String companyId);

  @GET("users/current/{emp_id}")
  Future<List<CheckInStatusRequest>> fetchTodayAttendance(
    @Path("emp_id") int empId,
  );

  //Login Check
  @GET("login/checkPhone")
  Future<List<LoginInfo>> CheckPhone(@Query("mobile_no") String mobileNo);

  //Products
  @GET("users/productList/{company_id}")
  Future<List<Product>> fetchProductList(@Path("company_id") String companyId);

  @GET("users/getOrders/{emp_id}")
  Future<List<Order>> getOrders(@Path("emp_id") int empId);

  @GET("users/employeeVisits/{emp_id}")
  Future<List<EmployeeVisit>> getEmployeeVisits(@Path("emp_id") int empId);

  //DELETE API
  @DELETE("index/deleteProductSubTypes")
  Future<ProductResponse> deleteProductSubType(@Body() List<int> sub_item_ids);

  @DELETE("index/deleteEmployee/{emp_id}")
  Future<EmployeeLogin> deleteEmployee(@Path("emp_id") int empId);

  @POST("insert/addOrder")
  Future<dynamic> addOrder(@Body() Order product);

  @GET("users/getAllOrders/{company_id}")
  Future<List<Order>> getOrderList(@Path("company_id") String companyId);

  @GET("users/getEmployeeLocationOrders/{emp_id}")
  Future<List<EmployeeVisit>> getEmployeeVisitLocation(@Path("emp_id") int empId);

  @GET("users/getEmployeeAttendance/{emp_id}")
  Future<List<CheckInStatusRequest>> getAttendance(@Path("emp_id") int emp_id);

  @GET("users/getEmployeeVisits/{emp_id}")
  Future<List<VisitPayload>> getEmployeeVisit(@Path("emp_id") int empId);

  @MultiPart()
  @POST("upload/EmployeeIdProof")
  Future<dynamic> uploadEmployeeIdProof(
    @Part(name: "image") File images,
    @Part(name: "emp_id") String empId,
  );
  @DELETE("index/deleteRegion/{region_id}/{company_id}")
  Future<dynamic> deleteRegion(
    @Path("region_id") int regionId,
    @Path("company_id") String companyId,
  );

  @DELETE("index/deleteShop/{shop_id}")
  Future<dynamic> deleteShop(@Path("shop_id") int shopId);


  @GET("users/productReport/{company_id}")
  Future<List<ProductData>> productReport(@Path("company_id") String companyId);
  
}



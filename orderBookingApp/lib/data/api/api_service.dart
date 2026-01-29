import 'package:dio/dio.dart';
import 'package:order_booking_app/core/constant.dart';
import 'package:order_booking_app/domain/models/checkin_status.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/domain/models/login_info.dart';
import 'package:order_booking_app/domain/models/models.dart';
import 'package:order_booking_app/domain/models/product_details.dart';
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

  @POST("insert/addAdminDetails")
  Future<dynamic> addAdminDetails(@Body() AdminLogin adminLogin);

  @POST("insert/addRegion")
  Future<dynamic> addRegion(@Body() Region region);

  @POST("insert/addShopDetails")
  Future<dynamic> addShopDetails(@Body() ShopDetails shopDetails);

  @POST("insert/addLocation")
  Future<dynamic> addLocation(@Body() VisitPayload shopDetails);




  @POST("users/checkIn/{emp_id}")
Future<void> checkIn(
  @Path("emp_id") int empId,
);


@POST("users/checkOut/{emp_id}")
Future<void> checkOut(
  @Path("emp_id") int empId,
);

@GET("users/current/{emp_id}")
Future<List<CheckInStatusRequest>> fetchTodayAttendance(
  @Path("emp_id") int empId,
);






//GET METHODS
  @GET("users/employeeList")
  Future<List<EmployeeLogin>> getEmployeeList();
  
  @GET("users/employeeDetails/{emp_id}")
  Future<List<EmployeeLogin>> fetchEmployeeDetails(
  @Path("emp_id") int empId,
);
 @GET("users/fetchEmployeeInfo/{mobile_no}")
  Future<List<EmployeeLogin>> fetchEmployeeInfo(
  @Path("mobile_no") String mobileNo
);

 @GET("users/adminDetails/{mobile_no}")
  Future<List<AdminLogin>> fetchAdminDetails(
  @Path("mobile_no") String mobileNo,
);

 @GET("users/shopList")
  Future<List<ShopDetails>> getShopList( );
  
  @GET("users/regionList")
  Future<List<Region>> fetchRegionList();
 
 //Login Check
  @GET("login/checkPhone")
  Future<List<LoginInfo>> CheckPhone(@Query("mobile_no") String mobileNo);


  //get product list for employee
@GET("users/getProductList/{admin_id}")
Future<List<ProductDetails>> getProductList(int adminId);


}
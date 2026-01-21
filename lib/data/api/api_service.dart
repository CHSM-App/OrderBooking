import 'package:dio/dio.dart';
import 'package:order_booking_app/core/constant.dart';
import 'package:order_booking_app/domain/models/employee_login.dart';
import 'package:order_booking_app/domain/models/token_response.dart';
import 'package:retrofit/retrofit.dart';
part 'api_service.g.dart';

@RestApi(baseUrl: baseUrl) // <-- replace with your base URL
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;
  @GET("/")
  Future<HttpResponse> checkHealth();


  @POST("login/CreateLogin")
  Future<TokenResponse> createLogin(@Body() TokenResponse tokenResponse);

  @POST("login/refreshAccessToken")
  Future<TokenResponse> refreshAccessToken(@Body() TokenResponse tokenResponse);

@POST("insert/employee")
Future<dynamic> addEmployee(@Body() EmployeeLogin employeeLogin);

@GET("users/employeeList")
  Future<List<EmployeeLogin>> getEmployeeList();
  
 
@GET("users/employeeDetails/{emp_id}")
 Future<List<EmployeeLogin>> fetchEmployeeDetails(
  @Path("emp_id") int empId,
);
}
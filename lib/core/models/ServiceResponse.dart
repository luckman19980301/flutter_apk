class ServiceResponse<T> {
  String? message;
  T? data;
  bool? success;

  ServiceResponse({this.message, this.data, this.success});
}
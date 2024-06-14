class ServiceResponse<T> {
  String? message;
  T? data;

  ServiceResponse({this.message, this.data});
}
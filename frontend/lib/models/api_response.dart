class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse<T>(success: true, message: message, data: data);
  }

  factory ApiResponse.error(String message) {
    return ApiResponse<T>(success: false, message: message);
  }
}

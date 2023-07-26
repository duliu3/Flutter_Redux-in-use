import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';

import '../code.dart';
import '../result_data.dart';

///是否需要弹提示
const NOT_TIP_KEY = "noTip";

class ErrorInterceptors extends InterceptorsWrapper {


  @override
  onRequest(RequestOptions options, handler) async {
    //没有网络
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return handler.reject(DioError(
          requestOptions: options,
          type: DioErrorType.other,
          response: Response(
              requestOptions: options,
              data: new ResultData(
                  Code.errorHandleFunction(Code.NETWORK_ERROR, "", false),
                  false,
                  Code.NETWORK_ERROR))));
    }
    return super.onRequest(options, handler);
  }
}

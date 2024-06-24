import 'package:http/http.dart' as http;
import 'package:ton_dart/src/provider/core/core.dart';
import 'package:ton_dart/src/provider/service/service.dart';

class HTTPProvider implements TonServiceProvider {
  HTTPProvider(
      {required this.tonApiUrl,
      required this.tonCenterUrl,
      http.Client? client,
      this.defaultRequestTimeout = const Duration(seconds: 30)})
      : client = client ?? http.Client();

  final String? tonApiUrl;
  final String? tonCenterUrl;
  final http.Client client;
  final Duration defaultRequestTimeout;

  @override
  Future<String> get(TonRequestInfo params, {Duration? timeout}) async {
    final response = await client.get(
        Uri.parse(params.url(tonApiUrl: tonApiUrl, tonCenterUrl: tonCenterUrl)),
        headers: {
          "Accept": "application/json",
          // make sure to append the header to the request. some method has specific header parameters
          ...params.header
        }).timeout(timeout ?? defaultRequestTimeout);
    return response.body;
  }

  @override
  Future<String> post(TonRequestInfo params, {Duration? timeout}) async {
    final url =
        Uri.parse(params.url(tonApiUrl: tonApiUrl, tonCenterUrl: tonCenterUrl));
    http.Response response;
    if (params.requestType == RequestMethod.put) {
      response = await client
          .put(url,

              /// make sure to append the header to the request. some method has specific header parameters
              headers: {"Accept": "application/json", ...params.header},
              body: params.body)
          .timeout(timeout ?? defaultRequestTimeout);
    } else {
      response = await client
          .post(
            url,

            /// make sure to append the header to the request. some method has specific header parameters
            headers: {
              if (params.apiType.isTonCenter)
                "X-API-Key":
                    "d3800f756738ac7b39599914b8a84465960ff869f555c2317664c9a62529baf3",
              "Accept": "application/json",
              "Content-Type": "application/json",
              ...params.header
            },
            body: params.body,
          )
          .timeout(timeout ?? defaultRequestTimeout);
    }
    return response.body;
  }

  @override
  TonApiType get api =>
      tonCenterUrl != null ? TonApiType.tonCenter : TonApiType.tonApi;
}

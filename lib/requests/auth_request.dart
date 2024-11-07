import 'dio_client.dart';

class AuthRequest extends DioClient {
  Future login({required Map data}) async {
    final client = await getApiClient();

    return client.post('login', data: {
      'user_info': data['login'],
      'password': data['password'],
    });
  }

  Future register({required Object data}) async {
    final client = await getApiClient();
    return await client.post('register', data: data);
  }

  Future logout() async {
    final client = await getApiClient();
    return client.delete('/auth/token/destroy');
  }
}

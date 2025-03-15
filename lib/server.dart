import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';

Middleware cors() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsh);
      }
      final response = await handler(request);
      return response.change(headers: _corsh);
    };
  };
}

final Map<String, String> _corsh = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': '*',
};
void main() async {
  try {
    var db = await Db.create(
        "mongodb+srv://karthk2642005:k1234@cluster0.xs2kf.mongodb.net/test?retryWrites=true&w=majority&appName=Cluster0");
    await db.open();

    var collection = db.collection('users');
    final router = Router();

    router.post('/val', (Request request) async {
      var getBody = await request.readAsString();
      var getData = jsonDecode(getBody);
      var email = getData['_id'] ?? '';
      var password = getData['password'] ?? '';
      if (email.isEmpty || password.isEmpty) {
        return Response.ok(
            jsonEncode(
                {'message': 'Please enter the credentials', 's_code': 0}),
            headers: {'Content-Type': 'application/json'});
      } else {
        Map<String, dynamic>? validate = await collection
            .findOne(where.eq('_id', email).eq('password', password));
        if (validate != null) {
          return Response.ok(
              jsonEncode({'message': 'Login sucessfull', 's_code': 1}),
              headers: {'Content-Type': 'application/json'});
        } else {
          return Response.ok(
              jsonEncode({
                'message': 'Username or password is incorrect',
                's_code': 2
              }),
              headers: {'Content-Type': 'application/json'});
        }
      }
    });

    router.post('/users', (Request request) async {
      var body = await request.readAsString();
      var regdata = jsonDecode(body);
      print('Raw request body: $body');
      var data = jsonDecode(body);
      var id = regdata['_id'] ?? '';
      var name = regdata['name'] ?? '';
      var pass = regdata['password'] ?? '';

      Map<String, dynamic>? if_exists =
          await collection.findOne(where.eq('_id', id));
      if (id.isEmpty || name.isEmpty || pass.isEmpty) {
        return Response.ok(
            jsonEncode({'message': 'Please enter credentials', 's_code': 0}),
            headers: {'Content-Type': 'application/json'});
      } else if (if_exists == null) {
        await collection.insertOne(data);
        return Response.ok(jsonEncode({'message': 'user added', 's_code': 1}),
            headers: {'Content-Type': 'application/json'});
      }
    });
    router.post('/event', (Request request) async {
      var body1 = await request.readAsString();
      var res = jsonDecode(body1);
      var email_id = res['_id'] ?? '';
      Map<String, dynamic>? check =
          await collection.findOne(where.eq('_id', email_id));

      if (!email_id.isEmpty && check != null) {
        return Response.ok(
            jsonEncode({'message': 'Username already exists', 's_code': 1}),
            headers: {'Content-Type': 'application/json'});
      } else {
        return Response.ok(jsonEncode({'s_code': 0}),
            headers: {'Content-Type': 'application/json'});
      }
    });
    router.post('/getname', (Request request) async {
      var data = await request.readAsString();
      var bodyforname = jsonDecode(data);
      Map<String, dynamic>? result =
          await collection.findOne(where.eq('_id', bodyforname['_id']));
      print(result?['name']);

      return Response.ok(jsonEncode({'name': result!['name']}),
          headers: {'Content-Type': 'application/json'});
    });
    var handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(cors())
        .addHandler(router);
    var server = await shelf_io.serve(
      handler,
      'localhost',
      8080,
    );
  } catch (e) {
    print('Exception : $e');
  }
  print('server running');
}

import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/http.dart';
import 'package:angel_build_runner/angel_build_runner.dart';
import '../.dart_tool/build/entrypoint/build.dart';

main() async {
  var app = new Angel();
  var http = new AngelHttp(app);

  // Pull from our build script.
  var build = new BuildServer(builders, rootDir: 'web');
  app.fallback(build.handleRequest);

  await http.startServer('127.0.0.1', 3000);
  print('Listening at ${http.uri}');
}
import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_shelf/angel_shelf.dart';
import 'package:build_runner/src/entrypoint/options.dart';
import 'package:build_runner/src/generate/build.dart';
import 'package:build_runner/src/server/server.dart';
import 'package:build_runner_core/build_runner_core.dart';

class BuildServer {
  final List<String> buildDirs;
  final String rootDir;
  final List<BuilderApplication> builderApplications;
  final BuildUpdatesOption buildUpdates;
  ServeHandler _handler;
  RequestHandler _wrapped;
  bool _initialized = false;

  BuildServer(this.builderApplications,
      {this.buildDirs: const [],
      this.rootDir: '.',
      this.buildUpdates: BuildUpdatesOption.none});

  Future _init() async {
    if (!_initialized) {
      var packageGraph = new PackageGraph.forThisPackage();
      _handler = await watch(
        builderApplications,
        deleteFilesByDefault: true,
        enableLowResourcesMode: false,
        configKey: null,
        outputMap: {},
        outputSymlinksOnly: false,
        packageGraph: packageGraph,
        trackPerformance: false,
        skipBuildScriptCheck: false,
        verbose: false,
        builderConfigOverrides: {},
        isReleaseBuild: false,
        buildDirs: buildDirs,
        logPerformanceDir: null,
      );
      _wrapped =
          embedShelf(_handler.handlerFor(rootDir, buildUpdates: buildUpdates));
    }
  }

  Future<bool> handleRequest(RequestContext req, ResponseContext res) async {
    await _init();
    return await _wrapped(req, res);
  }
}

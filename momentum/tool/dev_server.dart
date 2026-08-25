import 'dart:io';

const _mimeByExtension = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.mjs': 'application/javascript',
  '.wasm': 'application/wasm',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.css': 'text/css',
};

Future<void> main(List<String> args) async {
  final root = Directory(args.isNotEmpty ? args[0] : 'build/web');
  final port = args.length > 1 ? int.parse(args[1]) : 8377;

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('serving ${root.path} on http://localhost:$port');

  await for (final request in server) {
    final path = request.uri.path == '/' ? '/index.html' : request.uri.path;
    final file = File('${root.path}$path');

    if (await file.exists()) {
      final extension = path.substring(path.lastIndexOf('.'));
      final mime = _mimeByExtension[extension] ?? 'application/octet-stream';
      final bytes = await file.readAsBytes();
      request.response.headers.contentType = ContentType.parse(mime);
      await request.response.addStream(Stream.value(bytes));
    } else {
      request.response.statusCode = HttpStatus.notFound;
    }
    await request.response.close();
  }
}

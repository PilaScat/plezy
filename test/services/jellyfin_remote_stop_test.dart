import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:plezy/services/jellyfin_client.dart';
import 'package:plezy/services/library_events/media_browser_library_event_socket.dart';
import 'package:plezy/utils/remote_stop_notifier.dart';

import '../test_helpers/backend_client_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final (name, build) in [('Jellyfin', testJellyfinClient), ('Emby', testEmbyClient)]) {
    group(name, () {
      late List<http.Request> requests;
      late JellyfinClient client;
      late MediaBrowserLibraryEventSocket socket;

      setUp(() {
        requests = [];
        client = build(
          handler: (request) async {
            requests.add(request);
            return http.Response('', 204);
          },
        );
        socket = client.createLibraryEventChannel()! as MediaBrowserLibraryEventSocket;
        addTearDown(socket.dispose);
      });

      test('the session advertises media control and no other command', () async {
        await socket.registerCapabilities!();

        final request = requests.single;
        expect(request.url.path, endsWith('/Sessions/Capabilities/Full'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['SupportsMediaControl'], isTrue);
        expect(body['SupportedCommands'], isEmpty);
      });

      test('a Stop is published for this server with its message', () async {
        final stops = <RemoteStop>[];
        final subscription = RemoteStopNotifier().stream.listen(stops.add);
        addTearDown(subscription.cancel);

        socket.onRemoteStop!('Transcoding 4K for nobody');
        socket.onRemoteStop!(null);
        await Future<void>.delayed(Duration.zero);

        expect(stops.map((stop) => stop.serverId), [client.serverId, client.serverId]);
        expect(stops.map((stop) => stop.message), ['Transcoding 4K for nobody', null]);
      });
    });
  }
}

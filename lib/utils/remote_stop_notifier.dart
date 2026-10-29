import '../media/ids.dart';
import 'base_notifier.dart';

class RemoteStop {
  const RemoteStop(this.serverId, {this.message});

  final ServerId serverId;
  final String? message;
}

class RemoteStopNotifier extends BaseNotifier<RemoteStop> {
  static final RemoteStopNotifier _instance = RemoteStopNotifier._internal();

  factory RemoteStopNotifier() => _instance;

  RemoteStopNotifier._internal();

  void notifyStop(RemoteStop stop) => notify(stop);
}

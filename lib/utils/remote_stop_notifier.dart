import '../media/ids.dart';
import 'base_notifier.dart';

class RemoteStopNotifier extends BaseNotifier<ServerId> {
  static final RemoteStopNotifier _instance = RemoteStopNotifier._internal();

  factory RemoteStopNotifier() => _instance;

  RemoteStopNotifier._internal();

  void notifyStop(ServerId serverId) => notify(serverId);
}

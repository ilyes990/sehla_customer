import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../core/enums_view_state.dart';

class BaseViewModel extends ChangeNotifier {
  ViewState state = ViewState.Idle;

  void changeState(ViewState viewState) {
    state = viewState;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }
}

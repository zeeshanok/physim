// from https://github.com/flame-engine/flame/blob/611e20b80b358662f89bff0549cc2098868d0f2f/packages/flame/lib/src/game/game_loop.dart

import 'package:flutter/scheduler.dart';

class GameLoop {
  void Function(double dt) callback;
  Duration previous = Duration.zero;
  late Ticker _ticker;

  GameLoop(this.callback) {
    _ticker = Ticker(_tick);
  }

  bool get paused => _ticker.muted;

  void _tick(Duration timestamp) {
    final dt = _computeDeltaT(timestamp);
    callback(dt);
  }

  double _computeDeltaT(Duration now) {
    final delta = previous == Duration.zero ? Duration.zero : now - previous;
    previous = now;
    return delta.inMicroseconds / Duration.microsecondsPerSecond;
  }

  void start() {
    _ticker.start();
  }

  void stop() {
    _ticker.stop();
  }

  void dispose() {
    _ticker.dispose();
  }

  void pause() {
    _ticker.muted = true;
    previous = Duration.zero;
  }

  void resume() {
    _ticker.muted = false;
    // If the game has started paused, we need to start the ticker
    // as it would not have been started yet
    if (!_ticker.isActive) {
      start();
    }
  }
}

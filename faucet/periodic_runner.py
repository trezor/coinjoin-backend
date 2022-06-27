import threading


class PeriodicRunner:
    def __init__(self):
        self.timer = None
        self.lock = threading.Lock()

    def start(self, interval_in_seconds, action):
        def _action():
            action()
            with self.lock:
                self.timer = threading.Timer(interval_in_seconds, _action)
                self.timer.daemon = True;
                self.timer.start()

        self.stop()
        _action()

    def stop(self):
        with self.lock:
            if self.timer is not None:
                self.timer.cancel()
                self.timer = None

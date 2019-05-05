# SystemD util

Minimal dynamic bindings for `libsystemd.so`:

* `int sd_notify(int unset_environment, const char* state)`
* `int sd_pid_notify(pid_t pid, int unset_environment, const char *state)`
* `int sd_journal_print(int priority, const char* fmt, ...)`
* `int sd_journal_send(const char* fmt, ...)`
* `int sd_journal_perror(const char *message)`

with minimal wraps:

* `int sdNotify(int unset_environment, string state)`
* `int sdNotify_ready(int unset_environment=0) @nogc` send `state="READY=1"`
* `int sdNotify_reloading(int unset_environment=0) @nogc` send `state="RELOADING=1"`
* `int sdNotify_stopping(int unset_environment=0) @nogc` send `state="STOPPING=1"`
* `int sdNotify_watchdog(int unset_environment=0) @nogc` send `state="WATCHDOG=1"`
* `int sdPidNotify(pid_t pid, int unset_environment, string state)`
* `int sdNotifyf(Args...)(int unset_environment, string fmt, Args args)` with D `format`
* `int sdPidNotifyf(Args...)(pid_t pid, int unset_environment, string fmt, Args args)` with D `format`

and 2 `std.experimental.logger.Logger` implementations:

* `SDSimpleLogger` not use `libsystemd`, only specific format output to `stderr`
* `SDJournalLogger` use `sd_journal_print` in `writeLogMsg` and call `initSystemDLib` in ctor

See [example](example)
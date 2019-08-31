/// systemd/sd-daemon.h
module systemd.daemon;

import systemd.base;

import std.string : toStringz, format;

public alias pid_t = size_t;
public import core.sys.posix.sys.socket : sockaddr;

mixin SSLL_INIT;

@api("lib") @nogc
{
    ///
    int sd_listen_fds(int unset_environment) { mixin(SSLL_CALL); }
    ///
    int sd_listen_fds_with_names(int unset_environment, char*** names) { mixin(SSLL_CALL); }
    ///
    int sd_is_fifo(int fd, const char* path) { mixin(SSLL_CALL); }
    ///
    int sd_is_special(int fd, const char* path) { mixin(SSLL_CALL); }
    ///
    int sd_is_socket(int fd, int family, int type, int listening) { mixin(SSLL_CALL); }
    ///
    int sd_is_socket_inet(int fd, int family, int type, int listening, ushort port) { mixin(SSLL_CALL); }
    ///
    int sd_is_socket_sockaddr(int fd, int type, const sockaddr* addr, uint addr_len, int listening) { mixin(SSLL_CALL); }
    ///
    int sd_is_socket_unix(int fd, int type, int listening, const char* path, size_t length) { mixin(SSLL_CALL); }
    ///
    int sd_is_mq(int fd, const char* path) { mixin(SSLL_CALL); }

    ///
    int sd_notify(int unset_environment, const char* state) { mixin(SSLL_CALL); }

    extern (C) // because variablic arguments
    {
        ///
        pragma(mangle, "sdutil_sd_notifyf") // because extern(C)
        int sd_notifyf(int unset_environment, const char* format, ...) { mixin(SSLL_CALL); }

        ///
        pragma(mangle, "sdutil_sd_pid_notifyf")
        int sd_pid_notifyf(pid_t pid, int unset_environment, const char* format, ...) { mixin(SSLL_CALL); }
    }

    ///
    int sd_pid_notify(pid_t pid, int unset_environment, const char* state) { mixin(SSLL_CALL); }
    ///
    int sd_pid_notify_with_fds(pid_t pid, int unset_environment, const char* state, const int* fds, uint n_fds) { mixin(SSLL_CALL); }
    ///
    int sd_booted() { mixin(SSLL_CALL); }
    ///
    int sd_watchdog_enabled(int unset_environment, ulong* usec) { mixin(SSLL_CALL); }
}

///
int sdNotify(int unset_environment, string state)
{ return sd_notify(unset_environment, state.toStringz); }

/// shortcut 
int sdNotify_ready(int unset_environment=0) @nogc
{ return sd_notify(unset_environment, "READY=1"); }

/// ditto
int sdNotify_reloading(int unset_environment=0) @nogc
{ return sd_notify(unset_environment, "RELOADING=1"); }

/// ditto
int sdNotify_stopping(int unset_environment=0) @nogc
{ return sd_notify(unset_environment, "STOPPING=1"); }

/// ditto
int sdNotify_watchdog(int unset_environment=0) @nogc
{ return sd_notify(unset_environment, "WATCHDOG=1"); }

/// ditto
int sdNotify_status(int unset_environment, string status)
{ return sd_notify(unset_environment, format!"STATUS=%s"(status).toStringz); }

/// ditto
int sdNotify_status(string status) { return sdNotify_status(0, status); }

///
int sdPidNotify(pid_t pid, int unset_environment, string state)
{ return sd_pid_notify(pid, unset_environment, state.toStringz); }

///
int sdNotifyf(Args...)(int unset_environment, string fmt, Args args)
{ return sd_notify(unset_environment, format(fmt, args).toStringz); }

///
int sdPidNotifyf(Args...)(pid_t pid, int unset_environment, string fmt, Args args)
{ return sd_pid_notify(pid, unset_environment, format(fmt, args).toStringz); }

///
bool sdBooted()
{
    const r = sd_booted();
    if (r == 0) return false;
    else if (r > 0) return true;
    else throw new Exception(format!"error (%d)"(r));
}

import std.datetime : Duration;

///
Duration sdWatchdogEnabled(int unset_environment=0)
{
    import std.datetime : usecs;

    ulong u;
    const r = sd_watchdog_enabled(unset_environment, &u);
    if (r == 0) return Duration.zero;
    else if (r > 0) return u.usecs;
    else throw new Exception(format!"error (%d)"(r));
}
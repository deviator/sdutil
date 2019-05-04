module sdnotify;

import ssll;

import std.exception : enforce;
import std.string : toStringz, format;

private enum libNames = [
    "libsystemd.so",
    "libsystemd.so.0"
];

private __gshared void* lib;

alias pid_t = size_t;

///
void initSystemDLib()
{
    if (lib !is null) return;
    foreach (name; libNames)
    {
        lib = loadLibrary(name);
        if (lib !is null) break;
    }
    enforce(lib, "can't load systemd lib");
    loadApiSymbols();
}

///
void cleanupSystemDLib() { unloadLibrary(lib); }

mixin apiSymbols;

@api("lib") @nogc
{
    int sd_notify(int unset_environment, const char* state) { mixin(rtLib); }
    int sd_pid_notify(pid_t pid, int unset_environment, const char *state) { mixin(rtLib); }

    extern (C) // because variablic arguments
    {
        pragma(mangle, "sdutil_dlib_sd_journal_print") // because extern(C)
        int sd_journal_print(int priority, const char* fmt, ...) { mixin(rtLib); }

        pragma(mangle, "sdutil_dlib_sd_journal_send")
        int sd_journal_send(const char* fmt, ...) { mixin(rtLib); }
    }

    int sd_journal_perror(const char *message) { mixin(rtLib); }
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

///
int sdPidNotify(pid_t pid, int unset_environment, string state)
{ return sd_pid_notify(pid, unset_environment, state.toStringz); }

///
int sdNotifyf(Args...)(int unset_environment, string fmt, Args args)
{ return sd_notify(unset_environment, format(fmt, args)); }

///
int sdPidNotifyf(Args...)(pid_t pid, int unset_environment, string fmt, Args args)
{ return sd_pid_notify(pid, unset_environment, format(fmt, args)); }
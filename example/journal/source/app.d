import std.stdio;

import systemd;

import core.thread;

import mod;
import mod2;

void main()
{
    initSystemDLib();

    // started as systemd service if return code > 0
    if (sdNotify_status("loading"))
        sharedLog = new SDJournalLogger;
    // else use default logger

    stderr.writeln("watchdog: ", sdWatchdogEnabled());

    info("start loading");

    Thread.sleep(250.msecs);

    info("finish loading"); 
    sdNotify_ready();

    trace("test trace");
    info("test info");
    warning("test warning");
    error("test error");
    critical("test critical");

    warning("multi\nline\nwarning");

    foo();
    mod2foo();
    mod2pac1foo();
    mod2mod3foo();

    foreach (i; 0 .. 10)
    {
        trace("some trace info with data ", i);
        sdNotify_watchdog();
        Thread.sleep(250.msecs);
    }

    warning("start reloading");
    Thread.sleep(250.msecs);

    info("finish reloading");
    sdNotify_ready();

    foreach (i; 0 .. 10)
    {
        trace("at this loop app must be killed with watchdog because sleep is > 1 sec");
        sdNotify_watchdog();
        Thread.sleep(2500.msecs);
    }

    info("start stop service");
    sdNotify_stopping();
    info("finish stop service");
}
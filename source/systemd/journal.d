// systemd/sd-journal.h
module systemd.journal;

import systemd.base;

public import core.sys.posix.sys.uio : iovec;

mixin SSLL_INIT;

@api("lib") @nogc
{
    extern (C) // because variablic arguments
    {
        ///
        pragma(mangle, "sdutil_sd_journal_print") // because extern(C)
        int sd_journal_print(int priority, const char* fmt, ...) { mixin(SSLL_CALL); }

        //int sd_journal_printv(int priority, const char *format, va_list ap) _sd_printf_(2, 0);

        ///
        pragma(mangle, "sdutil_sd_journal_send")
        int sd_journal_send(const char* fmt, ...) { mixin(SSLL_CALL); }
    }

    ///
    int sd_journal_sendv(const iovec* buf, int count) { mixin(SSLL_CALL); }
    ///
    int sd_journal_perror(const char* message) { mixin(SSLL_CALL); }
}
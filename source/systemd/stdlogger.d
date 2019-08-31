module systemd.stdlogger;

public import std.experimental.logger;

import std.format : formattedWrite;
import std.array : Appender;
import std.algorithm : findSplitAfter;
import std.string : lineSplitter, startsWith;
import std.stdio : stderr;

/++ SD Simple Logger

    Used stderr for output with systemd specific syntax.

    For using: `sharedLog = new SDSimpleLogger;`
 +/
class SDSimpleLogger : Logger
{
    int[LogLevel] levelRemap;

    Appender!(char[]) buffer;

    string fileNameProc(string f) const @safe pure
    { return f.findSplitAfter("source/")[1]; }

    this(LogLevel ll=LogLevel.all)
    {
        super(ll);
        //                              journald codes
        levelRemap[LogLevel.all]      = 7;
        levelRemap[LogLevel.trace]    = 7; // debug
        //                              6     info 
        levelRemap[LogLevel.info]     = 5; // notice
        levelRemap[LogLevel.warning]  = 4; // warning
        levelRemap[LogLevel.error]    = 3; // error
        levelRemap[LogLevel.critical] = 2; // crit
        levelRemap[LogLevel.fatal]    = 1; // alert
        levelRemap[LogLevel.off]      = 1;
        levelRemap.rehash();

        buffer.reserve(1024);
    }

    override void writeLogMsg(ref LogEntry p) @trusted
    {
        buffer.clear();
        bool fline = true;
        foreach (ln; p.msg.lineSplitter)
        {
            if (fline)
            {
                fline = false;
                formattedWrite(buffer, "<%d>[%s:%d] %s",
                            levelRemap[p.logLevel],
                            fileNameProc(p.file), p.line,
                            ln);
            }
            else formattedWrite(buffer, "\n<%d>  %s", ln);
        }
        stderr.writeln(buffer.data);
    }
}

/++ SD Simple Logger

    Used sd_journal_print for output.

    For using: `sharedLog = new SDJournalLogger;`
 +/
class SDJournalLogger : SDSimpleLogger
{
    import systemd.base;
    import systemd.journal;

    Appender!(char[])[8] bufs;

    this(LogLevel ll=LogLevel.all)
    {
        super(ll);
        bufs[0] = buffer;
        foreach (ref b; bufs) b.reserve(128);

        // if not inited
        initSystemDLib();
    }

    Appender!(char[]) buffer_priority, buffer_line;

    override void writeLogMsg(ref LogEntry p) @trusted
    {
        foreach (ref b; bufs) b.clear();

        formattedWrite(bufs[0], "MESSAGE=%s", p.msg);
        formattedWrite(bufs[1], "PRIORITY=%s", levelRemap[p.logLevel]);
        formattedWrite(bufs[2], "CODE_FILE=%s", fileNameProc(p.file));
        formattedWrite(bufs[3], "CODE_LINE=%s", p.line);
        formattedWrite(bufs[4], "CODE_FUNC=%s", p.prettyFuncName);
        formattedWrite(bufs[5], "CODE_MODULE=%s", p.moduleName);
        formattedWrite(bufs[6], "CODE_MODULE0=%s", p.moduleName.getUntil("."));
        formattedWrite(bufs[7], "CODE_MODULE1=%s", p.moduleName.getUntil(".",1));

        iovec[bufs.length] iv;

        foreach (i, ref v; iv)
        {
            v.iov_base = bufs[i].data.ptr;
            v.iov_len = cast(int)bufs[i].data.length;
        }

        sd_journal_sendv(iv.ptr, cast(int)iv.length);
    }
}

private string getUntil(string orig, string fnd, int skip=0) @nogc @safe
{
    foreach (i, ch; orig)
    {
        if (orig[i..$].startsWith(fnd))
        {
            if (skip <= 0) return orig[0..i];
            skip--;
        }
    }
    return orig;
}

unittest
{
    assert("abc".getUntil(".") == "abc");
    assert("abc.def".getUntil(".") == "abc");
    assert("abc.def.ij".getUntil(".") == "abc");
    assert("abc.def.ij".getUntil(".",1) == "abc.def");
    assert("abc.def.ij.aaa".getUntil(".",1) == "abc.def");
    assert("abc.def.ij.aaa".getUntil(".",2) == "abc.def.ij");
    assert("abc.def.ij.aaa".getUntil(".",10) == "abc.def.ij.aaa");
}
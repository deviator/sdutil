module sdlogger;

public import std.experimental.logger;

import std.format : formattedWrite;
import std.array : Appender;
import std.algorithm : findSplitAfter;

/++ SD Simple Logger

    Used stderr for output with systemd specific syntax.

    For using: `sharedLog = new SDSimpleLogger;`
 +/
class SDSimpleLogger : Logger
{
    int[LogLevel] levelRemap;

    Appender!(char[]) buffer;

    this(LogLevel ll=LogLevel.all)
    {
        super(ll);
        levelRemap[LogLevel.all]      = 7;
        levelRemap[LogLevel.trace]    = 7;
        levelRemap[LogLevel.info]     = 6;
        // no "notice" (5) level in std.experimental.logger
        levelRemap[LogLevel.warning]  = 4;
        levelRemap[LogLevel.error]    = 3;
        levelRemap[LogLevel.critical] = 2;
        levelRemap[LogLevel.fatal]    = 1;
        levelRemap[LogLevel.off]      = 1;
        levelRemap.rehash();

        buffer.reserve(1024);
    }

    override void writeLogMsg(ref LogEntry p) @trusted
    {
        import std.stdio : stderr;
        buffer.clear();
        formattedWrite(buffer, "<%d>[%s:%d] %s",
                    levelRemap[p.logLevel],
                    p.file.findSplitAfter("source/")[1], p.line,
                    p.msg);
        stderr.writeln(buffer.data);
    }
}

/++ SD Simple Logger

    Used sd_journal_print for output.

    For using: `sharedLog = new SDJournalLogger;`
 +/
class SDJournalLogger : SDSimpleLogger
{
    import sdnotify;

    this(LogLevel ll=LogLevel.all)
    {
        super(ll);
        initSystemDLib();
    }

    override void writeLogMsg(ref LogEntry p) @trusted
    {
        buffer.clear();
        formattedWrite(buffer, "[%s:%d] %s",
                    p.file.findSplitAfter("source/")[1], p.line, p.msg);
        sd_journal_print(levelRemap[p.logLevel], "%.*s",
                            cast(int)buffer.data.length,
                            buffer.data.ptr);
    }
}

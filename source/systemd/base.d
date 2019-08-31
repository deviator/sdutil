module systemd.base;

package import ssll;

package import std.string : toStringz, format;

private enum libNames = [
    "libsystemd.so",
    "libsystemd.so.0"
];

package __gshared void* lib;

///
void initSystemDLib()
{
    if (lib !is null) return;

    foreach (name; libNames)
    {
        lib = loadLibrary(name);
        if (lib !is null) break;
    }

    if (lib is null)
        assert(0, "can't load systemd lib");

    static import systemd.daemon;
    systemd.daemon.loadApiSymbols(LoadApiSymbolsVerbose.assertion);

    static import systemd.journal;
    systemd.journal.loadApiSymbols(LoadApiSymbolsVerbose.assertion);
}

///
void cleanupSystemDLib() { unloadLibrary(lib); }
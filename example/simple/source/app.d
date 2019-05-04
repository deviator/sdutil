import sdlogger;

void main()
{
    sharedLog = new SDSimpleLogger;
    log("log");
    trace("trace");
    info("info");
    warning("warning");
    error("error");
    critical("critical");
}
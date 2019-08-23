For `void mod2.pac1.mod2pac1foo()`

    CODE_MODULE=mod2.pac1
    CODE_MODULE0=mod2
    CODE_MODULE1=mod2.pac1

For `void mod2.pac1.some.thing.foo()`

    CODE_MODULE=mod2.pac1.some.thing
    CODE_MODULE0=mod2
    CODE_MODULE1=mod2.pac1

Example greps:

    journalctl -e -u example CODE_MODULE1=mod2.mod3 -p err
    journalctl -e -u example CODE_MODULE0=mod2 -p 4
    journalctl -e -u example CODE_MODULE=mod2.pac1
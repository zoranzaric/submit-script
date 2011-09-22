#!/usr/bin/env python
from telnetlib import Telnet
import sys

def submit(flag):
    t = Telnet("localhost", 8888)
    t.read_very_eager()

    t.write(flag)
    result = t.read_very_eager()
    if result == "nope...\n\n":
        print "no"
    elif result == "KTHXBYE!\n\n":
        print "yes"
    elif result == "U MAD?!\n\n":
        print "..."

    t.close()

if __name__ == '__main__':
    if sys.stdin.isatty():
        flags = sys.argv[1:]
    else:
        flags = [line[0:-1] for line in sys.stdin]

    for flag in flags:
        submit(flag)


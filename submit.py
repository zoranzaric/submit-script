#!/usr/bin/env python
from telnetlib import Telnet
import sys

class Submitter():
    def __init__(self):
        self.t = Telnet("10.11.0.1", 1)
        self.t.read_very_eager()


    def submit(self, flag):
        self.t.write(flag)
        result = self.t.read_very_eager()
        if result.strip() == "Invalid flag.":
            print "no"
        elif result.strip() == "Congratulations, you scored a point!":
            print "yes"
        elif result.strip() == "U MAD?!\n\n":
            print "..."


if __name__ == '__main__':
    if sys.stdin.isatty():
        flags = sys.argv[1:]
    else:
        flags = [line[0:-1] for line in sys.stdin]

    submitter = Submitter()

    for flag in flags:
        submitter.submit(flag)


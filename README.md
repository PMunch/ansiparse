ansiparse
=========

This super small module is indented to correctly parse ANSI escape sequences to
be then interpreted. Currently only Control Sequence Introducer sequnces are
supported (these are the ones that are used for terminal colours and cursor
movement). To parse a string with ANSI escape sequences in it, simply do

``` Nim
parseANSI("Hello \e[31;5mworld\e[m")
```

The `parseANSI` procedure takes a string and returns a sequence of variant
objects that can either have `kind == String` and a `str` field with the string
value, or a `kind == CSI` and have the `parameter`, `intermediate`, and `final`
fields set to strings containing the valid values according to this:
https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_sequences


# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import ansiparse
test "String only":
  let res = parseAnsi("hello world")
  check res.len == 1
  check res[0].kind == String
  check res[0].str == "hello world"

test "Escape only":
  let res = parseAnsi("\e[100m")
  check res.len == 1
  check res[0].kind == CSI
  check res[0].parameters == "100"
  check res[0].intermediate == ""
  check res[0].final == 'm'

test "Escape at start":
  let res = parseAnsi("\e[100mHello world")
  check res.len == 2
  check res[0].kind == CSI
  check res[0].parameters == "100"
  check res[0].intermediate == ""
  check res[0].final == 'm'
  check res[1].kind == String
  check res[1].str == "Hello world"

test "Escape at end":
  let res = parseAnsi("Hello world\e[100m")
  check res.len == 2
  check res[0].kind == String
  check res[0].str == "Hello world"
  check res[1].kind == CSI
  check res[1].parameters == "100"
  check res[1].intermediate == ""
  check res[1].final == 'm'

test "String with colour":
  let res = parseAnsi("hello \e[100mthere\e[m world")
  check res.len == 5
  check res[0].kind == String
  check res[0].str == "hello "
  check res[1].kind == CSI
  check res[1].parameters == "100"
  check res[1].intermediate == ""
  check res[1].final == 'm'
  check res[2].kind == String
  check res[2].str == "there"
  check res[3].kind == CSI
  check res[3].parameters == ""
  check res[3].intermediate == ""
  check res[3].final == 'm'
  check res[4].kind == String
  check res[4].str == " world"

test "Start after end":
  let res = parseAnsi("\e[m\e[100m")
  check res.len == 2
  check res[0].kind == CSI
  check res[0].parameters == ""
  check res[0].intermediate == ""
  check res[0].final == 'm'
  check res[1].kind == CSI
  check res[1].parameters == "100"
  check res[1].intermediate == ""
  check res[1].final == 'm'



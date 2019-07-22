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

test "String with colour":
  let res = parseAnsi("hello \e[100mthere\e[m world")
  echo res
  check res.len == 5
  check res[0].kind == String
  check res[0].str == "hello "
  check res[1].kind == Escape
  check res[1].parameters == "100"
  check res[1].intermediate == ""
  check res[1].final == 'm'

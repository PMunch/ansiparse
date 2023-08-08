type
  AnsiDataKind* = enum
    String, CSI
  AnsiData* = object
    case kind*: AnsiDataKind
    of String:
      str*: string
    of CSI:
      parameters*: string
      intermediate*: string
      final*: char
  AnsiParseError* = object of CatchableError
    position*: int
  FinalByteError* = object of AnsiParseError
  UnknownEscapeError* = object of AnsiParseError

proc parseAnsi*(input: string): seq[AnsiData] =
  ## This procedure will take a string and parse it into a sequence of AnsiData
  ## elements that split the string in string parts and ANSI escape code parts.
  var
    lastpos = 0
    pos = 0
  while pos < input.len:
    if input[pos] == 0x1b.char and pos+1 < input.len:
      if input[pos+1] == '[':
        if lastpos != pos:
          result.add AnsiData(kind: String, str: input[lastpos..<pos])
        pos += 2
        lastpos = pos
        result.add AnsiData(kind: CSI)
        while input[pos] in {0x30.char..0x3F.char}:
          pos += 1
        result[^1].parameters = input[lastpos..<pos]
        lastpos = pos
        while input[pos] in {0x20.char..0x2F.char}:
          pos += 1
        result[^1].intermediate = input[lastpos..<pos]
        if input[pos] notin {0x40.char..0x7E.char}:
          var err = newException(FinalByteError, "Final byte of sequence at position " & $pos & " not in range 0x40-0x7E is " & $input[pos].byte)
          err.position = pos
          raise err
        result[^1].final = input[pos]
        lastpos = pos + 1
      else:
        var err = newException(UnknownEscapeError, "Unknown escape sequence at position " & $pos & ", currently only CSI sequences are recognised")
        err.position = pos
        raise err
    pos += 1

  if lastpos != input.len:
    result.add AnsiData(kind: String, str: input[lastpos..^1])

proc validAnsi*(input: string): bool =
  ## This procedure will take a string and verify if all recognised ANSI tags
  ## are properly formed.
  var
    lastpos = 0
    pos = 0
  while pos < input.len:
    if input[pos] == 0x1b.char and pos+1 < input.len:
      if input[pos+1] == '[':
        pos += 2
        lastpos = pos
        while input[pos] in {0x30.char..0x3F.char}:
          pos += 1
        lastpos = pos
        while input[pos] in {0x20.char..0x2F.char}:
          pos += 1
        if input[pos] notin {0x40.char..0x7E.char}:
          return false
        lastpos = pos + 1
      else:
        return false
    pos += 1
  return true

proc toString*(input: seq[AnsiData], stripAnsi = false): string =
  ## Converts the result of `parseAnsi` back into a string. The `stripAnsi`
  ## argument can be used to decide if the ANSI escapes codes are output in the
  ## string or not.
  for part in input:
    case part.kind:
    of String:
      result.add part.str
    of CSI:
      if not stripAnsi:
        result.add "\e[" & part.parameters & part.intermediate & $part.final

proc textLen*(ansiSequence: seq[AnsiData]): int =
  ## Returns the length of the string without counting the ANSI escape codes.
  for part in ansiSequence:
    if part.kind == String:
      result += part.str.len

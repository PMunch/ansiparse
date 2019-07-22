type
  AnsiDataKind* = enum
    String, Escape
  AnsiData* = object
    case kind*: AnsiDataKind
    of String:
      str*: string
    of Escape:
      parameters*: string
      intermediate*: string
      final*: char

proc parseAnsi*(input: string): seq[AnsiData] =
  var
    lastpos = 0
    pos = 0
  while pos < input.len:
    if input[pos] == 0x1b.char and pos+1 < input.len and input[pos+1] == '[':
      result.add AnsiData(kind: String, str: input[lastpos..<pos])
      pos += 2
      lastpos = pos
      result.add AnsiData(kind: Escape)
      while input[pos] in {0x30.char..0x3F.char}:
        pos += 1
      result[^1].parameters = input[lastpos..<pos]
      lastpos = pos
      while input[pos] in {0x20.char..0x2F.char}:
        pos += 1
      result[^1].intermediate = input[lastpos..<pos]
      assert input[pos] in {0x40.char..0x7E.char}, "Final byte of sequence at position " & $pos & " not in range 0x40-0x7E is " & $input[pos].byte
      result[^1].final = input[pos]
      pos += 1
      lastpos = pos
    pos += 1

  if lastpos != input.high:
    result.add AnsiData(kind: String, str: input[lastpos..^1])

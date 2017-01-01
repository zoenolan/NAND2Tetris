# Hack Assembler

def load_input(fileName)
  # load input filename
  fileObj = File.new(fileName, "r")

  rawContentsArray=[]
  fileObj.each_line {|line|
    rawContentsArray.push line
  }

  return rawContentsArray
end

def strip_whitespace(rawContentsArray)
  # Remove whitespace and comments
  contentArray=[]
  rawContentsArray.each {|line|
    strippedLine = line.split("//")[0].strip

    if (strippedLine.empty? != true) && (strippedLine.start_with?('//') != true)
      contentArray.push strippedLine
    end
  }

  return contentArray
end

def build_predefined_symbols()
  symbolTable = Hash.new

  symbolTable["SP"] = 0
  symbolTable["LCL"] = 1
  symbolTable["ARG"] = 2
  symbolTable["THIS"] = 3
  symbolTable["THAT"] = 4
  symbolTable["R0"] = 0
  symbolTable["R1"] = 1
  symbolTable["R2"] = 2
  symbolTable["R3"] = 3
  symbolTable["R4"] = 4
  symbolTable["R5"] = 5
  symbolTable["R6"] = 6
  symbolTable["R7"] = 7
  symbolTable["R8"] = 8
  symbolTable["R9"] = 9
  symbolTable["R10"] = 10
  symbolTable["R11"] = 11
  symbolTable["R12"] = 12
  symbolTable["R13"] = 13
  symbolTable["R14"] = 14
  symbolTable["R15"] = 15
  symbolTable["SCREEN"] = 0x4000
  symbolTable["KBD"] = 0x6000

  return symbolTable
end

def build_symboltable(inputArray)
  symbolTable = build_predefined_symbols()
  counter = 0;

  inputArray.each {|line|
    if line.start_with?("(")
      # symbol
      symbol = line[1..-1].split(')')[0]
      symbolTable[symbol] = counter
    else
      counter = counter + 1
    end
  }

  return symbolTable
end

def is_number(symbol)
  return symbol.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
end

def aInstruction(line, symbolTable, variableCounter)
  symbol = line[1..-1].strip

  if is_number(symbol)
      return symbol.to_i, variableCounter
  else
    lookup = symbolTable[symbol]
    if lookup == nil
      symbolTable[symbol] = variableCounter
      lookup = variableCounter

      variableCounter = variableCounter + 1
    end

    return lookup, variableCounter
  end
end

def split_dest_comp(line)
  if line.include? "="
    return line.split('=')
  else
    dest_comp=[]
    dest_comp[0]= ""
    dest_comp[1]= line.split(';')[0]
    return dest_comp
  end
end

def parseDest(line)
  dest = split_dest_comp(line)[0]

  if dest == nil
    dest = ""
  else
    dest = dest.strip
  end

  case dest
  when "M"
    return 0b001
  when "D"
    return 0b010
  when "MD"
    return 0b011
  when "A"
    return 0b100
  when "AM"
    return 0b101
  when "AD"
    return 0b110
  when "AMD"
    return 0b111
  else
    return 0b000
  end
end

def parseComp(line)
  comp = split_dest_comp(line)[1]

  if comp == nil
    comp = ""
  else
    comp = comp.strip
  end

  case comp
  when "0"
     return 0b0101010
  when "1"
     return 0b0111111
  when "-1"
     return 0b0111010
  when "D"
     return 0b0001100
  when "A"
     return 0b0110000
  when "!D"
     return 0b0001101
  when "!A"
     return 0b0110001
  when "-D"
     return 0b0001111
  when "-A"
     return 0b0110011
  when "D+1"
     return 0b0011111
  when "A+1"
     return 0b0110111
  when "D-1"
     return 0b0001110
  when "A-1"
     return 0b0110010
  when "D+A"
     return 0b0000010
  when "D-A"
     return 0b0010011
  when "A-D"
     return 0b0000111
  when "D&A"
     return 0b0000000
  when "D|A"
     return 0b0010101
  when "M"
     return 0b1110000
  when "!M"
     return 0b1110001
  when "-M"
     return 0b1110011
  when "M+1"
     return 0b1110111
  when "M-1"
     return 0b1110010
  when "D+M"
     return 0b1000010
  when "D-M"
     return 0b1010011
  when "M-D"
     return 0b1000111
  when "D&M"
     return 0b1000000
  when "D|M"
     return 0b1010101
  else
      return 0b0000000
  end
end

def parseJump(line)
  jump = line.split(';')[1]

  if jump == nil
    jump = ""
  else
    jump = jump.strip
  end

  case jump
  when "JGT"
      return 0b001
  when "JEQ"
      return 0b010
  when "JGE"
      return 0b011
  when "JLT"
      return 0b100
  when "JNE"
      return 0b101
  when "JLE"
      return 0b110
  when "JMP"
      return 0b111
  else
      return 0b000
  end
end

def cInstruction(line)
  opCode = 0b111
  dest = parseDest(line)
  comp = parseComp(line)
  jump = parseJump(line)

  instruction = (opCode << 13) + (comp << 6) + (dest << 3) + (jump << 0)
  return instruction
end

def parse(inputArray, symbolTable)
  variableCounter = 16
  byteCode=[]

  inputArray.each {|line|
    if line.start_with?("@")
      code, variableCounter = aInstruction(line, symbolTable, variableCounter)
      byteCode.push code
    elsif line.start_with?("(") != true
      byteCode.push cInstruction(line)
    end
  }

  return byteCode
end

def build_output_filename(inputFilename)
  elements = inputFilename.split(".")
  return elements[0] + ".mine.hack"
end

def output_bytecode(outputFilename, bytecode)
  fileObj = File.open(outputFilename, 'w')

  bytecode.each {|line|
    formattedLine = sprintf("%016b\n", line)
    fileObj.write formattedLine
  }
end

inputFilename = ARGV[0]

rawInputArray = load_input(inputFilename)

inputArray = strip_whitespace(rawInputArray)

symbolTable = build_symboltable(inputArray)

bytecode = parse(inputArray, symbolTable)

outputFilename = build_output_filename(inputFilename)

output_bytecode(outputFilename, bytecode)

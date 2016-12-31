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
    strippedLine = line.lstrip

    if (strippedLine.empty? != true) && (strippedLine.start_with?('//') != true)
      contentArray.push strippedLine
    end
  }

  return contentArray
end

def is_number(symbol)
  true if Float(symbol) rescue false
end

def build_symboltable(inputArray)
  symbolTable = Hash.new
  counter = 16;

  inputArray.each {|line|
    step = 1

    if line.start_with?("(")
      # symbol
      symbol = line.split(' ')[0]

      if is_number(symbol)
        symbolTable[symbol] = counter
        step = 0
      end
    end

    counter = counter + step
  }

  return symbolTable
end

def aInstruction(line, symbolTable)
  symbol = line[1..-1]

  if is_number(symbol)
      return symbol.to_i
  else
      return symbolTable[symbol]
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

  if line.start_with? "D=D+M"
    puts "D:" + dest + "\n"
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

  if line.start_with? "D=D+M"
    puts "C:" + comp + "\n"
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

  if line.start_with? "D=D+M"
    puts "J:" + jump + "\n"
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
  byteCode=[]
  inputArray.each {|line|
    if line.start_with?("@")
      byteCode.push aInstruction(line, symbolTable)
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

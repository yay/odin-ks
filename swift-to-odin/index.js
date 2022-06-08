const fs = require('fs');
const { exec } = require("child_process");

// The order of the struct elements in memory is the order of their declaration:
// https://github.com/apple/swift/blob/main/docs/ABI/TypeLayout.rst

function run(command) {
  exec(command, (err, stdout, stderr) => {
    if (err) {
      console.error(`exec error: ${err}`);
      return;
    }

    stderr = stderr.trim();
    if (stderr) {
      console.log(`stderr: ${stderr}`);
      return;
    }

    stdout = stdout.trim();
    if (stdout) {
      console.log(`stdout: ${stdout}`);
    }
  });
}

function swiftRawPrint(str) {
  return `print("""\n${str}\n""", terminator: "")`;
}

function swiftRawPrintln(str) {
  return `print("""\n${str}\n""")`;
}

const getterRegEx = /^(.*)public var (.+): (.+) { get }(.*)$/; // prefix, name, type, suffix
const structsRegEx = /(.*?)public struct (.+?) {(.+?)}/smg; // prefix, name, body (note: doesn't capture suffix)
const structFieldsRegEx = /public var (.+?): (.+?)(?:\n| (?:\/\*(.*?)\*\/)| \/\/ (.*?)\n)/g; // name, type, comment

const code = String(fs.readFileSync('./generated.swift'));

const generateSwift = false;
const generateOdin = true;

if (generateSwift) {
  const lines = code.split('\n').map((line, i) => {
    const arr = getterRegEx.exec(line);
    if (arr) {
      const [all, prefix, constant, type, suffix] = arr;
      return `print("let ${constant}: ${type} = ", ${constant}, separator: "")`;
    }
    return swiftRawPrintln(line);
  });
  lines.unshift('import Foundation');

  fs.writeFileSync('./eval.swift', lines.join('\n'));

  run('swift ./eval.swift > regenerated.swift');
}

if (generateOdin) {
  swiftToOdinTypeMap = {
    'Int': 'int',
    'UInt': 'uint',
    'Int8': 'i8',
    'UInt8': 'u8',
    'Int16': 'i16',
    'UInt16': 'u16',
    'Int32': 'i32',
    'UInt32': 'u32',
    'Int64': 'i64',
    'UInt64': 'u64',
    'Float': 'f32',
    'Double': 'f64',

    '__int8_t': 'i8',
    '__uint8_t': 'u8',
    '__int16_t': 'i16',
    '__uint16_t': 'u16',
    '__int32_t': 'i32',
    '__uint32_t': 'u32',
    '__int64_t': 'i64',
    '__uint64_t': 'u64',
    '__darwin_intptr_t': 'int',
    '__darwin_natural_t': 'u32',
    '__darwin_off_t': 'i64',
    'off_t': 'i64',
    '__darwin_mach_port_name_t': 'u32',
    '__darwin_mach_port_t': 'u32',
    '__darwin_mode_t': 'u16',
    'mode_t': 'u16',
    '__darwin_pid_t': 'i32',
    'pid_t': 'i32',
    '__darwin_sigset_t': 'u32',
    '__darwin_suseconds_t': 'i32',
    '__darwin_uid_t': 'u32',
    '__darwin_useconds_t': 'u32',
    '__darwin_uuid_t': '[16]byte',
    '__darwin_uuid_string_t': '[37]byte',
    '__darwin_time_t': 'int',

    'u_long': 'uint',
    'ushort': 'u16',
    'uint': 'u32',
    'u_quad_t': 'u64',
    'quad_t': 'i64',
    'qaddr_t': '^i64',
    'daddr_t': 'i32',

    'fixpt_t': 'u32',
    'segsz_t': 'i32',
    'swblk_t': 'i32',
    'fd_mask': 'i32',

    'filesec_property_t': 'u32',
    'filesec_t': 'rawptr',
    'OpaquePointer': 'rawptr',
    'UnsafeMutableRawPointer!': 'rawptr',
    'UnsafePointer<CChar>': 'cstring'
  };

  // JavaScript RegExp objects are stateful when they have the global or sticky flags set
  // (e.g. /foo/g or /foo/y). They store a lastIndex from the previous match.
  // Using this internally, exec() can be used to iterate over multiple matches
  // in a string of text (with capture groups).
  const lines = [];
  const structNames = new Set();
  let structMatch;
  while (structMatch = structsRegEx.exec(code)) {
    const [, structPrefix, structName, structBody] = structMatch;
    structNames.add(structName);
    lines.push(mapConstants(structPrefix));
    let fieldMatch;
    lines.push(swiftRawPrintln(`${structName} :: struct {`));
    while (fieldMatch = structFieldsRegEx.exec(structBody)) {
      const [, fieldName, fieldType, fieldComment] = fieldMatch;
      const trimmedComment = fieldComment?.trim();
      const odinType = swiftToOdinTypeMap[fieldType] || (structNames.has(fieldType) ? fieldType : `${fieldType}!!!`);
      // Search for `!!!` in the output to see if there are any errors.
      lines.push(swiftRawPrintln(`    ${fieldName}: ${odinType}, ${trimmedComment ? ` // ${trimmedComment}` : ''}`));
    }
    lines.push(swiftRawPrintln('}'));
  }
  const remainder = code.replace(structsRegEx, ''); // the rest of the code after all the matched structs
  lines.push(mapConstants(remainder));

  function mapConstants(code) {
    const lines = code.split('\n').map((line, i) => {
      const arr = getterRegEx.exec(line);
      if (arr) {
        const [all, prefix, constant, type, suffix] = arr;
        const odinType = swiftToOdinTypeMap[type];
        if (!odinType) {
          console.error(`Unknown type: ${type}`);
          process.exit(1);
        }
        return `${swiftRawPrint(prefix)}\nprint("${constant} : ${odinType} : ", ${constant}, separator: "", terminator: "")\n${swiftRawPrintln(suffix)}\n`;
      }
      return swiftRawPrintln(line);
    });
    return lines.join('\n');
  }

  lines.unshift('print("package darwin")');
  lines.unshift('import Foundation');

  fs.writeFileSync('./eval.swift', lines.join('\n'));

  run('swift ./eval.swift > generated.odin');
}
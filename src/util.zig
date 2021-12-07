const std = @import("std");

/// Given a relative or absolute filename, open the file
pub fn openFile(filename: []u8) std.fs.File.OpenError!std.fs.File {
    const flags = std.fs.File.OpenFlags {
        .read = true
    };
    const cwd = std.fs.cwd();
    return cwd.openFile(filename, flags);
}

/// Given a string, return a splice ends at the first whitespace character
pub fn getWord(str: []u8) []u8 {
    for (str) |c, n| {
        if (c == ' ' or c == '\n') return str[0..n];
    }
    return str[0..];
}

/// Given a string returns a new string without the leading whitespace
pub fn eatWhitespace(str: []u8) []u8 {
    for (str) |c, n| {
        if (c != ' ' and c != '\n') return str[n..];
    }
    return str[0..];
}

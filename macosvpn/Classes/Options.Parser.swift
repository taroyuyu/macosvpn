/*
 * Copyright (C) 2014-2019 halo https://github.com/halo/macosvpn
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Darwin

extension Options {
  /// Reads global command line arguments and converts them into an Options instance.
  enum Parser {
    static func parse(_ arguments: [String]) throws -> Options {
      let parser = Moderator()

      let commandName = parser.add(
        Argument<String>.singleArgument(name: ""))

      // Global

      let versionFlag = parser.add(
        Argument<Bool>.option(
          Flag.Version.rawValue,
          Flag.VersionShort.rawValue))

      let helpFlag = parser.add(
        Argument<Bool>.option(
          Flag.Help.rawValue,
          Flag.HelpShort.rawValue))

      let debugFlag = parser.add(
        Argument<Bool>.option(
          Flag.Debug.rawValue,
          Flag.DebugShort.rawValue))

      // Create

      let forceFlag = parser.add(
        Argument<Bool>.option(
          Flag.Force.rawValue,
          Flag.ForceShort.rawValue))

      // Delete

      let allFlag = parser.add(
        Argument<Bool>.option(
          Flag.All.rawValue,
          Flag.AllShort.rawValue))

      let nameFlag = parser.add(
        Argument<String>.optionWithValue(
          Flag.Name.rawValue,
          Flag.NameShort.rawValue).repeat())

      // Parse arguments

      // This 3rd party library should not throw, when passed in `strict: false`.
      // If it still does, it's OK to let it bubble up. It will be caught higher up.
      try parser.parse(arguments, strict: false)

      let options = Options()
      options.unprocessedArguments = parser.remaining

      // Highest precedence when requesting help, bail our immediately
      if helpFlag.value {
        options.command = .help
        return options
      }

      if versionFlag.value {
        options.command = .version
        return options
      }

      guard let commandNameValue = commandName.value else {
        throw ExitError(message: "You must specify a command. For example `macosvpn create` or `macosvpn delete`. Try `--help`.",
                        code: .invalidCommand)
      }

      guard let command = Command(rawValue: commandNameValue) else {
        throw ExitError(message: "You specified an unknown command. Try `macosvpn create` or `macosvpn delete` instead.",
                        code: .invalidCommand)
     }

      // Global
      options.command = command
      options.debugRequested = debugFlag.value

      // Create
      options.forceRequested = forceFlag.value

      // Delete
      options.allRequested = allFlag.value
      options.names = nameFlag.value

      return options
    }
  }
}

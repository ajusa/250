version     = "0.1"
author      = "ajusa"
description = "Simple webapp to calculate score"
license     = "MIT"

srcDir = "src"

requires "nim >= 1.4.2"
requires "mummy"
requires "webby"
requires "flatty"
requires "supersnappy"
requires "https://github.com/ajusa/dekao#HEAD"

task arm, "builds binary for aarch64":
  switch("cc", "clang")
  switch("clang.exe", "zigcc")
  switch("clang.linkerexe", "zigcc")
  switch("forceBuild", "on")
  switch("passC", "-target aarch64-linux-gnu")
  switch("passL", "-target aarch64-linux-gnu")
  switch("cpu", "arm64")
  selfExec("c src/main.nim")
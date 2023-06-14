--threads:on
--mm:orc

task arm, "builds binary for aarch64":
  switch("cc", "clang")
  switch("d", "release")
  switch("clang.exe", "zigcc")
  switch("clang.linkerexe", "zigcc")
  switch("forceBuild", "on")
  switch("passC", "-target aarch64-linux-gnu")
  switch("passL", "-target aarch64-linux-gnu")
  switch("cpu", "arm64")
  setCommand("c", "src/main.nim")
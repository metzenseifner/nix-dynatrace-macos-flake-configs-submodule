function showascii() {
  man -P "cat" termios
  man -P "cat" terminfo # apps use to map escape sequences back to keys
  man -P "cat" ansi_cctrl # mac
  man -P "cat" ansi_code # mac
  man -P "cat" ansi_ctrlu # mac
  man -P "cat" ansi_send # mac
  man -P "cat" console_codes # linux
  man -P "cat" ascii
  stty -a
  # Also see Control Sequence Introducer (CSI) and Operating System Command (OSC) sequences
}

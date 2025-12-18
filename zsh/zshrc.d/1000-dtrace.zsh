function ls_available_syscalls() {
  dtrace -ln 'syscall:::entry'
}

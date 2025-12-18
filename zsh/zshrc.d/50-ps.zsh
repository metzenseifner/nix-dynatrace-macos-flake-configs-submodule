function watchmem() {
  watch -n 1 \
  ps -eo comm,pcpu,pmem,pid,args --sort=-pmem -ww | head -n 10 | column 
}

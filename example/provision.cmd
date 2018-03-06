configure
  set interfaces em3 unit 0 family inet address 10.0.0.1/24
  show | compare
  commit
exit

show interfaces em3 terse


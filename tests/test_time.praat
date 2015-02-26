include ../../plugin_jjatools/procedures/time.proc

date$ = date$()
@time()

test$ = time.dw$       + " " +
  ... time.mo$         + " " +
  ... string$(time.dm) + " " +
  ... time.tm$         + " " +
  ... string$(time.yr)

assert date$ = test$

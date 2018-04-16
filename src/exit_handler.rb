at_exit{
  Thread.kill($thr)
  puts "Exiting The Application"
}
at_exit{
  Thread.kill($thr)
  Thread.kill($clsuter_message_thrd)
  Thread.kill($replica_handle_thrd)
  puts "Exiting The Application"
}

class profile::base {
  $message = hiera('message')
  notify { "The message from hiera is: ${message}": }
}

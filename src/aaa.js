console.log('hello')

define([], function() {
  console.log('aaa included')
  return 'aaa'
})

// define('bbb', ['aaa'], function(aaa) {
//   console.log('bbb included')
//   'bbb'
// })

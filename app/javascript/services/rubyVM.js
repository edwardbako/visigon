export function evaluate(program) {
  let vm = window["rubyVM"]

  if (typeof vm !== 'undefined') {
    try {
      return vm.eval(program)
    }
    catch (err) {
      return err.message
    }
  } else {
    return "RubyVM is not ready yet."
  }
}

export function ready() {
  let vm = window["rubyVM"]

  if (typeof vm !== 'undefined') {
    return true
  } else {
    return false
  }
}
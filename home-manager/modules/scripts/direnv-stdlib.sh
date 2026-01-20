# direnv-stdlib.sh - Custom direnv functions

# Custom direnv function to use mise
use_mise() {
  direnv_load mise direnv exec
}

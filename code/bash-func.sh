function bash-cli() {
  curl -s https://mresetar.github.io/code/bash.sh > "$1"
  chmod +x "$1"
}

function bash-min() {
  curl -s https://mresetar.github.io/code/bash-min.sh > "$1"
  chmod +x "$1"
}
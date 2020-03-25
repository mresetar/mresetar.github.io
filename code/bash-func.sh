
# Creates new minimal bash script using bash-min new-script.sh
function bash-min() {
  curl -s https://mresetar.github.io/code/bash-min.sh > "$1"
  chmod +x "$1"
}

# Creates CLI template bash script using bash-cli new-script.sh
function bash-cli() {
  curl -s https://mresetar.github.io/code/bash.sh > "$1"
  chmod +x "$1"
}

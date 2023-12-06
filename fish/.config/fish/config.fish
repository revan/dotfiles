if status is-interactive
    # Commands to run in interactive sessions can go here
end
source /opt/homebrew/opt/asdf/libexec/asdf.fish
set -x GPG_TTY (tty)
export JAVA_HOME=$(/usr/libexec/java_home -v 12)

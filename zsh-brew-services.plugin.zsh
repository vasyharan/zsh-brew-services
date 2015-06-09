# Autocompletion for homebrew-cask.
#
# This script intercepts calls to the brew plugin and adds autocompletion
# for the services subcommand.
#
# Homebrew Services: https://github.com/Homebrew/homebrew-services
# Author: https://github.com/vasyharan

compdef _brew-services brew

_brew-services()
{
  local curcontext="$curcontext" state line
  typeset -A opt_args

  _arguments -C \
    ':command:->command' \
    ':subcmd:->subcmd' \
    '*::options:->options'

  case $state in
    (command)
      __call_original_brew
      services_commands=(
        'services:manage launchctl services'
      )
      _describe -t commands 'brew services command' services_commands ;;

    (subcmd)
      case "$line[1]" in
        services)
          if (( CURRENT == 3 )); then
            local -a subcommands
            subcommands=(
              'cleanup:get rid of stale services and unused plists'
              "list:list all services managed by 'brew services'"
              'restart:gracefully restart selected service'
              'start:start selected service'
              'stop:stop selected service'
            )
            _describe -t commands "brew services subcommand" subcommands
          fi ;;

        *)
          __call_original_brew ;;
      esac ;;

    (options)
      local -a stopped_services started_services
      local expl
      case "$line[2]" in
        start)
          __brew_stopped_services
          _wanted stopped_services expl 'stopped services' compadd -a stopped_services ;;
        stop|restart)
          __brew_started_services
          _wanted started_services expl 'started services' compadd -a started_services ;;
      esac ;;
  esac
}

__brew_stopped_services() {
  stopped_services=(`find /usr/local/Cellar -type f -name 'homebrew.mxcl.*.plist' | awk -F/ '{print $5}'`)
}

__brew_started_services() {
  started_services=(`brew services list 2>/dev/null | awk '{print $1}'`)
}

__call_original_brew()
{
  local ret=1
  _call_function ret _brew
  compdef _brew-services brew
}

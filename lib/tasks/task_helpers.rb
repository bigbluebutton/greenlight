# frozen_string_literal: true

COLORS = {
  # https://www.ing.iac.es/~docs/external/bash/abs-guide/colorizing.html.
  black: 30,
  red: 31,
  green: 32,
  yellow: 33,
  blue: 34,
  magenta: 35,
  cyan: 36,
  white: 37
}.freeze

def err(msg)
  color = COLORS[:red]

  warn "\033[#{color}m#{msg}\033[0m"
  exit 1
end

def warning(msg)
  color = COLORS[:yellow]

  warn "\033[#{color}m#{msg}\033[0m"
end

def info(msg)
  color = COLORS[:cyan]

  puts "\033[#{color}m#{msg}\033[0m"
end

def success(msg)
  color = COLORS[:green]

  puts "\033[#{color}m#{msg}\033[0m"
end

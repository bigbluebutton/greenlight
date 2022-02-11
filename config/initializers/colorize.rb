# frozen_string_literal: true

{
  # https://www.ing.iac.es//~docs/external/bash/abs-guide/colorizing.html.
  black: 30,
  red: 31,
  green: 32,
  yellow: 33,
  blue: 34,
  magenta: 35,
  cyan: 36,
  white: 37
}.each do |key, color_code|
  define_method key do |text|
    "\033[#{color_code}m#{text}\033[0m"
  end
end

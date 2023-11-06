define setConfigurationAIO($file, $line) {
   $defvar = split($line, '=')
   $var = $defvar[0]
   $value = $defvar[1]

   exec { "/bin/sed -i 's/'${var}'=.*/'${var}'='${value}'/' '${file}'":
      onlyif => "/bin/grep -q '${var}' '${file}'",
      unless => "/bin/grep -q '${line}' '${file}'"
   }

   exec { "/bin/echo '${line}' >> '${file}'":
      unless => "/bin/grep -q '${var}' '${file}'"
   }
}

define replaceLineAIO($file, $pattern, $replacement) {
   exec { "/bin/sed -i 's/'${pattern}'/'{$replacement}'/g' '${file}'":
      onlyif => "/bin/grep -q '${pattern}' '${file}'",
   }
}

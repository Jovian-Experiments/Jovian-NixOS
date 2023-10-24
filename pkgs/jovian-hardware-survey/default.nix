{ lib
, runCommand
, ruby
, steamdeck-firmware
, dmidecode
}:

runCommand "jovian-hardware-survey" { } ''
  mkdir -p $out/bin
  (
  echo "#!${ruby}/bin/ruby"
  echo 'ENV["PATH"] = "${lib.makeBinPath [ steamdeck-firmware dmidecode ]}:#{ENV["PATH"]}"'
  echo 'D20BOOTLOADER = "${steamdeck-firmware}/libexec/d20bootloader"'
  cat ${./jovian-hardware-survey.rb}
  ) > $out/bin/jovian-hardware-survey
  chmod +x $out/bin/jovian-hardware-survey
''

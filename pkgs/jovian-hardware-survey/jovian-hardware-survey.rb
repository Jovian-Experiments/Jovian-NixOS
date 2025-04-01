#!/usr/bin/env ruby

require "json"
require "shellwords"

D20BOOTLOADER ||= "/usr/share/jupiter_controller_fw_updater/d20bootloader.py"

# Identifiers from: class DeviceType(IntEnum)
DeviceType = {
  :D21_D21 => 0x100,
  :D2x_D21 => 0x200,
  :RA4     => 0x300,
}

# Handles joining/escaping a command, and raises on status != 0
# Additionally prints the command to stderr.
def run(*args, stdout:, silent: false, stderr: false, ignore_fail: false)
  cmd = args.shelljoin
  if !stdout and stderr then
    raise "To use stderr, for now you need to use stdout."
  end
  stderr =
    if stderr then
      " 2>&1"
    else
      ""
    end
  $stderr.puts " $ #{cmd}" unless silent
  ret =
    if stdout then
      `#{cmd}#{stderr}`
    else
      system("#{cmd}")
      nil
    end
  unless $?.success? || ignore_fail
    raise "Command “#{cmd}” unexpectedly failed..."
  end
  ret
end

module DMI
  TYPES = {
    0 	=> "BIOS",
    1 	=> "System",
    2 	=> "Base Board",
    3 	=> "Chassis",
    4 	=> "Processor",
    5 	=> "Memory Controller",
    6 	=> "Memory Module",
    7 	=> "Cache",
    8 	=> "Port Connector",
    9 	=> "System Slots",
    10 	=> "On Board Devices",
    11 	=> "OEM Strings",
    12 	=> "System Configuration Options",
    13 	=> "BIOS Language",
    14 	=> "Group Associations",
    15 	=> "System Event Log",
    16 	=> "Physical Memory Array",
    17 	=> "Memory Device",
    18 	=> "32-bit Memory Error",
    19 	=> "Memory Array Mapped Address",
    20 	=> "Memory Device Mapped Address",
    21 	=> "Built-in Pointing Device",
    22 	=> "Portable Battery",
    23 	=> "System Reset",
    24 	=> "Hardware Security",
    25 	=> "System Power Controls",
    26 	=> "Voltage Probe",
    27 	=> "Cooling Device",
    28 	=> "Temperature Probe",
    29 	=> "Electrical Current Probe",
    30 	=> "Out-of-band Remote Access",
    31 	=> "Boot Integrity Services",
    32 	=> "System Boot",
    33 	=> "64-bit Memory Error",
    34 	=> "Management Device",
    35 	=> "Management Device Component",
    36 	=> "Management Device Threshold Data",
    37 	=> "Memory Channel",
    38 	=> "IPMI Device",
    39 	=> "Power Supply",
    40 	=> "Additional Information",
    41 	=> "Onboard Device",
  }

  extend self

  def dmi_info()
    run("dmidecode", stdout: true, silent: true)
    .strip
    .split(/\n\n+(?=Handle)/)[1..-2]
    .map do |data|
      full_header, description, data = data.split(/\n+/, 3)
      # full_header: Handle 0x0031, DMI type 40, 18 bytes\n
      handle = full_header.split(",", 2).first.split(" ", 2).last
      dmi_type_numeric = full_header.split(",")[1].split(/\s+/).last.to_i
      dmi_type = TYPES[dmi_type_numeric]
      data = data.gsub(/^\t/, "").split(/\n+(?=[^\t])/).map do |line|
        k, v = line.split(/\s*:\s*/, 2)
        v = v.gsub(/^\t/, "") if v
        [k, v]
      end
        .group_by { |pair| pair.first }
        .map do |k, data|
          data = data.map(&:last)
          data = data.first unless data.length > 1
          [k, data]
        end
        .to_h
      {
        "dmi_type" => dmi_type,
        "dmi_type_numeric" => dmi_type_numeric,
        "handle" => handle,
        "full_header" => full_header,
        "description" => description,
        "data" => data,
      }
    end
    .group_by { |data| data["dmi_type"] }
    .map do |k, data|
      data = data.first unless data.length > 1
      [k, data]
    end
    .to_h
  end
end

module ReportData
  extend self

  def dmi_info()
    @dmi_info ||= DMI.dmi_info
  end

  def is_steam_deck?()
    [
      "Jupiter",
      "Galileo",
    ].include?(system_information["Product Name"])
  end

  FIELDS = [
    :data_version,
    :bios_information,
    :manufacturing_information,
    :system_information,
    :board_information,
    :processor_information,
    :memory_information,
    :onboard_devices_information,
    :controller_information,
  ]

  def data_version()
    1
  end

  def bios_information()
    dmi_info["BIOS"]["data"].select do |k, _|
      [
        "Vendor",
        "Version",
        "Release Date",
        "BIOS Revision",
        "Firmware Revision",
      ].include?(k)
    end
      .to_h
  end

  def manufacturing_information()
    if is_steam_deck? then
      year = system_information["Serial Number"][4..4]
      week = system_information["Serial Number"][5..6]
      {
        "Year" => "202#{year}",
        "Week" => week,
      }
    end
  end

  def system_information()
    dmi_info["System"]["data"].select do |k, _|
      [
        "Manufacturer",
        "Product Name",
        "Version",
        "Family",
        "Serial Number",
      ].include?(k)
    end
      .to_h
  end

  def board_information()
    dmi_info["Base Board"]["data"].select do |k, _|
      [
        "Manufacturer",
        "Product Name",
        "Version",
        "Serial Number",
      ].include?(k)
    end
    .to_h
  end

  def processor_information()
    dmi_info["Processor"]["data"].tap do
      # Convert flags into a Hash, for converting into a JSON Object.
      _1["Flags"] = _1["Flags"].split("\n").map do |line|
        data = line.match(%r{^([^\s]+)\s+\((.*)\)$})
        [data[1], data[2]]
      end
        .to_h
      # Convert characteristics into an array
      _1["Characteristics"] = _1["Characteristics"].split("\n")
    end
  end

  def memory_information()
    devices = dmi_info["Memory Device"].map do |entry|
        entry["data"].select do |k, _|
          [
            "Size",
            "Part Number",
            "Type",
            "Speed",
            "Configured Memory Speed",
            "Manufacturer",
          ].include?(k)
        end
        .to_h
      end
      .map do |v|
        if v["Manufacturer"] == "Unknown" then
          v["Manufacturer"] =
            case v["Part Number"]
            when /^MT/
              "Micron"
            when /^KL/
              "Samsung"
            else
              "(Unknown)"
            end
        end
        v
      end
      physical_memory = dmi_info["Physical Memory Array"]["data"].select do |k, _|
        [
          "Maximum Capacity",
          "Number Of Devices",
        ].include?(k)
      end
      .to_h
    {
      "Physical Memory" => physical_memory,
      "Devices" => devices,
    }
  end

  def onboard_devices_information()
    dmi_info["Onboard Device"].map do |entry|
      entry["data"]
    end
  end

  def controller_information()
    return nil unless is_steam_deck?
    return @controller_information if @controller_information
    begin
      info = JSON.parse(run(D20BOOTLOADER, "getdevicesjson", silent: true, stdout: true)).first
      bootloader_type = info["release_number"] & 0xff00 # Mask out lower byte
      raw = run(D20BOOTLOADER, "getinfo", silent: true, stdout: true, stderr: true)

      # Clean up the raw data
      raw =
        raw
        .split(/\n+/)
        .grep(/__main__ - INFO/)
        .map { |line| line.split(/\s*-\s*/, 6).last } # "2023-08-09 20:35:03,265 - __main__ - INFO - ......"
        .join("\n")

      # Seed device_type from the bootloader type
      device_type = bootloader_type

      # Extract the info
      if bootloader_type == DeviceType[:RA4]
        mcu = raw.split("**").last.strip
        mcus = [mcu]
      else
        # D20/D21
        mcus = raw.split("\n\n")
        header = mcus.shift.split(/\n/)
        # Let the vendor identify the device for us.
        device_type = header
          .find { |line| line.match(/^Found a/) }
          .split(/\s+/)[2]
      end

      # Identify the device type from the bootloader type
      if DeviceType.key(device_type.to_i)
        device_type = DeviceType.key(device_type.to_i).to_s
      end

      # Format the raw information (bootloader_type) with the information we got.
      device_type = "%s (0x%x)" % [device_type.to_s, bootloader_type]

      mcus = mcus.map do |mcu|
        mcu.split(/\n/)
          .grep(/:/)
          .map do |line|
            line
              .split(/:\s*/, 2)
          end
          .select { |pair| pair.length == 2 }
          .select do |pair|
            [
              "Stored board serial",
              "Stored hardware ID",
            ].include?(pair.first)
          end
          .to_h
      end
    ensure
      run(D20BOOTLOADER, "reset", silent: true, stdout: true, stderr: true)
      sleep(1)
    end
    @controller_information = {
      "Device Type" => device_type,
      "Hardware Info" => mcus,
      "Bootloader Type" => bootloader_type,
      "Hardware ID" => mcus.first["Stored hardware ID"],
      "Release Number" => info["release_number"],
    }
  end

  def raw()
    FIELDS.map { |field| [field, ReportData.send(field)] }.to_h
  end

  def steam_deck()
    ram_chip_count = memory_information["Devices"].length
    ram_chip_size = memory_information["Devices"][0]["Size"].split(/\s+/, 2)[0].to_i

    [
      "Product Name:         #{system_information["Product Name"]}",
      "System Family:        #{system_information["Family"]}",
      "Serial:               #{system_information["Serial Number"]}",
      "Manufacturing year:   #{manufacturing_information["Year"]}",
      "Manufacturing week:   #{manufacturing_information["Week"]}",
      "Controller type:      #{controller_information["Device Type"]}",
      "Controller BL type:   #{controller_information["Bootloader Type"]}",
      "Controller HWID:      #{controller_information["Hardware ID"]}",
      "RAM config:           #{ram_chip_count}×#{ram_chip_size} = #{ram_chip_size * ram_chip_count}",
      "RAM Part Number:      #{memory_information["Devices"][0]["Part Number"]}",
      "RAM Manufacturer:     #{memory_information["Devices"][0]["Manufacturer"]}",
    ].join("\n")
  end
end

def usage()
  puts [
    "Usage: jovian-hardware-survey <param>",
    "",
    "  --steam-deck-report   outputs a brief report only for steam deck.",
    "  --raw                 outputs all data gathered to JSON on stdout.",
  ].join("\n")
end

if ARGV.length != 1 then
  usage()
  exit 1
end
case ARGV.first
when "-h", "-help"
  usage()
  exit 0
when "--steam-deck-report"
  if ReportData.is_steam_deck?()
    puts ReportData.steam_deck()
  else
    $stderr.puts "ERROR: This is not a steam deck..."
    exit 2
  end
when "--raw"
    puts JSON.pretty_generate(ReportData.raw)
end

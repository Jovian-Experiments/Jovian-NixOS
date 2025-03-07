use anyhow::bail;
use smbioslib::SMBiosOemStrings;
use std::fs;

mod consts;
use consts::{DATA_PATH, RUNTIME_DIRECTORY};

fn main() -> anyhow::Result<()> {
    let data = smbioslib::table_load_from_device()?;

    let mut all_strings = Vec::new();

    for table in data.collect::<SMBiosOemStrings>() {
        for string in table.oem_strings() {
            // really weird API design on that crate
            if string.is_ok() {
                all_strings.push(string.ok().unwrap());
            } else if string.is_err() {
                eprintln!("Failed to parse OEM string: {:?}", string.err().unwrap());
            }
        }
    }

    if all_strings.is_empty() {
        bail!("Found no OEM strings!");
    }

    let encoded = bitcode::encode(&all_strings);

    fs::create_dir_all(RUNTIME_DIRECTORY)?;
    fs::write(DATA_PATH, encoded)?;

    Ok(())
}

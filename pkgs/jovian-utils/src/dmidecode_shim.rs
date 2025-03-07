use std::fs;

mod consts;
use consts::DATA_PATH;

use clap::Parser;

#[derive(Parser, Debug)]
struct Args {
    #[arg(long)]
    oem_string: usize,
}

fn main() -> anyhow::Result<()> {
    let index = Args::parse().oem_string;
    let data = fs::read(DATA_PATH)?;
    let decoded: Vec<&str> = bitcode::decode(&data)?;
    println!("{}", decoded[index - 1]);
    Ok(())
}

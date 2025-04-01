use nix::unistd::{Uid, User};
use std::{fs, io};

fn main() {
    let uid = Uid::effective();
    let user = User::from_uid(uid)
        .expect("Unable to get current user info")
        .expect("Current user does not exist");
    let mut path = user.dir;
    path.push(".local/state/steamos-session-select");

    let session = fs::read_to_string(&path);
    match session {
        Ok(s) => {
            print!("{}", s);
            fs::remove_file(&path).expect("Failed to remove session file");
        },
        Err(e) => match e.kind() {
            io::ErrorKind::NotFound => {}
            _ => eprintln!("Error when reading session file: {:?}", e),
        },
    }
}

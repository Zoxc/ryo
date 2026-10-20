//! A VM `main`: entered through `ryo_rt::entry::c_main` and its portal. It calls another VM
//! function and returns `Err(())`, so the program prints `Error: ()` and exits with 1.

const E: Result<(), ()> = Err(());

fn answer() -> i32 {
    42
}

fn main() -> Result<(), ()> {
    answer();
    E
}

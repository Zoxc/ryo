//! Constants pointing at another crate's statics, functions and vtables (on PE these go into
//! the image's fixup area), and thread locals of another crate (on ELF the backend adds the
//! `ThreadLocal` shim itself).

use std::fmt::Display;

use vsl::{Shape, T};

const TO_STATIC: &&u32 = &&vsl::S;
const FNS: &[fn() -> i32] = &[vsl::f, vsl::g, local];
const DYNS: &[&dyn Shape] = &[&T(3), &T(4)];
const SHOW: &dyn Display = &T(9);
const MIXED: (&u32, &str, fn() -> i32) = (&vsl::S, "mixed", vsl::g);
static LOCAL: u32 = 2;
const TO_LOCAL: &[&u32] = &[&LOCAL, &vsl::S];

fn local() -> i32 {
    7
}

fn statics() -> u32 {
    unsafe {
        vsl::M += 1;
        vsl::M += **TO_STATIC;
        vsl::M
    }
}

fn fns() -> i32 {
    FNS.iter().map(|f| f()).sum::<i32>() + MIXED.2() + std::ptr::fn_addr_eq(FNS[0], vsl::f as fn() -> i32) as i32
}

fn dyns() -> u32 {
    DYNS.iter().map(|s| s.area()).sum::<u32>() + *MIXED.0 + MIXED.1.len() as u32 + TO_LOCAL.iter().map(|x| **x).sum::<u32>()
}

fn tls() -> u32 {
    vsl::TL.set(vsl::TL.get() * 2);
    vsl::TLK.with(|k| k.set(k.get() + vsl::TL.get()));
    vsl::bump_tl() + vsl::TLK.get() + vsl::NAMES.len() as u32
}

fn main() {
    println!("{}", statics());
    println!("{}", fns());
    println!("{}", dyns());
    println!("{} {}", SHOW, std::ptr::eq(&vsl::S, *TO_STATIC));
    println!("{} {}", tls(), tls());
    println!("{:?}", std::thread::spawn(tls).join().unwrap());
}

//! `y bench crates` workload for semver: parse versions and requirements, match and sort.
use semver::{Version, VersionReq};

fn main() {
    let mut versions = Vec::new();
    for major in 0..20u64 {
        for minor in 0..20u64 {
            for patch in 0..10u64 {
                let pre = if patch % 3 == 0 { format!("-alpha.{patch}") } else { String::new() };
                versions.push(Version::parse(&format!("{major}.{minor}.{patch}{pre}+build.{minor}")).unwrap());
            }
        }
    }
    let reqs: Vec<VersionReq> = ["^1.2", "~3.4.5", ">=2.0.0, <5.0.0", "=7.7.7", "*", "^0.3", ">10.1.0-alpha.0"]
        .iter()
        .map(|r| VersionReq::parse(r).unwrap())
        .collect();
    let mut matches = 0u64;
    for _ in 0..5 {
        for r in &reqs {
            matches += versions.iter().filter(|v| r.matches(v)).count() as u64;
        }
    }
    versions.sort();
    versions.reverse();
    let text: usize = versions.iter().map(|v| v.to_string().len()).sum();
    println!("{} versions, {matches} matches, {text} bytes, max {}", versions.len(), versions[0]);
}

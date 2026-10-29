//! Filesystem wrappers with the path in their errors, and hashing.

use std::path::{Path, PathBuf};

/// `fs::create_dir_all`, with the path in the error.
pub fn create_dir(dir: impl AsRef<Path>) -> Result<(), String> {
    let dir = dir.as_ref();
    std::fs::create_dir_all(dir).map_err(|e| format!("creating {}: {e}", dir.display()))
}

/// Removes `dir` and its contents, if it exists.
pub fn remove_dir_if_exists(dir: impl AsRef<Path>) -> Result<(), String> {
    let dir = dir.as_ref();
    if dir.exists() {
        std::fs::remove_dir_all(dir).map_err(|e| format!("removing {}: {e}", dir.display()))?;
    }
    Ok(())
}

/// Removes `dir` if it exists and creates it empty.
pub fn fresh_dir(dir: impl AsRef<Path>) -> Result<(), String> {
    remove_dir_if_exists(&dir)?;
    create_dir(dir)
}

/// `fs::remove_file`, with the path in the error.
pub fn remove_file(path: impl AsRef<Path>) -> Result<(), String> {
    let path = path.as_ref();
    std::fs::remove_file(path).map_err(|e| format!("removing {}: {e}", path.display()))
}

/// `fs::read_to_string`, with the path in the error.
pub fn read(path: impl AsRef<Path>) -> Result<String, String> {
    let path = path.as_ref();
    std::fs::read_to_string(path).map_err(|e| format!("reading {}: {e}", path.display()))
}

/// `fs::read`, with the path in the error.
pub fn read_bytes(path: impl AsRef<Path>) -> Result<Vec<u8>, String> {
    let path = path.as_ref();
    std::fs::read(path).map_err(|e| format!("reading {}: {e}", path.display()))
}

/// `fs::write`, with the path in the error.
pub fn write(path: impl AsRef<Path>, contents: impl AsRef<[u8]>) -> Result<(), String> {
    let path = path.as_ref();
    std::fs::write(path, contents).map_err(|e| format!("writing {}: {e}", path.display()))
}

/// Copies `from` to `to` through a temporary file renamed into place, so a process that has
/// `to` mapped (a rustc running the backend dylib) keeps the old file instead of seeing it
/// overwritten (design/build.md).
pub fn copy(from: &Path, to: &Path) -> Result<(), String> {
    let err = |e: std::io::Error| format!("copying {} to {}: {e}", from.display(), to.display());
    let mut tmp = to.as_os_str().to_owned();
    tmp.push(format!(".tmp{}", std::process::id()));
    let tmp = PathBuf::from(tmp);
    std::fs::copy(from, &tmp).map_err(err)?;
    std::fs::rename(&tmp, to).map_err(|e| {
        let _ = std::fs::remove_file(&tmp);
        err(e)
    })
}

/// Copies the tree `from` to `to`, each file with [`copy`].
pub fn copy_dir(from: &Path, to: &Path) -> Result<(), String> {
    create_dir(to)?;
    for entry in std::fs::read_dir(from).map_err(|e| format!("{}: {e}", from.display()))? {
        let entry = entry.map_err(|e| e.to_string())?;
        let dst = to.join(entry.file_name());
        if entry.file_type().map_err(|e| e.to_string())?.is_dir() {
            copy_dir(&entry.path(), &dst)?;
        } else {
            copy(&entry.path(), &dst)?;
        }
    }
    Ok(())
}

/// Hashes the paths and contents of the files under `dir` (but `target/`), in a fixed order.
pub fn hash_tree(dir: &Path, rel: &Path, h: &mut std::hash::DefaultHasher) -> Result<(), String> {
    use std::hash::Hasher;
    let mut entries: Vec<_> = std::fs::read_dir(dir).map_err(|e| format!("{}: {e}", dir.display()))?.flatten().collect();
    entries.sort_by_key(|e| e.file_name());
    for entry in entries {
        let name = entry.file_name();
        let path = entry.path();
        let rel = rel.join(&name);
        if entry.file_type().map_err(|e| e.to_string())?.is_dir() {
            if name != "target" {
                hash_tree(&path, &rel, h)?;
            }
        } else {
            h.write(rel.to_string_lossy().as_bytes());
            h.write_u8(0);
            hash_file(h, &path)?;
        }
    }
    Ok(())
}

/// A hash of `bytes`. `DefaultHasher::new` uses fixed keys, so it is stable across runs
/// (which stamps and build ids rely on).
pub fn hash_bytes(bytes: &[u8]) -> u64 {
    use std::hash::Hasher;
    let mut h = std::hash::DefaultHasher::new();
    h.write(bytes);
    h.finish()
}

/// A hash of the contents of `files`, in order.
pub fn hash_files(files: &[impl AsRef<Path>]) -> Result<u64, String> {
    use std::hash::Hasher;
    let mut h = std::hash::DefaultHasher::new();
    for f in files {
        hash_file(&mut h, f.as_ref())?;
    }
    Ok(h.finish())
}

/// Hashes the contents of `path`.
pub fn hash_file(h: &mut std::hash::DefaultHasher, path: &Path) -> Result<(), String> {
    use std::hash::Hasher;
    h.write(&std::fs::read(path).map_err(|e| format!("{}: {e}", path.display()))?);
    Ok(())
}

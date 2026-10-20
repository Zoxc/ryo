//! The bytecode format: opcodes, encoding, the argument block layout, and the image format.
//! Shared by the backend (writer) and the VM (reader).

#![no_std]

#[cfg(feature = "alloc")]
extern crate alloc;

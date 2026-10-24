/-
Ryo.Obj — readers for the objects the backend emits (docs/aot.md §C3): ELF, the image in an
image object, each VM function's decoder inputs, and the unwind tables (`.eh_frame`, LSDAs).
-/
import Ryo.Obj.Elf
import Ryo.Obj.Reloc
import Ryo.Obj.Image
import Ryo.Obj.Lsda
import Ryo.Obj.EhFrame
import Ryo.Obj.Unwind

import RyoTest.Harness
import RyoTest.Int
import RyoTest.Basic
import RyoTest.Ptr
import RyoTest.Call
import RyoTest.Enum
import RyoTest.Unsized
import RyoTest.Divergence
import RyoTest.Json
import RyoTest.Audit
import RyoTest.M1b
import RyoTest.Generated
import RyoTest.X86

namespace RyoTest

def allTests : List TestCase :=
  Int.tests ++ Basic.tests ++ Ptr.tests ++ Call.tests ++ Enum.tests ++ Unsized.tests ++ Divergence.tests ++ Json.tests ++ Audit.tests ++ M1b.tests ++ Generated.tests ++ X86.tests

end RyoTest

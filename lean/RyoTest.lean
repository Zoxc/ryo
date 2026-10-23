import RyoTest.Harness
import RyoTest.Int
import RyoTest.Basic
import RyoTest.Ptr
import RyoTest.Call
import RyoTest.Enum
import RyoTest.Unsized
import RyoTest.Divergence
import RyoTest.Json

namespace RyoTest

def allTests : List TestCase :=
  Int.tests ++ Basic.tests ++ Ptr.tests ++ Call.tests ++ Enum.tests ++ Unsized.tests ++ Divergence.tests ++ Json.tests

end RyoTest

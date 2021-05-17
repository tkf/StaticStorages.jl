module TestDoctest

using StaticStorages
using Documenter: doctest
using Test

test_doctest() = doctest(StaticStorages, manual = false)

end  # module

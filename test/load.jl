try
    using StaticStoragesTests
    true
catch
    false
end || begin
    push!(LOAD_PATH, joinpath(@__DIR__, "StaticStoragesTests"))
    using StaticStoragesTests
end

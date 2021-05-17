module StaticStoragesTests

using LoadAllPackages
using Test

include("utils.jl")

function include_tests(m = @__MODULE__, dir = @__DIR__)
    for file in readdir(dir)
        if match(r"^test_.*\.jl$", file) !== nothing
            Base.include(m, joinpath(dir, file))
        end
    end
end

include_tests()

function collect_modules(root::Module)
    modules = Module[]
    for n in names(root, all = true)
        m = getproperty(root, n)
        m isa Module || continue
        m === root && continue
        startswith(string(nameof(m)), "Test") || continue
        push!(modules, m)
    end
    let i = findfirst(==(TestDoctest), modules)
        if i !== nothing
            deleteat!(modules, i)
            push!(modules, TestDoctest)
        end
    end
    return modules
end

collect_modules() = collect_modules(@__MODULE__)


this_project() = joinpath(dirname(@__DIR__), "Project.toml")

function is_in_path()
    project = this_project()
    paths = Base.load_path()
    project in paths && return true
    realproject = realpath(project)
    realproject in paths && return true
    matches(path) = path == project || path == realproject
    return any(paths) do path
        matches(path) || matches(realpath(path))
    end
end

function with_project(f)
    is_in_path() && return f()
    load_path = copy(LOAD_PATH)
    push!(LOAD_PATH, this_project())
    try
        f()
    finally
        append!(empty!(LOAD_PATH), load_path)
    end
end

function runtests_static(modules = collect_modules())
    @testset "$(nameof(m))" for m in modules
        tests = map(names(m, all = true)) do n
            n == :test || startswith(string(n), "test_") || return nothing
            f = getproperty(m, n)
            f !== m || return nothing
            parentmodule(f) === m || return nothing
            applicable(f) || return nothing  # removed by Revise?
            return f
        end
        filter!(!isnothing, tests)
        @testset "$f" for f in tests
            @debug "Testing $m.$f"
            f()
        end
    end
end

function _runtests_dynamic()
    modules = collect_modules()
    filter!(!=(TestDoctest), modules)
    runtests_static(modules)
end

function runtests_impl()
    LoadAllPackages.loadall(this_project())
    runtests_static()
    @testset "dynamic" begin
        m = Module()
        Base.include(m, @__FILE__)
        Base.invokelatest(m.StaticStoragesTests._runtests_dynamic)
    end
end

runtests() = with_project(runtests_impl)

end # module

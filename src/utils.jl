function define_docstrings()
    docstrings = [:StaticStorages => joinpath(dirname(@__DIR__), "README.md")]
    #=
    docsdir = joinpath(@__DIR__, "docs")
    for filename in readdir(docsdir)
        stem, ext = splitext(filename)
        ext == ".md" || continue
        name = Symbol(stem)
        name in names(StaticStorages, all=true) || continue
        push!(docstrings, name => joinpath(docsdir, filename))
    end
    =#
    for (name, path) in docstrings
        include_dependency(path)
        doc = read(path, String)
        doc = replace(doc, r"^```julia"m => "```jldoctest $name")
        doc = replace(doc, "<kbd>TAB</kbd>" => "_TAB_")
        @eval StaticStorages $Base.@doc $doc $name
    end
end

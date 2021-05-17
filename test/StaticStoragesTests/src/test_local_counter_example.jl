module TestLocalCounterExample

using StaticStorages
using Test

const COUNTER_BUCKET = StaticStorages.BucketKey()

struct Counter
    tag::Symbol
    source::LineNumberNode
    _module::Module 
    count::Ref{UInt}
end

macro count(tag::Symbol)
    counter = Counter(tag, __source__, __module__, Ref(UInt(0)))
    key = StaticStorages.put!(__module__, COUNTER_BUCKET, counter)
    quote
        $(QuoteNode(counter.count))[] += 1
        $(QuoteNode(key))
    end
end

count_user_a() = @count a
count_user_b() = @count b

counters() = values(StaticStorages.getbucket(COUNTER_BUCKET))

function test_count()
    for c in counters()
        c.count[] = 0
    end

    count_user_a()
    count_user_b()
    count_user_a()
    count_user_a()
    counts = Dict(c.tag => c.count[] for c in counters())
    @test counts[:a] == 3
    @test counts[:b] == 1

    ka = count_user_a()
    ca = StaticStorages.get(COUNTER_BUCKET, ka)
    @test ca.count[] == 4
    @test ca.tag == :a
end

end  # module

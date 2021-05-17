"""
    StaticStorages.BucketKey()

Generate a unique bucket key.

Typically, this should be called at top-level scope and assigned to a constant
for later use.

```julia
const MY_BUCKET_KEY = StaticStorages.BucketKey()
```
"""
StaticStorages.BucketKey

"""
    StaticStorages.put!(__module__, [bucket::BucketKey,] value) -> key

Put `value` in a static storage.  This is typically done during macro expansion
time.
"""
StaticStorages.put!

"""
    StaticStorages.get([bucketkey::BucketKey,] key::StorageKey) -> value or nothing

Retrieve the object inserted by `StaticStorages.put!`.
"""
StaticStorages.get

"""
    StaticStorages.getbucket(bucketkey::BucketKey) -> dict or nothing
"""
StaticStorages.getbucket

StorageKey() = StorageKey(uuid4())

BucketKey() = BucketKey(uuid4())
const DEFAULT_BUCKET_KEY = BucketKey()

const StorageDict = Dict{StorageKey,Any}
const BucketDict = Dict{BucketKey,StorageDict}
const BUCKETS = BucketDict()

const EMPTY_DICT = Dict{Union{},Union{}}()

StaticStorages.get(bucketkey::BucketKey, key::StorageKey) =
    get(get(BUCKETS, bucketkey, EMPTY_DICT), key, nothing)
StaticStorages.get(key::StorageKey) = StaticStorages.get(DEFAULT_BUCKET_KEY, key)

StaticStorages.getbucket(bucketkey::BucketKey) = get(BUCKETS, bucketkey, nothing)

#=
StaticStorages.getbucket!(bucketkey::BucketKey) = get!(StorageDict, BUCKETS, bucketkey)
=#

const LOCAL_BUCKETS_NAME = gensym("LOCAL_BUCKETS_NAME")

StaticStorages.put!(__module__::Module, value) =
    StaticStorages.put!(__module__, DEFAULT_BUCKET_KEY, value)

function StaticStorages.put!(__module__::Module, bucketkey::BucketKey, value)
    key = StorageKey()
    get!(StorageDict, BUCKETS, bucketkey)[key] = value

    # Precompilation support
    local_buckets = try
        getfield(__module__, LOCAL_BUCKETS_NAME)
    catch
        nothing
    end
    if local_buckets === nothing
        local_buckets = BucketDict()
        @gensym StaticStoragesInit
        expr = quote
            module $StaticStoragesInit
            __init__() = merge!(merge!, $(@__MODULE__).BUCKETS, LOCAL_BUCKETS)
            const LOCAL_BUCKETS = $(QuoteNode(local_buckets))
            end
            const $LOCAL_BUCKETS_NAME = $StaticStoragesInit.LOCAL_BUCKETS
        end
        Base.eval(__module__, Expr(:toplevel, expr.args...))
    end
    get!(StorageDict, local_buckets, bucketkey)[key] = value

    return key
end

module TestPutGet

using StaticStorages
using StaticStorages.Implementations: DEFAULT_BUCKET_KEY, LOCAL_BUCKETS_NAME
using Test

const SPECIAL_BUCKET_KEY = StaticStorages.BucketKey()

const KEY1 = StaticStorages.put!(@__MODULE__, gensym(:value))
const KEY2 = StaticStorages.put!(@__MODULE__, [])
const KEY3 = StaticStorages.put!(@__MODULE__, SPECIAL_BUCKET_KEY, [])

const VALUE1 = StaticStorages.get(KEY1)
const VALUE2 = StaticStorages.get(KEY2)
const VALUE3 = StaticStorages.get(SPECIAL_BUCKET_KEY, KEY3)

function test_get_hit()
    @test StaticStorages.get(KEY1) === VALUE1
    @test StaticStorages.get(KEY2) === VALUE2
    @test StaticStorages.get(SPECIAL_BUCKET_KEY, KEY3) === VALUE3
end

function test_get_miss()
    @test StaticStorages.get(SPECIAL_BUCKET_KEY, KEY1) === nothing
    @test StaticStorages.get(SPECIAL_BUCKET_KEY, KEY2) === nothing
    @test StaticStorages.get(KEY3) === nothing
end

macro local_buckets()
    esc(LOCAL_BUCKETS_NAME)
end

local_buckets() = @local_buckets
local_storages() = get(local_buckets(), DEFAULT_BUCKET_KEY, nothing)

function test_local_buckets()
    @test local_storages()[KEY1] === VALUE1
    @test local_storages()[KEY2] === VALUE2
    @test local_buckets()[SPECIAL_BUCKET_KEY][KEY3] === VALUE3
end

function test_getbucket()
    @test StaticStorages.getbucket(SPECIAL_BUCKET_KEY) == Dict(KEY3 => VALUE3)
end

end  # module

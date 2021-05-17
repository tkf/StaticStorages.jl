baremodule StaticStorages

import UUIDs

struct BucketKey
    value::UUIDs.UUID
end

struct StorageKey
    value::UUIDs.UUID
end

function put! end
function get end
function getbucket end

module Implementations

using UUIDs: UUID, uuid4

using ..StaticStorages: StaticStorages, BucketKey, StorageKey

include("utils.jl")
include("implementations.jl")

end  # module Implementations

Implementations.define_docstrings()

end  # baremodule StaticStorages

module Utils

using Base.Filesystem: joinpath, isfile
using UrlDownload
using ZipFile
using CSV
using DataFrames
using Scratch

export get_single_csv_zip, file_cache

function get_single_csv_zip(url)
    @info "Downloading" url
    zip_file = urldownload(
        url;
        compress = :zip,
        multifiles = true
    )
    file = nothing
    for f in zip_file
        if f isa CSV.File
            file = f
            break
        end
    end
    DataFrame(file)
end


function file_cache(path, get_fn, read_fn, write_fn)
    function inner(args...; kwargs...)
        full_path = joinpath(cache, path)
        if isfile(full_path)
            @info "Using cached $full_path"
            return read_fn(full_path)
        end
        ret = get_fn(args..., kwargs...)
        if full_path !== nothing
            mkpath(dirname(full_path))
            write_fn(full_path, ret)
        end
        return ret
    end
    inner
end

cache::Union{Nothing, String} = nothing

function __init__()
    global cache = get_scratch!(@__MODULE__, "cache")
end

end

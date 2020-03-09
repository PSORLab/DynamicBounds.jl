module pDELib

const PROTECTED_LIBS = ["PerezGalvan2017", "Sahlodin2011", "Scott2013",
                        "Shen2017", "Wilhelm2019"]

pdelib_dir = joinpath(dirname(pathof(DiffEqRelax)), "library", "..")

"""
$(TYPEDSIGNATURES)
"""
function fetch_instance(style::R, instance::S) where {R<:AbstractString, S<:AbstractString}
    pname = replace(splitdir(instance)[end], Pair(".jl", ""))
    nakeinstance = replace(instance, Pair(".jl", ""))
    if isfile(joinpath(minlplib_dir, "instances", "$(nakeinstance).jl"))
        m = include(joinpath(minlplib_dir, "instances", "$(nakeinstance).jl"))
    else
        @warn "No instance detected..."
        return nothing
    end
    return prob
end

"""
$(TYPEDSIGNATURES)
"""
function fetch_instance(lib::S, instance::T) where {R<:AbstractString,
                                                    S<:AbstractString,
                                                    T<:AbstractString}
end

"""
$(TYPEDSIGNATURES)
"""
function add_to_lib()
end

"""
$(TYPEDSIGNATURES)
"""
function remove_from_lib()

    # Library protection
    if libname in PROTECTED_LIBS
        error("Cannot remote instances from protected libraries $(libname)")
        return
    end

    # Finding instance
    if !isfile(joinpath(pdelib_dir, libname, "$(pname).jl"))
        @warn "No instances detected to remove."
        return
    end

    # Removing instance
    @warn "Removing instance $(pname) from library $(libname)"
    rm(joinpath(pdelib_dir, libname, "$(pname).jl"))

    return
end

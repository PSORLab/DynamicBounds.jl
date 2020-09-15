# Copyright (c) 2020: Matthew Wilhelm & Matthew Stuber.
# This work is licensed under the Creative Commons Attribution-NonCommercial-
# ShareAlike 4.0 International License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative
# Commons, PO Box 1866, Mountain View, CA 94042, USA.
#############################################################################
# DynamicBounds.jl
# A package for compute bounds and relaxations of the solutions of
# parametric differential equations.
# See https://github.com/PSORLab/DynamicBoundsBase.jl
#############################################################################
# src/library.jl
# A module containing the access functions and library utilities for the
# library of relaxation problem benchmarks.
#############################################################################

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

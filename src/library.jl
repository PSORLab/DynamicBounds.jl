# Copyright (c) 2020: Matthew Wilhelm & Matthew Stuber.
# This work is licensed under the Creative Commons Attribution-NonCommercial-
# ShareAlike 4.0 International License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative
# Commons, PO Box 1866, Mountain View, CA 94042, USA.
#############################################################################
# DynamicBounds.jl
# A package for compute bounds and relaxations of the solutions of
# parametric differential equations.
# See https://github.com/PSORLab/DynamicBounds.jl
#############################################################################
# src/library.jl
# A module containing the access functions and library utilities for the
# library of relaxation problem benchmarks.
#############################################################################

export STANDARD_LIBRARY, reinitialize_standard_lib!, fetch_instance

const STANDARD_LIB_PATH = joinpath(@__DIR__(), "library")
const PROTECTED_LIBS = ["pODEs"]

mutable struct LibraryProblem
    prob
    id::Symbol
    desc::String
    source::String
    url::String
end

const STANDARD_LIBRARY = LibraryProblem[]

function reinitialize_standard_lib!()
    for folder in PROTECTED_LIBS
        for f in readdir(joinpath(STANDARD_LIB_PATH, folder))
            include(joinpath(STANDARD_LIB_PATH, folder, f))
            lib_prob = LibraryProblem(prob, id, desc, source, url)
            push!(STANDARD_LIBRARY, lib_prob)
        end
    end
end

pdelib_dir = joinpath(@__DIR__(), "library")
reinitialize_standard_lib!()

"""
    fetch_instance
"""
function fetch_instance(lib::String, instance::String)
    simple_instance = replace(instance, Pair(".jl", ""))
    if isfile(joinpath(pdelib_dir, lib, "$(simple_instance).jl"))
        include(joinpath(pdelib_dir, lib, "$(simple_instance).jl"))
        return LibraryProblem(prob, id, desc, source, url)
    else
        @warn "No instance detected..."
        return nothing
    end
end
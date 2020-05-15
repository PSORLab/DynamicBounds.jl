push!(LOAD_PATH,"../src/")

using Documenter, DynamicBounds, DynamicBoundsBase, DynamicBoundspODEsIneq, DynamicBoundspODEsDiscrete

makedocs(modules = [DynamicBounds, DynamicBoundsBase],
         doctest = false,
         format = Documenter.HTML(),
         authors = "Matthew Wilhelm",
         sitename = "DynamicBounds.jl: Nonlinear Interval Bounds and State Relaxations of Differential Equations",
         pages = ["Introduction" => "index.md",
                  "DynamicsBoundsBase, An extendable abstraction layer" => "Base/Base.md",
                  "Discrete-Time Differential Relaxations" => "pODEsDiscrete/pODEsDiscrete.md",
                  "Continuous-Time Differential Relaxations" => "pODEsIneq/pODEsIneq.md",
                  "Contributing to DynamicBounds" => "contributing.md",
                  "References" => "ref.md"]
)

deploydocs(repo = "github.com/PSORLab/DynamicBounds.jl.git")

# Common modeling primitives are found here
abstract type SteadyStateInternalVariable end

struct EmptyInternalVariableModel <: SteadyStateInternalVariable
end

struct EmptyInternalVariableCache
end

struct EmptyInternalVariable
end

setup_internal_model_cache(cv, ::EmptyInternalVariableModel) = EmptyInternalVariableCache()

function state(model_cache::EmptyInternalVariableCache, geometry_cache, qp::QuadraturePoint, time)
    return EmptyInternalVariable()
end

abstract type AbstractSourceTerm end

include("core/coefficients.jl")

include("core/boundary_conditions.jl")

abstract type AbstractBilinearIntegrator end
include("core/mass.jl")
include("core/diffusion.jl")

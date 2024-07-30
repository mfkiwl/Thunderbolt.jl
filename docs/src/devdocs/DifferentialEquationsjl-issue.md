# Brain flush about relevant design decisions

https://github.com/SciML/DifferentialEquations.jl/issues/997

My personal roadmap is to publish [Thunderbolt.jl](https://github.com/termi-official/Thunderbolt.jl/) soon, which is a multiphysics framework which tries to be close to the design of the libraries in the DifferentialEquations.jl ecosystem, and to upstream relevant parts (after cleaning up and settling the design). 

In Thunderbolt.jl I approach the outlined problems as follows (in the spoiler because likely not relevant for most readers). I put it here to see what problems come if we follow one approach deeper into the PDE rabbit hole (multiphysics/coupled problems). I hope that we can learn something about the interface design from this description.

**1,2,3,5** I do not have a clear separation between the hypothetic `PDEFunction` and the `PDEProblem`, because I could not figure out how to untie them in a modular and generic fashion, yet. Instead I have a granular distinction between the different types of PDE problems which I encounter (CoupledProblem, SplitProblem, ParitionedProblem,PointwiseProblem,QuasiStaticNonlinearProblem,QuasiStaticDAEProblem...). I ended up here because I am not sure what the distinguishing property between the problems should be (in contrast to ODE/SDE/...-Problems, where it is immediately clear).

**4,7** When constructing the problem from some model the discrete mesh (with some coordinate system), a discretization technique and boundary condition information is passed. This way the problem can cache the boundary condition information for a specific discretization and it also directly has the solution vector sizes (+meta information about the degrees of freedom). This way I can only handle a limited number of methods from class B (partitioned, basically method of lines) above and technically it should be possible to provide support for A (not touched this one yet).

**6** Solvers are defined per problem, as in the SciML ecosystem. However, this does not feel like the best choice due to the fine granularity of the problems described above. Basically when constructing the solvers I am constructing a sequence of operators, such that I get discrete (Non)linearFunctions of the form $f(u,t)$ plus caches for evaluating f, as well as caches for the inner solvers (e.g. "NewtonRaphsonCache", which is very similar to NonlinearSolve.jl . The operator is probably closest to a `PDEFunction`. However, I can not find a way to hoist the operator construction directly into the `*Problem`s yet, because different solvers might need different operators. I **think** we can do the hoisting and I just had not enough time to figure out how to do it properly in the data structures.

**8** Kinda of a blocker for releasing my package public. I am currently basically poking around in the solver caches with dispatches. Since I want to interface against the SciML ecosystem in the long term anyway I have not bothered investing time. But I have something analogue to the TimeChoiceIterator in mind. I should note here that it is usually impossible to store the the full space-time solution in RAM (in contrast to e.g. pure small ODE problems). It should be just made clear that evaluating $u(x,t)$ is possible, but quite costly and comes with inaccurracies if the mesh is nonlinear (because we basically have to find where to evaluate, which usually involves solving a nonlinear problem). It should also be considered that many problems involve more than one field (e.g. "heat and mechanics" fields), hence we also need some way to distinguish between fields in the iterator.

I have not given much details on the caching infrastructure since I am currently reworking it (and I honestly do not think that in depth detail here really will help with the problems). But the idea is similar to what is done in any package in the DifferentialEquations.jl ecosystem. Solvers construct caches and use them to control dispatches. 

The obvious problem with my approach is that we do not clearly separate between modeling and solver. Yes, it allows that the model structure can be easier utilized, but I think we should be able to get an interface with a clearer separation and better reusability of individual components.
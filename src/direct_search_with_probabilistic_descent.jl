# Direct Search with Probabilistic Descent as described in Gratton2014:
#
#  S. Gratton, C. W. Royer, L. N. Vicente, and Z. Zhang, Direct search 
#  based on probabilistic descent, preprint 14-11, Dept. Mathematics, Univ. Coimbra.
#  http://www.mat.uc.pt/~lnv/papers/ds-random.pdf
#

# Generate num random vectors on the n-dimensional, unit (hyper)sphere.
# This is the Muller-Marsaglia method as described on the page:
#   http://mathworld.wolfram.com/HyperspherePointPicking.html
function sample_unit_hypersphere(n, num = 1)
  X = randn(n, num)
  sqrootsums = 1 ./ sqrt(sum( X.^2, 1 ))
  broadcast(*, sqrootsums, X)
end

type RandomDirectionGen <: DirectionGenerator
  numDimensions::Int64
  numDirections::Int64
end

function directions_for_k(rdg::RandomDirectionGen, k)
  sample_unit_hypersphere(rdg.numDimensions, rdg.numDirections)
end

# A MirroredRandomDirectionGen generates half of the directions randomly and then
# mirrors by negating them.
type MirroredRandomDirectionGen <: DirectionGenerator
  numDimensions::Int64
  numDirections::Int64

  MirroredRandomDirectionGen(numDims, numDirections) = begin
    if numDirections % 2 == 1
      throw("the number of directions must be even")
    end
    new(numDims, numDirections)
  end
end

function directions_for_k(rdg::MirroredRandomDirectionGen, k)
  r = sample_unit_hypersphere(rdg.numDimensions, int(rdg.numDirections/2))
  [r -r]
end

DirectSearchProbabilisticDescentDefaultParameters = {
  :NumDirections => 2, # This should be a function of Gamma and Phi for the GSS but 2 is often enough
}

function direct_search_probabilistic_descent(parameters)
  params = Parameters(parameters, DirectSearchProbabilisticDescentDefaultParameters)
  params[:DirectionGenerator] = MirroredRandomDirectionGen(numdims(params[:Evaluator]), params[:NumDirections])
  GeneratingSetSearcher(params)
end

mutable struct CovarIS{T} <: AbstractMatrix{T}
    IS:: AbstractMatrix{T}
    factors
end

function CovarIS(IS::AbstractMatrix)
    factors = nothing
    CovarIS(IS,factors)
end


Base.inv(C::CovarIS) = C.IS

Base.size(C::CovarIS) = size(C.IS)

function Base.:*(C::CovarIS, v::AbstractVector{Float64})
    if C.factors != nothing
        return C.factors \ v
    else
        return C.IS \ v
    end
end

Base.:*(C::CovarIS, v::SparseVector{Float64,Int}) = C*full(v) 


function A_mul_B(C::CovarIS, M::AbstractMatrix{Float64})
    if C.factors != nothing
        return C.factors \ M
    else
        return C.IS \ M
    end
end

# call to C * M
Base.:*(C::CovarIS, M::AbstractMatrix{Float64}) = A_mul_B(C,M)

# The following two definitions are necessary; otherwise the full C matrix will be formed when
# calculating C * M' or C * M.'

# call to C * M' (conjugate transpose: C Mᴴ)
Base.A_mul_Bc(C::CovarIS, M::AbstractMatrix{Float64}) = A_mul_B(C,M')
# call to C * M.' (transpose: C Mᵀ)
Base.A_mul_Bt(C::CovarIS, M::AbstractMatrix{Float64}) = A_mul_B(C,M.')


function Base.getindex(C::CovarIS, i::Int,j::Int)
    ei = zeros(eltype(C),size(C,1)); ei[i] = 1
    ej = zeros(eltype(C),size(C,1)); ej[j] = 1

    return (ej'*(C*ei))[1]
end


Base.:\(C::CovarIS, M::AbstractArray{Float64,2}) = C.IS * M

function factorize!(C::CovarIS)
    #    C.factors = cholfact(Symmetric(C.IS), Val{true})
    C.factors = cholfact(Symmetric(C.IS))
    #    C.factors = cholfact(C.IS, Val{true})
end


function diagMtCM(C::CovarIS, M::AbstractMatrix{Float64})
    if C.factors != nothing
        return squeeze(sum((abs.(C.factors[:PtL]\M)).^2,1),1)
    else
        return diag(M'*(C.IS \ M))
    end
end

function diagLtCM(L::AbstractMatrix{Float64}, C::CovarIS, M::AbstractMatrix{Float64})
    if C.factors != nothing
        return squeeze(sum((C.factors[:PtL]\M).*(C.factors[:PtL]\L),1),1)
    else
        return diag(L'*(C.IS \ M))
    end
end



# MatFun: a matrix defined by a function representing the matrix product

mutable struct MatFun{T}  <: AbstractMatrix{Float64}
    sz::Tuple{T,T}
    fun:: Function
    funt:: Function
end

Base.size(MF::MatFun) = MF.sz

for op in [:+, :-]; @eval begin
    function Base.$op(MF1::MatFun, MF2::MatFun)
        return MatFun(size(MF1),x -> $op(MF1.fun(x),MF2.fun(x)), x -> $op(MF2.funt(x),MF1.funt(x)))
    end

    Base.$op(MF::MatFun, S::AbstractSparseMatrix) = $op(MF,MatFun(S))
    Base.$op(S::AbstractSparseMatrix, MF::MatFun) = $op(MatFun(S),MF)
end
end

Base.:*(MF::MatFun, x::AbstractVector) = MF.fun(x)

if VERSION >= v"0.7.0-beta.0"
    Base.:*(MF::MatFun, M::AbstractMatrix) = cat([MF.fun(M[:,i]) for i = 1:size(M,2)]..., dims = 2)
else
    Base.:*(MF::MatFun, M::AbstractMatrix) = cat(2,[MF.fun(M[:,i]) for i = 1:size(M,2)]...)
end

function A_mul_B(MF1::MatFun, MF2::MatFun)
    if size(MF1,2) != size(MF2,1)
        error("incompatible sizes")
    end
    return MatFun((size(MF1,1),size(MF2,2)),x -> MF1.fun(MF2.fun(x)), x -> MF2.funt(MF1.funt(x)))
end

Base.:*(MF1::MatFun, MF2::MatFun) = A_mul_B(MF1,MF2)
Base.:*(MF::MatFun, S::AbstractSparseMatrix) = MF * MatFun(S)
Base.:A_mul_Bc(S::AbstractSparseMatrix, MF::MatFun) = MatFun(S) * MF
Base.:*(S::AbstractSparseMatrix,MF::MatFun) = MatFun(S) * MF

for op in [:/, :*]; @eval begin
    Base.$op(MF::MatFun, a::Number) = MatFun(size(MF),x -> $op(MF.fun(x),a),x -> $op(MF.funt(x),a))
end
end

Base.:*(a::Number, MF::MatFun) = MatFun(size(MF),x -> a*MF.fun(x),x -> a*MF.funt(x))


function Base.:^(MF::MatFun,n::Int)
    if n == 0
        return MatFun(size(MF),identity,identity)
    else
        return MF * (MF^(n-1))
    end
end

Base.:transpose(MF:: MatFun) = MatFun((MF.sz[2],MF.sz[1]),MF.funt,MF.fun)
if VERSION >= v"0.7.0-beta.0"
    Base.:adjoint(MF:: MatFun) = MatFun((MF.sz[2],MF.sz[1]),MF.funt,MF.fun)
end

Base.Ac_mul_B(MF:: MatFun, x::AbstractVector) = MF.funt(x)
Base.Ac_mul_B(MF1:: MatFun, MF2:: MatFun) = A_mul_B(MF1',MF2)
Base.A_mul_Bc(MF1:: MatFun, MF2:: MatFun) = A_mul_B(MF1,MF2')

MatFun(S::AbstractSparseMatrix) = MatFun(size(S), x -> S*x, x -> S'*x)


# CovarHPHt representing H P Hᵀ

mutable struct CovarHPHt{T} <: AbstractMatrix{T}
    P:: AbstractMatrix{T}
    H:: AbstractMatrix{T}
end

Base.size(C::CovarHPHt) = (size(C.H,1),size(C.H,1))

#function CovarHPHt(P::AbstractMatrix,H::AbstractMatrix)
#    CovarIS(IS,factors)
#end

function Base.:*(C::CovarHPHt, v::AbstractVector{Float64})
    return C.H * (C.P * (C.H' * v))
end


function A_mul_B(C::CovarHPHt, M::AbstractMatrix{Float64})
    return C.H * (C.P * (C.H' * M))
end

# call to C * M
Base.:*(C::CovarHPHt, M::AbstractMatrix{Float64}) = A_mul_B(C,M)

# The following two definitions are necessary; otherwise the full C matrix will be formed when
# calculating C * M' or C * transpose(M)

# call to C * M' (conjugate transpose: C Mᴴ)
Base.A_mul_Bc(C::CovarHPHt, M::AbstractMatrix{Float64}) = A_mul_B(C,M')
# call to C * transpose(M) (transpose: C Mᵀ)
Base.A_mul_Bt(C::CovarHPHt, M::AbstractMatrix{Float64}) = A_mul_B(C,transpose(M))



function Base.getindex(C::CovarHPHt, i::Int,j::Int)
    ei = zeros(eltype(C),size(C,1)); ei[i] = 1
    ej = zeros(eltype(C),size(C,1)); ej[j] = 1

    return (ej'*(C*ei))[1]
end

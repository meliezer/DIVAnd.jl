"""
R = divand_obscovar(epsilon2,m)

Create a matrix representing the observation error covariance R of size m x m.

If epsilon2 is a scalar, then R = epsilon2 * I
If epsilon2 is a vector, then R = diag(epsilon2)
If epsilon2 is a matrix, then R = epsilon2
"""
divand_obscovar(epsilon2::Number,m) = Diagonal([epsilon2 for i=1:m])
divand_obscovar(epsilon2::Vector,m) = Diagonal(epsilon2)
divand_obscovar(epsilon2::AbstractMatrix,m) = epsilon2


# Functions to manage a statevector which is a concatenation of
# several variables under the control of a mask

# N is the dimension of all variables
type statevector{nvar_,N}
    mask::NTuple{nvar_,BitArray{N}}
    nvar::Int
    numels::Vector{Int}
    numels_all::Vector{Int}
    size::Vector{NTuple{N,Int}}
    ind::Vector{Int}
    n::Int
    packed2unpacked::Vector{Vector{Int}}
    unpacked2packed::Vector{Vector{Int}}
end

function unpack_(v,mask)
    tmp = zeros(eltype(v),size(mask));
    tmp[mask] = v;
    return tmp[:]
end


"""
Initialize structure for packing and unpacking given their mask.

sv = statevector_init((mask1, mask2, ...))

Initialize structure for packing and unpacking
multiple variables given their corresponding land-sea mask.

Input:
  mask1, mask2,...: land-sea mask for variable 1,2,... Sea grid points correspond to one and land grid points to zero.
    Every mask can have a different shape.

Output:
  sv: structure to be used with statevector_pack and statevector_unpack.

Note:
see also statevector_pack, statevector_unpack

Author: Alexander Barth, 2009,2017 <a.barth@ulg.ac.be>
License: GPL 2 or later
"""

function statevector{nvar_,N}(masks::NTuple{nvar_,BitArray{N}})

    numels = [sum(mask)    for mask in masks]
    ind = [0, cumsum(numels)...]

    # vector mapping packed indices to unpacked indices
    packed2unpacked = [(1:length(mask))[mask[:]] for mask in masks]

    # vector mapping unpacked indices packed indices
    unpacked2packed = [unpack_(1:sum(mask),mask) for mask in masks]

    sv = statevector{nvar_,N}(
                     masks,
                     length(masks),
                     numels,
                     [length(mask) for mask in masks],
                     [size(mask) for mask in masks],
                     ind,
                     ind[end],
                     packed2unpacked,
                     unpacked2packed
                     )

    return sv
end


function statevector{nvar_,N}(masks::NTuple{nvar_,Array{Bool,N}})
    return statevector(([convert(BitArray{N},mask) for mask in masks]...))
end

"""
Pack a series of variables into a vector under the control of a mask.

x = pack(sv,(var1, var2, ...))

Pack the different variables var1, var2, ... into the vector x where `sv` is a `statevector`.
Only sea grid points are retained.

Input:
  sv: structure generated by statevector_init.
  var1, var2,...: variables to pack (with the same shape as the corresponding masks).

Output:
  x: vector of the packed elements. The size of this vector is the number of elements of all masks equal to 1.

Notes:
If var1, var2, ... have an additional trailing dimension, then this dimension is assumed
to represent the different ensemble members. In this case x is a matrix and its last dimension
is the number of ensemble members.
"""

function pack{nvar_,N,T}(sv::statevector{nvar_,N},vars::NTuple{nvar_,Array{T,N}})::Vector{T}

    k = size(vars[1],ndims(sv.mask[1])+1)

    x = Vector{T}(sv.n)

    for i=1:sv.nvar
        tmp = reshape(vars[i],sv.numels_all[i],k)
        ind = find(sv.mask[i])
        x[sv.ind[i]+1:sv.ind[i+1]] = tmp[ind]
    end

    return x
end



function packens{nvar_,N,T,Np}(sv::statevector{nvar_,N},vars::NTuple{nvar_,Array{T,Np}})::Array{T,2}

    k = size(vars[1],ndims(sv.mask[1])+1)

    x = Array{T,2}(sv.n,k)

    for i=1:sv.nvar
        tmp = reshape(vars[i],sv.numels_all[i],k)
        ind = find(sv.mask[i])
        x[sv.ind[i]+1:sv.ind[i+1],:] = tmp[ind,:]
    end

    return x
end


"""
Unpack a vector into different variables under the control of a mask.

var1, var2, ... = unpack(sv,x)
var1, var2, ... = unpack(sv,x,fillvalue)

Unpack the vector x into the different variables var1, var2, ...
where `sv` is a `statevector`.

Input:
  sv: structure generated by statevector_init.
  x: vector of the packed elements. The size of this vector is the number of elements equal to 1
    in all masks.

Optional input parameter:
  fillvalue: The value to fill in var1, var2,... where the masks correspond to a land grid point. The default is zero.

Output:
  var1, var2,...: unpacked variables.

Notes:
If x is a matrix, then the second dimension is assumed
to represent the different ensemble members. In this case,
var1, var2, ... have also an additional trailing dimension.
"""

function unpack{nvar_,N,T}(sv::statevector{nvar_,N},x::Vector{T},fillvalue = 0)
    out = ntuple(i -> begin
                v = Array{T,N}(sv.size[i]);
                v[:] = fillvalue
                v[sv.mask[i]] = x[sv.ind[i]+1:sv.ind[i+1]]

                return v
                end,Val{nvar_})

    return out
end

# output is Tuple{_<:Array{Float64,N}} (not completely type-stable)

function unpackens{nvar_,N,T}(sv::statevector{nvar_,N},x::Array{T,2},fillvalue = 0)

    const k = size(x,2)

    out = ntuple(i -> begin
                v = Array{T,N+1}((sv.size[i]...,k));
                v[:] = fillvalue
                ind = find(sv.mask[i])

                tmp = reshape(v,sv.numels_all[i],k)
                tmp[ind,:] = x[sv.ind[i]+1:sv.ind[i+1],:]

                return v
                end,Val{nvar_})::NTuple{nvar_,Array{T,N+1}}

    return out
end


"""
subscripts = ind2ind(sv,index)

Compute from linear index in the packed state vector a tuple of subscripts.
The first element of the subscript indicates the variable index and the remaining the spatial subscripts.
"""

function Base.ind2sub(sv::statevector,index::Integer)

    # variable index
    ivar = sum(sv.ind .< index)

    # substract offset
    vind = index - sv.ind[ivar]

    # spatial subscript
    subscript = ind2sub(sv.size[ivar],sv.packed2unpacked[ivar][vind])

    return (ivar,subscript...)

end


"""
ind = statevector_sub2ind(sv,subscripts)

Compute from a tuple of subscripts the linear index in the packed state vector.
The first element of the subscript indicates the variable index and the remaining the spatial subscripts.
"""

function Base.sub2ind(sv::statevector,subscripts::Tuple)

    # index of variable
    ivar = subscripts[1]

    # offset of variable
    ioff = sv.ind[ivar]

    # linear index in ivar-th array
    index = sub2ind(sv.size[ivar],Tuple(subscripts[2:end])...)

    return ioff + sv.unpacked2packed[ivar][index]

end


# full names with prefix

statevector_init(masks::Tuple) = statevector(masks)
statevector_pack(sv::statevector,vars::Tuple) = pack(sv,vars)
statevector_unpack(sv::statevector,x,fillvalue = 0) = unpack(sv,x,fillvalue)
statevector_sub2ind(sv::statevector,subscripts::Tuple) = sub2ind(sv,subscripts)
statevector_ind2sub(sv::statevector,index::Integer) = ind2sub(sv,index)

# Copyright (C) 2009,2017 Alexander Barth <a.barth@ulg.ac.be>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; If not, see <http://www.gnu.org/licenses/>.


#  LocalWords:  statevector init GPL

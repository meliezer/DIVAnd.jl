# Testing DIVAnd in 1 dimension.

# grid of background field
xi = collect(linspace(0,1,11));

x = [.4; .6];
f = [.4; .6];

mask = trues(xi);
#mask[[1 end]] = false;

pm = ones(xi) / (xi[2]-xi[1]);
len = 1
epsilon2 = 0.5

fi,s = DIVAndrun(mask,(pm,),(xi,),(x,),f,len,epsilon2);


D = DIVAnd_laplacian(Val{:sparse},mask,(pm,),ones(size(mask)),falses(2))
Dsym = +([s.Dx[i]'*(s.WEs[i] *(s.WEs[i] *(s.Dx[i]))) for i in 1:ndims(mask)]...)

# only the same if pm = 1
display(full(D))
display(full(Dsym))

Dx = sparse_gradient(Val{:sparse},mask,(pm,),falses(ndims(mask)))
# note s.Dx is not equal to Dx at the boundary

pmn = (pm,)
S = [sparse_stagger(size(mask),i)  for i in 1:ndims(mask)];
pmn_staggerd = [S[i] * pmn[i] for i in 1:ndims(mask)];
mask_staggerd = [(S[i] * mask[:]) .== 1 for i in 1:ndims(mask)];

Dsym2 = +([Dx[i]' * Dx[i] for i in 1:ndims(mask)]...)

# works!
display(full(Dsym2))

@show Dsym2 * xi[:].^2
@show D * xi[:].^2


# variable resolution

pm = [Float64(i)+1 for i in linspace(0,1,11)]
pmn = (pm,)
xe = [0; cumsum(1./pm)]
xi = (xe[1:end-1] +xe[2:end])/2

len = 0.1
epsilon2 = 0.5

fi,s = DIVAndrun(mask,(pm,),(xi,),(x,),f,len,epsilon2);

fimax = maximum(fi[2:end-1])
#@test xi[fi .== fimax][1] == x[2]

D = DIVAnd_laplacian(Val{:sparse},mask,(pm,),ones(size(mask)),falses(2))
Dx = sparse_gradient(Val{:sparse},mask,(pm,),falses(ndims(mask)))

Dsym2 = +([Dx[i]' * Dx[i] for i in 1:ndims(mask)]...)

# small differences
display(full(D))
display(full(Dsym2))

# Dsym2 is not as precise
@show Dsym2 * xi[:].^2
@show D * xi[:].^2

nothing




# Copyright (C) 2014,2017 Alexander Barth <a.barth@ulg.ac.be>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, see <http://www.gnu.org/licenses/>.

# Testing DIVAnd in 3 dimensions.

using Base.Test

# function to interpolate
fun(x,y,z) = sin(6x) * cos(6y) * sin(6z)

# grid of background field
xi,yi,zi = ndgrid(linspace(0,1.,15),linspace(0,1.,15),linspace(0,1.,15));
fi_ref = fun.(xi,yi,zi)

ϵ = eps()
# grid of observations
x,y,z = ndgrid(linspace(ϵ,1-ϵ,10),linspace(ϵ,1-ϵ,10),linspace(ϵ,1-ϵ,10));
x = x[:];
y = y[:];
z = z[:];

# observations
f = fun.(x,y,z)

# all points are valid points
mask = trues(xi);

# this problem has a simple cartesian metric
# pm is the inverse of the resolution along the 1st dimension
# pn is the inverse of the resolution along the 2nd dimension
# po is the inverse of the resolution along the 3rd dimension
pm = ones(xi) / (xi[2,1,1]-xi[1,1,1]);
pn = ones(xi) / (yi[1,2,1]-yi[1,1,1]);
po = ones(xi) / (zi[1,1,2]-zi[1,1,1]);

# correlation length
len = 0.1;

# obs. error variance normalized by the background error variance
epsilon2 = 0.01;

# fi is the interpolated field
fi,s = DIVAndrun(mask,(pm,pn,po),(xi,yi,zi),(x,y,z),f,len,epsilon2;alphabc=0);

# compute RMS to background field
rms = sqrt(mean((fi_ref[:] - fi[:]).^2));

@test rms < 0.04


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

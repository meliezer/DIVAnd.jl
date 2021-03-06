
"""
    d = distance(lat1,lon1,lat2,lon2)

Compute the great-circle distance between the points (`lat1,`lon1`) and (`lat2,`lon2`).
The units of all input and output parameters are degrees.
"""
function distance(lat1,lon1,lat2,lon2)
    #https://en.wikipedia.org/w/index.php?title=Great-circle_distance&oldid=749078136#Computational_formulas

    Δλ = π/180 * (lon2 - lon1)
    ϕ1 = π/180 * lat1
    ϕ2 = π/180 * lat2
    cosΔσ = sin(ϕ1)*sin(ϕ2) + cos(ϕ1)*cos(ϕ2)*cos(Δλ)

    eins = one(cosΔσ)
    cosΔσ = max(min(cosΔσ,eins),-eins)
    Δσ = acos(cosΔσ)
    return 180/π * Δσ
end

"""
    d = distance([lon1,lat1],[lon2,lat2])

The same as `distance(lat1,lon1,lat2,lon2)` but there the arguments are vectors 
and the order is longitude then latitude.

The units of all input and output parameters are degrees.
"""
function distance(xi::Vector{T},xj::Vector{T}) where T
    return distance(xi[2],xi[1],xj[2],xj[1])
end

"""
    pm,pn = DIVAnd_metric(lon,lat)

Compute metric scale factors `pm` and `pn` based on the arrays
longitude `lon` and latitude `lat`. The variables pm and pn
represent the inverse of the local resolution in meters using
the mean Earth radius.
"""
function DIVAnd_metric(lon::Array{T,2},lat::Array{T,2}) where T
    sz = size(lon)
    i = 2:sz[1]-1
    j = 2:sz[2]-1

    dx = distance.(lat[i-1,:],lon[i-1,:],lat[i+1,:],lon[i+1,:])/2
    dx = cat(1,dx[1:1,:],dx,dx[end:end,:])

    dy = distance.(lat[:,j-1],lon[:,j-1],lat[:,j+1],lon[:,j+1])/2
    dy = cat(2,dy[:,1:1],dy,dy[:,end:end])

    dx = real(dx)
    dy = real(dy)

    dx = deg2m(dx)
    dy = deg2m(dy)

    pm = 1 ./ dx
    pn = 1 ./ dy

    return pm,pn
end

function DIVAnd_metric(lon::AbstractVector,lat::AbstractVector)
    return DIVAnd_metric(ndgrid(lon,lat)...)
end

function deg2m(dlat)
    # Mean radius (http://en.wikipedia.org/wiki/Earth_radius)
    R = 6371.009e3;

    return dlat*(2*pi*R)/360;
end

# Copyright (C) 2014, 2017 Alexander Barth <a.barth@ulg.ac.be>
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

"""
    cfilled = ufill(c,valex)

Replace values in `c` equal to `valex` by averages of surrounding points.

"""

function ufill(c::Array{T,3},valex::Number) where T
    imax,jmax,kmax = size(c)
    work = zeros(eltype(c),imax+2, jmax+2, kmax+2)
    work2 = zeros(eltype(c),imax+2, jmax+2, kmax+2)

    iwork = zeros(Int8,imax+2, jmax+2, kmax+2)
    iwork2 = zeros(Int8,imax+2, jmax+2, kmax+2)

    cfilled = copy(c)
    ufill!(cfilled,valex,work,work2,iwork,iwork2)

    return cfilled
end



function ufill(c::Array{T,2},valex::Number) where T
    return ufill(reshape(c,(size(c,1), size(c,2), 1)),valex)
end

"""
    ufill(c::Array{T,2},mask::AbstractArray{Bool}) where T

`mask` is true where `c` is valid.
"""
function ufill(c::Array{T,N},mask::AbstractArray{Bool}) where N where T
    c2 = copy(c)
    # better way
    valex = T(-9999.)
    c2[.!mask] = valex
    
    return ufill(c2,valex)
end

ufill(c::DataArray) = ufill(c.data,.!ismissing.(c))


function ufill!(c,valexc,work,work2,iwork::Array{Int8,3},iwork2::Array{Int8,3})
    const A1 = 5
    const A2 = 0
    const A3 = 0

    imax,jmax,kmax = size(c)

    for j = 1:jmax+2
        for i = 1:imax+2
            work[i,j,1] = valexc
            iwork[i,j,1] = 0
            work[i,j,kmax+2] = valexc
            iwork[i,j,kmax+2] = 0
        end
    end

    for k = 1:kmax+2
        for i = 1:imax+2
            work[i,1,k] = valexc
            iwork[i,1,k] = 0
            work[i,jmax+2,k] = valexc
            iwork[i,jmax+2,k] = 0
        end
    end

    for k = 1:kmax+2
        for j = 1:jmax+2
            work[1,j,k] = valexc
            iwork[1,j,k] = 0
            work[imax+2,j,k] = valexc
            iwork[imax+2,j,k] = 0
        end
    end

    #
    # copy interior field
    for k = 1:kmax
        for j = 1:jmax
            for i = 1:imax
                work[i+1,j+1,k+1] = c[i,j,k]
                iwork[i+1,j+1,k+1] = 1
                if work[i+1,j+1,k+1] == valexc
                    iwork[i+1,j+1,k+1] = 0
                end
            end
        end
    end

    icount  =  1
    
    while icount > 0
        icount = 0

        for k = 2:kmax+1
            for j = 2:jmax+1
                for i = 2:imax+1

                    work2[i,j,k] = work[i,j,k]
                    iwork2[i,j,k] = iwork[i,j,k]

                    if iwork[i,j,k] == 0
                        work2[i,j,k] = valexc
                        icount = icount+1
                        isom = 0
                        
                        if A1 != 0
                            isom += A1 * (
                                +iwork[i+1,j,k]+iwork[i-1,j,k]
                                +iwork[i,j+1,k]+iwork[i,j-1,k])
                        end
                            
                        if A2 != 0
                            isom += A2 * (
                                iwork[i+1,j+1,k+1]+iwork[i+1,j+1,k-1]
                                +iwork[i+1,j-1,k+1]+iwork[i+1,j-1,k-1]
                                +iwork[i-1,j+1,k+1]+iwork[i-1,j+1,k-1]
                                +iwork[i-1,j-1,k+1]+iwork[i-1,j-1,k-1])
                        end
                        
                        if A3 != 0
                            isom += A3 * (
                                iwork[i,j+1,k+1]+iwork[i,j+1,k-1]
                                + iwork[i,j-1,k+1]+iwork[i,j-1,k-1]
                                + iwork[i+1,j,k+1]+iwork[i+1,j,k-1]
                                + iwork[i-1,j,k+1]+iwork[i-1,j,k-1]
                                + iwork[i+1,j+1,k]+iwork[i+1,j-1,k]
                                + iwork[i-1,j+1,k]+iwork[i-1,j-1,k])
                        end

                        if isom != 0
                            rsom = zero(eltype(c))
                            
                            # interpolate

                            if A1 != 0
                                rsom += A1 * (
                                    +iwork[i+1,j,k]*work[i+1,j,k]
                                    +iwork[i-1,j,k]*work[i-1,j,k]
                                    +iwork[i,j+1,k]*work[i,j+1,k]
                                    +iwork[i,j-1,k]*work[i,j-1,k])
                            end

                            if A2 != 0
                                rsom += A2 * (
                                    iwork[i+1,j+1,k+1]*work[i+1,j+1,k+1]
                                    +iwork[i+1,j+1,k-1]*work[i+1,j+1,k-1]
                                    +iwork[i+1,j-1,k+1]*work[i+1,j-1,k+1]
                                    +iwork[i+1,j-1,k-1]*work[i+1,j-1,k-1]
                                    +iwork[i-1,j+1,k+1]*work[i-1,j+1,k+1]
                                    +iwork[i-1,j+1,k-1]*work[i-1,j+1,k-1]
                                    +iwork[i-1,j-1,k+1]*work[i-1,j-1,k+1]
                                    +iwork[i-1,j-1,k-1]*work[i-1,j-1,k-1])
                            end

                            if A3 != 0                                
                                rsom += A3 * (
                                    iwork[i,j+1,k+1]*work[i,j+1,k+1]
                                    +iwork[i,j+1,k-1]*work[i,j+1,k-1]
                                    +iwork[i,j-1,k+1]*work[i,j-1,k+1]
                                    +iwork[i,j-1,k-1]*work[i,j-1,k-1]
                                    +iwork[i+1,j,k+1]*work[i+1,j,k+1]
                                    +iwork[i+1,j,k-1]*work[i+1,j,k-1]
                                    +iwork[i-1,j,k+1]*work[i-1,j,k+1]
                                    +iwork[i-1,j,k-1]*work[i-1,j,k-1]
                                    +iwork[i+1,j+1,k]*work[i+1,j+1,k]
                                    +iwork[i+1,j-1,k]*work[i+1,j-1,k]
                                    +iwork[i-1,j+1,k]*work[i-1,j+1,k]
                                    +iwork[i-1,j-1,k]*work[i-1,j-1,k])
                            end
                            
                            work2[i,j,k] = rsom/isom
                            iwork2[i,j,k] = 1
                        end
                    end
                end
            end
        end

        for k = 2:kmax+1
            for j = 2:jmax+1
                for i = 2:imax+1
                    work[i,j,k] = work2[i,j,k]
                    iwork[i,j,k] = iwork2[i,j,k]
                end
            end
        end
        #@show icount

    end

# copy interior points
for k = 1:kmax
    for j = 1:jmax
        for i = 1:imax
            c[i,j,k] = work[i+1,j+1,k+1]
        end
    end
end
end




"""
    hx,hy = cgradient(pmn,h)


"""
function cgradient(pmn,h)

    @assert ndims(h) == 2
    
    hx = similar(h)
    hy = similar(h)

    sz = size(h)
    # loop over the domain
    for j = 1:size(h,2)
        # previous j0 and next j1 (but still a valid index)
        j0 = max(j-1,1)
        j1 = min(j+1,sz[2])
        
        for i = 1:size(h,1)
            # previous i0 and next i1 (but still a valid index)
            i0 = max(i-1,1)
            i1 = min(i+1,sz[1])

            # finite difference
            hx[i,j] = (h[i1,j] - h[i0,j]) * pmn[1][i,j]
            hy[i,j] = (h[i,j1] - h[i,j0]) * pmn[2][i,j]

            # centered difference
            if i1 == i0+2
                hx[i,j] = hx[i,j]/2
            end
            
            if j1 == j0+2
                hy[i,j] = hy[i,j]/2
            end

        end
    end
    
    return hx,hy
end


function beforenext(ind,sz::NTuple{N,Int},dim) where N
    # previous and next index (but still a valid index)
    
    ind0 = ntuple(j -> (j == dim ? max(ind[j]-1,1) : ind[j]), N) :: NTuple{N,Int}
    ind1 = ntuple(j -> (j == dim ? min(ind[j]+1,sz[j]) : ind[j]), N) :: NTuple{N,Int}
    return ind0,ind1
end

function cgradient(pmn,h::Array{T,N}, dim) where N where T
    hx = similar(h)
    hy = similar(h)

    sz = size(h)
    
    # loop over the domain
    for ind in CartesianRange(sz)
        #ind = copy(ind)::CartesianIndex{N}
        #ind = ind::CartesianIndex{N}
        
        # previous and next index (but still a valid index)
        ind0,ind1 = beforenext(ind,sz,dim)
        
        #ind0 = ntuple(j -> (j == dim ? max(ind[j]-1,1) : ind[j]), N) :: NTuple{N,Int}
        #ind1 = ntuple(j -> (j == dim ? min(ind[j]+1,sz[j]) : ind[j]), N) :: NTuple{N,Int}        
        
        # finite difference
        hx[ind] = (h[ind1...] - h[ind0...]) * pmn[dim][ind]

        # centered difference
        if (ind[dim] != 1) && (ind[dim] != sz[dim])
            hx[ind] = hx[ind]/2
        end
    end
    
    return hx
end

function cgradientn(pmn,h::Array{T,N}) where N where T
    return ntuple(j -> cgradient(pmn,h,j),N)
end


""" 
    RL = lengraddepth(pmn,h, L;
                      h2 = h,
                      hmin = 0.001
                      )

Create the relative correlation length-scale field `RL` based on the bathymetry 
`h` and the metric `pmn` (tuple of arrays). Effectively the correlation-length 
scale is close to zero if the relative bathymetry gradients (|∇h|/h) are smaller
 than the length-scale `L` (in consistent units as `pmn`).

R_L = 1 / (1 + L |∇h| / h2)

Per default `h2` is equal to `h`. The depth `h` must be positive. `hmin` must 
have the same units as h (usually meters).
"""

function lengraddepth(pmn,h::Array{T,2}, L;
                      h2 = h,
                      hmin = 0.001 #m
                      ) where T

    
    # gradient of h
    hx,hy = cgradient(pmn,h)

    normgrad = sqrt.(hx.^2 + hy.^2)

    # avoid divisions by zero
    h2 = max.(h2,hmin)

    # creating the RL field
    RL = 1 ./ (1 + L * normgrad ./ h2)

    #RL[isnan(h)] = valex
    #RL = fill(RL,valex)
    
    return RL
end



                      

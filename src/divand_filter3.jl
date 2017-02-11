# Adapted from
# from http://julialang.org/blog/2016/02/iteration
# to deal with fill values
# 3x3x3...x3 window box filtering
# and central point weight equals sum of all other points if present
# to add: loop ntimes over the filter; need to check how to copy/update the arrays...

function divand_filter3(A::AbstractArray,fillvalue,ntimes=1)
    nd=ndims(A)
# central weight
	cw=3^nd-1
	cw=1
    out = similar(A)
    R = CartesianRange(size(A))
    I1, Iend = first(R), last(R)
    for I in R
        w, s = 0.0, zero(eltype(out))
# Define out[I] fillvalue
        out[I] = fillvalue
        for J in CartesianRange(max(I1, I-I1), min(Iend, I+I1))
	# If not a fill value
	    if !(A[J] == fillvalue)
            s += A[J]
			if (I==J)
			  w += cw 
			else
              w += 1.
			end
		end
	# end if not fill value
        end
		if w>0.0
        out[I] = s/w
		end
    end
    return out
end
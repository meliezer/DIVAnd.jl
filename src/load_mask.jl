"""deprecated"""

function load_mask(bath_name,isglobal,x0,x1,dx,y0,y1,dy,level::Number)

    level = -abs(level);

    x = ncread(bath_name,"lon")
    y = ncread(bath_name,"lat")
    nc = NetCDF.open(bath_name);

    rx = x[2]-x[1];
    ry = y[2]-y[1];
    X0 = x[1];
    Y0 = y[1];

    redx = dx/rx;
    redy = dy/ry;

    xi = x0:dx:x1;
    yi = y0:dy:y1;

    i0 = round(Int,(x0-dx-X0)/rx)+1;
    i1 = round(Int,(x1+dx-X0)/rx)+1;
    i=i0:i1;

    j0 = round(Int,(y0-dy-Y0)/ry)+1;
    j1 = round(Int,(y1+dy-Y0)/ry)+1;
    j=j0:j1;

    #xp = X0 + (i-1)*rx;
    #xp2 = mean(reshape(xp,[redx length(xp)/redx]),1);

    #i = get_index_range(X0,rx,x0,x1,dx);
    #j = get_index_range(Y0,rx,y0,y1,dy);

    b = zeros(length(i),length(j));

    if isglobal
        #if false
        i2 = mod.(i-1,size(nc["bat"] ,1))+1;
        jumps = [0; find(abs.(i2[2:end]-i2[1:end-1]) .> 1); length(i2)];



        for l=1:length(jumps)-1
            b[(jumps[l]+1):jumps[l+1],:] = nc["bat"][i2[jumps[l]+1]:i2[jumps[l+1]],j];
        end
    else
        i = maximum([minimum(i) 1]):minimum([maximum(i) length(x)]);
        j = maximum([minimum(j) 1]):minimum([maximum(j) length(y)]);
        b[:,:] = nc["bat"][i,j];
    end

    mask = b .< level;

    x = X0 + rx*(i-1);
    y = Y0 + ry*(j-1);


    # # convolution
    # Fx = round(redx);
    # Fy = round(redy);

    # Fi,Fj = ndgrid(-Fx:Fx,-Fy:Fy);
    # F = exp(-2* ((Fi/redx).^2 + (Fj/redy).^2));
    # F = F/sum(F[:]);

    # # mask as float

    # maskf = Int.(mask) + 0.
    # #m = conv2(double(mask),F,"same");
    # m = conv2(maskf,F);
    Xi,Yi = ndgrid(xi,yi);

    itp = interpolate((x,y), Int.(mask),Gridded(Linear()))
    mif = itp[xi,yi];

    mi = mif .> 1/2;
    NetCDF.close(nc);

    return  xi,yi,mi
end


"""deprecated"""
function load_mask(bath_name,isglobal,x0,x1,dx,y0,y1,dy,levels::AbstractVector)
    data = [load_mask(bath_name,isglobal,x0,x1,dx,y0,y1,dy,level) for level in levels ];

    return data[1][1],data[1][2],cat(3,[d[3] for d in data]...)
end



function load_mask(bath_name,isglobal,xi,yi,level::Number)

    dxi = xi[2] - xi[1]
    dyi = yi[2] - yi[1]

    level = -abs(level);

    x = ncread(bath_name,"lon")
    y = ncread(bath_name,"lat")
    nc = NetCDF.open(bath_name);

    rx = x[2]-x[1];
    ry = y[2]-y[1];
    X0 = x[1];
    Y0 = y[1];

    redx = dxi/rx;
    redy = dyi/ry;


    i0 = round(Int,(xi[1]-dxi-X0)/rx)+1;
    i1 = round(Int,(xi[end]+dxi-X0)/rx)+1;
    i=i0:i1;

    j0 = round(Int,(yi[1]-dyi-Y0)/ry)+1;
    j1 = round(Int,(yi[end]+dyi-Y0)/ry)+1;
    j=j0:j1;

    b = zeros(length(i),length(j));

    if isglobal
        i2 = mod.(i-1,size(nc["bat"] ,1))+1;
        jumps = [0; find(abs.(i2[2:end]-i2[1:end-1]) .> 1); length(i2)];



        for l=1:length(jumps)-1
            b[(jumps[l]+1):jumps[l+1],:] = nc["bat"][i2[jumps[l]+1]:i2[jumps[l+1]],j];
        end
    else
        i = maximum([minimum(i) 1]):minimum([maximum(i) length(x)]);
        j = maximum([minimum(j) 1]):minimum([maximum(j) length(y)]);
        b[:,:] = nc["bat"][i,j];
    end

    mask = b .< level;

    bx = X0 + rx*(i-1);
    by = Y0 + ry*(j-1);


    # # convolution
    # Fx = round(redx);
    # Fy = round(redy);

    # Fi,Fj = ndgrid(-Fx:Fx,-Fy:Fy);
    # F = exp(-2* ((Fi/redx).^2 + (Fj/redy).^2));
    # F = F/sum(F[:]);

    # # mask as float

    # maskf = Int.(mask) + 0.
    # #m = conv2(double(mask),F,"same");
    # m = conv2(maskf,F);
    Xi,Yi = ndgrid(xi,yi);

    itp = interpolate((bx,by), Int.(mask),Gridded(Linear()))
    mif = itp[xi,yi];

    mi = mif .> 1/2;
    NetCDF.close(nc);

    return  xi,yi,mi
end


function load_mask(bath_name,isglobal,x,y,levels::AbstractVector)
    data = [load_mask(bath_name,isglobal,x,y,level) for level in levels ];

    return data[1][1],data[1][2],cat(3,[d[3] for d in data]...)
end
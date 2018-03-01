import divand

bathname = joinpath(dirname(@__FILE__),"..","..","divand-example-data","Global","Bathymetry","gebco_30sec_16.nc")
bathisglobal = true

if !isfile(bathname)
    bathname = "gebco_30sec_16.nc"
    download("https://b2drop.eudat.eu/s/o0vinoQutAC7eb0/download",bathname)
end

dx = dy = 0.1
dx = dy = 0.2

lonr = 27:dx:42
latr = 40:dy:47

depthr = [0.,10,100]

mask,(pm,pn,po),(xi,yi,zi) = divand.domain(bathname,bathisglobal,lonr,latr,depthr)


@test sum(mask[:,:,1]) >= sum(mask[:,:,2]) >= sum(mask[:,:,3])

DIVAnd


# DIVAnd.jl documentation



```@docs
DIVAnd.diva3d
DIVAnd.DIVAndrun
DIVAnd.DIVAndgo
DIVAnd.DIVAnd_averaged_bg
DIVAnd.SDNMetadata
DIVAnd.save
DIVAnd.loadbigfile
DIVAnd.checkobs
DIVAnd.smoothfilter
DIVAnd.Anam.loglin
DIVAnd.Anam.logit
DIVAnd.divadoxml
DIVAnd.random
DIVAnd.distance
DIVAnd.interp
DIVAnd.backgroundfile
DIVAnd.Quadtrees.checkduplicates
```

# Bathymetry and spatial-temporal domain

```@docs
DIVAnd.load_bath
DIVAnd.extract_bath
DIVAnd.load_mask
DIVAnd.DIVAnd_metric
DIVAnd.domain
DIVAnd.DIVAnd_rectdom
DIVAnd.DIVAnd_squaredom
DIVAnd.TimeSelectorYW
DIVAnd.TimeSelectorYearListMonthList
```

# Load observations

```@docs
DIVAnd.saveobs
DIVAnd.loadobs
DIVAnd.NCSDN.load
DIVAnd.NCSDN.loadvar
DIVAnd.ODVspreadsheet.loaddata
DIVAnd.ODVspreadsheet.parsejd
DIVAnd.ODVspreadsheet.myparse
```

# Parameter optimization

```@docs
DIVAnd.fit_isotropic
DIVAnd.fit
DIVAnd.DIVAnd_cv
DIVAnd.empiriccovar
DIVAnd.fithorzlen
DIVAnd.fitvertlen
DIVAnd.lengraddepth
DIVAnd.DIVAnd_cvestimator
DIVAnd.weight_RtimesOne
DIVAnd.Rtimesx!
```

# Vocabulary


```@docs
DIVAnd.Vocab.@urn_str
DIVAnd.Vocab.CFVocab
Base.haskey(collection::DIVAnd.Vocab.CFVocab,stdname)
DIVAnd.Vocab.SDNCollection
DIVAnd.Vocab.prefLabel
DIVAnd.Vocab.altLabel
DIVAnd.Vocab.notation
DIVAnd.Vocab.definition
DIVAnd.Vocab.resolve
DIVAnd.Vocab.find(c::DIVAnd.Vocab.Concept,name,collection)
DIVAnd.Vocab.description
DIVAnd.Vocab.canonical_units
DIVAnd.Vocab.splitURL
```

# Internal API or advanced usage


## State vector

```@docs
DIVAnd.statevector
DIVAnd.pack
DIVAnd.unpack
Base.sub2ind
Base.ind2sub
Base.length
```

## Constraints

```@docs
DIVAnd_constr_fluxes
DIVAnd_constr_constcoast
```

## ODV files

```@docs
DIVAnd.ODVspreadsheet.listSDNparams
DIVAnd.ODVspreadsheet.load
DIVAnd.ODVspreadsheet.localnames
DIVAnd.ODVspreadsheet.Spreadsheet
DIVAnd.ODVspreadsheet.loadprofile
DIVAnd.ODVspreadsheet.loaddataqv
DIVAnd.ODVspreadsheet.SDNparse!
DIVAnd.ODVspreadsheet.colnumber
DIVAnd.ODVspreadsheet.nprofiles
```

## Operators

```@docs
DIVAnd.sparse_interp
DIVAnd.sparse_interp_g
DIVAnd.sparse_gradient
DIVAnd.sparse_diff
DIVAnd.matfun_trim
DIVAnd.matfun_stagger
DIVAnd.matfun_diff
DIVAnd.matfun_shift
```

## Quadtree

```@docs
DIVAnd.Quadtrees.QT
DIVAnd.Quadtrees.rsplit!
DIVAnd.Quadtrees.add!
DIVAnd.Quadtrees.within
DIVAnd.Quadtrees.bitget
DIVAnd.Quadtrees.inside
DIVAnd.Quadtrees.intersect
DIVAnd.Quadtrees.split!
```


## Conjugate gradient

```@docs
DIVAnd.conjugategradient
DIVAnd.pc_none!
DIVAnd.checksym
```

## Utility functions

```@docs
DIVAnd.DIVAnd_laplacian
DIVAnd.DIVAnd_obscovar
DIVAnd.DIVAnd_adaptedeps2
DIVAnd.DIVAnd_diagHKobs
DIVAnd.DIVAnd_residual
DIVAnd.DIVAnd_addc
DIVAnd.DIVAnd_erroratdatapoints
DIVAnd.DIVAnd_GCVKii
DIVAnd.DIVAnd_fittocpu
DIVAnd.DIVAnd_background
DIVAnd.DIVAnd_obs
DIVAnd.DIVAnd_bc_stretch
DIVAnd.DIVAnd_diagHK
DIVAnd.DIVAnd_kernel
DIVAnd.DIVAnd_residualobs
DIVAnd.DIVAnd_aexerr
DIVAnd.DIVAnd_cpme
DIVAnd.DIVAnd_cpme_go
DIVAnd.DIVAnd_datainboundingbox
DIVAnd.DIVAnd_Lpmnrange
DIVAnd.DIVAnd_pc_sqrtiB
DIVAnd.DIVAnd_pc_none
DIVAnd.DIVAnd_GCVKiiobs
DIVAnd.DIVAnd_cutter
DIVAnd.DIVAnd_qc
DIVAnd.DIVAnd_solve!
DIVAnd.DIVAnd_sampler
DIVAnd.DIVAndjog
DIVAnd.DIVAnd_background_components
DIVAnd.stats
DIVAnd.statpos
DIVAnd.blkdiag
Base.findfirst
DIVAnd.formatsize
DIVAnd.interp!
DIVAnd.ufill
DIVAnd.cgradient
DIVAnd.fzero
DIVAnd.localize_separable_grid
DIVAnd.decompB!
DIVAnd.varanalysis
DIVAnd.len_harmonize
DIVAnd.alpha_default
DIVAnd.ncfile
DIVAnd.writeslice
DIVAnd.encodeWMSStyle
DIVAnd.loadoriginators
```



# Examples

To run the example, you need to install `PyPlot`.
In the folder `examples` of DIVAnd, you can run e.g. the example `DIVAnd_simple_example_1D.jl` by issuing:

```julia
# cd("/path/to/DIVAnd/examples")
include("DIVAnd_simple_example_1D.jl")
```

Replace `/path/to/DIVAnd/` by the installation directory of DIVAnd which is the output of `Pkg.dir("DIVAnd")` if you installed `DIVAnd` using Julias package manager.


# Performance considerations


## Tuning the domain decomposition

The functions `diva3d` and `DIVAndgo` split the domain into overlapping subdomains to reduce the required amount of memory. In some circumstances (in particular few vertical levels), this can unnecessarily degrade the performance. The CPU time of the analysis can be improved by increasing the `diva3d` option `memtofit` from 3 (default) to higher values (as long as one does not run out of memory). If this parameter is set to a very high value then the domain decomposition is effectively disabled.

## Multiple CPU system

Per default julia tries to use all CPUs on your system when doing matrix operations. The number of CPUs is controlled by the call to `BLAS.set_num_threads`. Using multiple CPUs can result in overhead and it can be beneficial to reduce the number of CPUs:

```julia
BLAS.set_num_threads(2)
```

# Information for developers

To update the documentation locally, install the package `Documenter` and run the script `include("docs/make.jl")`.

```julia
Pkg.add("Documenter")
```

# API changes

We do are best to avoid changing the API, but sometimes it is unfortunately necessary.

* 2018-07-02: The module `divand` has been renamed `DIVAnd` and likewise functions containing `divand`
* 2018-06-18: The options `nmean` and `distbin` of `fithorzlen` and `fitvertlen` have been removed. The functions now choose appropriate values for these parameters automatically.



# Troubleshooting


If the installation of a package fails, it is recommended to update the local copy of the package list by issuing `Pkg.update()` to make sure that Julia knows about the latest version of these packages and then to re-try the installation of the problematic package.
Julia calls the local copy of the packge list `METADATA`.
For example to retry the installation of EzXML issue the following command:

```julia
Pkg.update()
Pkg.add("EzXML")
```



## No plotting window appears

If the following command doesn't produce any figure
```julia
using PyPlot
plot(1:10)
```
A possible solution is to modify the *backend*: this is done by editing the python configuration file
[matplotlibrc](http://matplotlib.org/users/customizing.html#the-matplotlibrc-file). The location of this file is obtained in python with:

```python
import matplotlib
matplotlib.matplotlib_fname
```

Under Linux, this returns ```'~/.config/matplotlib/matplotlibrc'```.
To use the `TkAgg` backend, add the following to the file:

```
backend      : TkAgg
```

The `matplotlibrc` need to be created if it does not exists.

## C runtime library when calling PyPlot

`R6034 an application has made an attempt to load the C runtime library incorrectly` on Windows 10 with julia 0.6.1, matplotlib 2.1.0, PyPlot 2.3.2:

```julia
ENV["MPLBACKEND"]="qt4agg"
```
You can put this line in a file `.juliarc.jl` placed in your home directory (the output of `homedir()` in Julia).

## Julia cannot connect to GitHub on Windows 7 and Windows Server 2012

Cloning METADATA or downloading a julia packages fails with:

```
GitError(Code:ECERTIFICATE, Class:OS, , user cancelled certificate checks: )
```

The problem is that Windows 7 and Windows Server 2012 uses outdated encryption protocols. The solution is to run the
"Easy fix" tool from the [Microsoft support page](https://stackoverflow.com/questions/49065986/installation-of-julia-on-windows7-64-bit)

## MbedTLS.jl does not install on Windows 7


The installion of `MbedTLS.jl` fails with the error message:

```
INFO: Building MbedTLS
Info: Downloading https://github.com/quinnj/MbedTLSBuilder/releases/download/v0.6/MbedTLS.x86_64-w64-mingw32.tar.gz to C:\Users\Jeremy\.julia\v0.6\MbedTLS
\deps\usr\downloads\MbedTLS.x86_64-w64-mingw32.tar.gz...
Exception setting "SecurityProtocol": "Cannot convert null to type "System.Net.SecurityProtocolType" due to invalid enumeration values. Specify one of th
e following enumeration values and try again. The possible enumeration values are "Ssl3, Tls"."
At line:1 char:35
+ [System.Net.ServicePointManager]:: <<<< SecurityProtocol =
    + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
    + FullyQualifiedErrorId : PropertyAssignmentException
    [...]
```

See also the issue <https://github.com/JuliaWeb/MbedTLS.jl/issues/133>.

The solution is to install the [Windows Management Framework 4.0](https://www.microsoft.com/en-us/download/details.aspx?id=40855).

## EzXML.jl cannot be installed on RedHat 6

The `zlib` library of RedHat 6, is slightly older than the library which `EzXML.jl` and `libxml2` requires.

To verify this issue, you can type in Julia

```
Libdl.dlopen(joinpath(Pkg.dir("EzXML"),"deps/usr/lib/libxml2.so"))
```

It should not return an error message. On Redhat 6.6, the following error message is returned:

```
ERROR: could not load library "/home/username/.julia/v0.6/EzXML/deps/usr/lib/libxml2.so"

/lib64/libz.so.1: version `ZLIB_1.2.3.3' not found (required by /home/divahs1/.julia/v0.6/EzXML/deps/usr/lib/libxml2.so)

Stacktrace:

 [1] dlopen(::String, ::UInt32) at ./libdl.jl:97 (repeats 2 times)
```

However, the following command should work:

```julia
 LD_LIBRARY_PATH="$HOME/.julia/v0.6/EzXML/deps/usr/lib/:$LD_LIBRARY_PATH" julia --eval  'print(Libdl.dlopen(joinpath(Pkg.dir("EzXML"),"deps/usr/lib/libxml2.so"))'
```

Lukily, EzZML.jl includes a newer version of the `zlib` library, but it does not load the library automatically.
(see also <https://github.com/JuliaLang/julia/issues/7004> and <https://github.com/JuliaIO/HDF5.jl/issues/97>)

To make Julia use this library, a user on RedHat 6 should always start Julia with:

```bash
LD_LIBRARY_PATH="$HOME/.julia/v0.6/EzXML/deps/usr/lib/:$LD_LIBRARY_PATH" julia
```

One can also create script with the following content:

```bash
#!/bin/bash
export LD_LIBRARY_PATH="$HOME/.julia/v0.6/EzXML/deps/usr/lib/:$LD_LIBRARY_PATH"
exec /path/to/bin/julia "$@"
```

by replacing `/path/to/bin/julia` to the full path of your installation directory.
The script should be marked executable and it can be included in your Linux search [`PATH` environement variable](http://www.linfo.org/path_env_var.html). Julia can then be started by calling directly this script.

## The DIVAnd test suite fails with `automatic download failed`

Running `Pkg.test("DIVAnd")` fails with the error:

```julia
automatic download failed (error: 2147500036)
```

The test suite will download some sample data. You need to have internet access and run the test function from a directory with write access.

You can change the directory to your home directory with the julia command `cd(homedir())`.

You can check the current working directory with:

```julia
pwd()
```

## METADATA cannot be updated

`Pkg.update` fails with the error message `METADATA cannot be updated`.

If you have git installed, you can issue the command:

```bash
cd ~/.julia/v0.6/METADATA
git reset --hard
```

and then in Julia run `Pkg.update()` again.

If this does not work, then, you can also delete `~/.julia` (<https://github.com/JuliaLang/julia/issues/18651#issuecomment-347579521>) and in Julia enter `Pkg.init(); Pkg.update()`.


## Convert error in `DIVAnd_obs`

The full error message:

```
MethodError: Cannot `convert` an object of type DIVAnd.DIVAnd_constrain{Float32,Diagonal{Float64},SparseMatrixCSC{Float64,Int64}} to an object of type DIVAnd.DIVAnd_constrain{Float64,TR,TH} where TH<:(AbstractArray{#s370,2} where #s370<:Number) where TR<:(AbstractArray{#s371,2} where #s371<:Number)
This may have arisen from a call to the constructor DIVAnd.DIVAnd_constrain{Float64,TR,TH} where TH<:(AbstractArray{#s370,2} where #s370<:Number) where TR<:(AbstractArray{#s371,2} where #s371<:Number)(...),
since type constructors fall back to convert methods.
```

The solution is to use the same type of all input parameters: all Float32 or all Float64.

## Monthlist issue

Using comments inside list can lead to unexpected results.

This

```julia
 monthlist = [
       [1,2,3]
       #[4,5,6]
       ]
```

should be written as

```julia
 monthlist = [
       [1,2,3]
       ]
```

## Error in the factorisation

The error message `Base.LinAlg.PosDefException(95650)`
followed by the stack-trace below might be due to a wrong choice in the analysis parameters, for example a too long correlation length.

```
Stacktrace:
 [1] #cholfact!#8(::Float64, ::Function, ::Base.SparseArrays.CHOLMOD.Factor{Float64}, ::Base.SparseArrays.CHOLMOD.Sparse{Float64}) at ./sparse/cholmod.jl:1360
 .................
 [9] DIVAndrun(::BitArray{3}, ::Tuple{Array{Float64,3},Array{Float64,3},Array{Float64,3}}, ::Tuple{Array{Float64,3},Array{Float64,3},Array{Float64,3}}, ::Tuple{Array{Float64,1},Array{Float64,1},Array{Float64,1}}, ::Array{Float64,1}, ::Tuple{Array{Float64,3},Array{Float64,3},Array{Float64,3}}, ::Float64) at /home/ctroupin/.julia/v0.6/DIVAnd/src/DIVAndrun.jl:147
```


## Installing additional packages when using a git clone

If `DIVAnd` is installed without the package manager, it can be necessary
to install additional packages. This will be explicitly shown,
for example:

```
LoadError: ArgumentError: Module Roots not found in current path.
Run `Pkg.add("Roots")` to install the Roots package.
```

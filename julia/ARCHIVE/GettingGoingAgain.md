# Getting going again, December 2024 

Worked with `julia 1.9.2` but `quarto` issues. 

- [x] Need to change to `1.11.2`.

- [x] Need to change `julia` location to `$(HOME)/.juliaup/bin/julia`.
- [x] Installed packages `IJulia`, `Revise`, `Documenter`, at top-level.
- [x] Amend production of PDFs because  `DocumenterLaTeX` is now [deprecated](https://github.com/JuliaDocs/Documenter.jl/pull/1493). Replace ``DocumenterLaTeX.LaTeX` by `Documenter.LaTeX` in `make_latex.jl` and remove `using DocumenterLaTeX`.
- [x] Added start-up script `~/.julia/config/startup.jl` to load `Revise` and to activate relevant environment on starting up `julia`.
- [x] NB [workflow tips](https://discourse.julialang.org/t/nice-workflows-for-using-and-developing-in-julia-1-9/96017)

## Package `EpidemicsCFTP`

- [x] Work through `Makefile`
  - [x] Use `] up` in `julia`: quite slow as there is a lot to do!
  - [x] `make test`
  - [x] `make doctest` 
  - [x] finally (for documents!) `make`.
- [x] Study "todo" list in `Readme.pdf`.

## Package `EpidemicsUtilities`

- [x] Work through `Makefile`
  - [x] Use `] up` in `julia`.  There is an issue with `Colors` versus `Compose` and `Gadfly`.
  - [x] `make test`
  - [x] (for documents!) `make -B`. Note this has a working example of `quarto`. 
- [x] Study "todo" list in `Readme.pdf`.

## Main code

- [x] Work through `Makefile`

  - [x] Use `] up` in `julia`. 

  - [x] `make` targets:

    - [x] `Notes-on-sampling.pdf` (no `julia` code! sets out programme for future parameter estimation. Useful to check basic `quarto` operation.)

    - [x] `production.pdf`edited as follows  (a) not to have separate YAML block for title;
      (b) there is a LaTeX error: using style file `SIR.sty` instead of inline _and_ using `xspace` package.

      ``````
      include-before-body:
          - text: |
          	\newcommand{\SIR}{\operatorname{S-I-R}\xspace
      ``````

    - [x] `introduction.pdf`

    - [x] `check.pdf`  ==though there are 3/110 significant discrepancies at 1% level!==

    - [x] `test.pdf` ==it would be good to check output with fresh eyes!==
    
    - [x] `LFEandNFZ.pdf`
    
    - [x] `CFTP.pdf`  ==it would be good to check output with fresh eyes!==
    
    - [x] `CFTP-demo.pdf` ==Now checkout the actual animations!== 
    
    - [x] `movie` (needed to ensure correct definition of `$(JULIA)` in `Makefile`!) ****
    
    - [x] `animate` Note that the animations don't always end with coalescence: ==why not!?== Amend `animate.jl`?

- [x] Study "todo" list in `Readme.pdf`.

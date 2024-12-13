# Getting going again, December 2024 

Worked with `julia 1.9.2` but `quarto` issues. Need to change to `1.11.2`.

1. Need to change `julia` location to `$(HOME)/.juliaup/bin/julia`.
2. Installed packages `IJulia`, `Revise`, `Documenter`, at top-level.
3. Amend production of PDFs because  `DocumenterLaTeX` is now [deprecated](https://github.com/JuliaDocs/Documenter.jl/pull/1493). Replace ``DocumenterLaTeX.LaTeX` by `Documenter.LaTeX` in `make_latex.jl` and remove `using DocumenterLaTeX`.
4. Added start-up script `~/.julia/config/startup.jl` to load `Revise` and to activate relevant environment on starting up `julia`.
5. NB [workflow tips](https://discourse.julialang.org/t/nice-workflows-for-using-and-developing-in-julia-1-9/96017)

## Package `EpidemicsCFTP`

- [ ] Work through `Makefile`
  - [x] Use `] up` in `julia`: quite slow as there is a lot to do!
  - [x] `make test`
  - [x] `make doctest` 
  - [x] finally (for documents!) `make`.
- [ ] Study "todo" list in `Readme.pdf`.

## Package `EpidemicsUtilities`

- [ ] Work through `Makefile`
  - [x] Use `] up` in `julia`.  There is an issue with `Colors` versus `Compose` and `Gadfly`.
  - [x] `make test`
  - [x] (for documents!) `make -B`. Note this has a working example of `quarto`. 
- [ ] Study "todo" list in `Readme.pdf`.

## Main code

- [ ] Work through `Makefile`

  - [x] Use `] up` in `julia`. 

  - [ ] `make` targets:

    - [x] `Notes-on-sampling.pdf` (no `julia` code! sets out programme for future parameter estimation. Useful to check basic `quarto` operation.)

    - [x] `production.pdf`edited as follows  (a) not to have separate YAML block for title;
      (b) there is a LaTeX error: using style file `SIR.sty` instead of inline _and_ using `xspace` package.

      ``````
      include-before-body:
          - text: |
          	\newcommand{\SIR}{\operatorname{S-I-R}\xspace
      ``````

    - [x] `introduction.pdf`

    - [x] `check.pdf` though there are 3/110 significant discrepancies at 1% level!

    - [ ] `test.pdf`
    
    - [ ] `LFEandNFZ.pdf`
    
    - [ ] `CFTP.pdf`
    
    - [ ] `CFTP-demo.pdf`
    
    - [ ] `movie`	
    
    - [ ] `animate`

- [ ] Study "todo" list in `Readme.pdf`.

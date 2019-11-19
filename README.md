# Revista Mexicana de Astronomía y Astrofísica

Source code of LaTeX macros and production scripts for the academic astronomy journal [RMxAA](http://www.astroscu.unam.mx/~rmaa/ "Homepage of the astronomy journal Revista Mexicana de Astronomía y Astrofísica") and conference series RMxAC. The journal is owned and run by the Instituto de Astronomía of the Universidad Nacional Autónoma de México (UNAM). 

This repository will mainly be of interest to those wishing to contribute to *development* of the macros and scripts.  Authors and editors who wish only to use them can download the relevant package from the [RMxAA macros website](http://www.irya.unam.mx/rmaa/). 

## Development process ##

  * The main file for the LaTeX macros and their documentation is [source/rmaa.dtx](source/rmaa.dtx), which is in DocTeX format. 
  * Running `make macros` in the `source/` directory will generate the class file `rmaa.cls`, together with auxiliary style files and scripts. These can be installed into the `packages/` folder with `make install-macros`. 
  * Running `make docs` in the `source/` directory will generate a PDF document of the annotated source code, while `make install-docs` will install it as [packages/rm-fulldocs.pdf](packages/rm-fulldocs.pdf)
  
## Preparing a new release of the packages ##

  * Running `make` in the `packages/` folder will create tarballs and zip files for distribution, but there are things that need editing by hand first. 
  
## Recent changes and plans for the future ##

  * The next release of the macros will be 4.0, which is currently in beta testing
      * This adds support for DOI and ORCID iD links. It also probably breaks compatibility with very old (last century) versions of LaTeX. 
      * [Remaining issues for version 4.0](https://github.com/will-henney/RMxAA/milestone/1)
      * Further details are [here](RMxAA-new-2019.org)
  * More far-reaching changes are planned for the future
      * Planned features on [GitHub issues](https://github.com/will-henney/RMxAA/milestone/2)


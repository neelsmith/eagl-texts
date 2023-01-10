# eagl-texts


> Explore Annotated Greek and Latin texts



## Read annotated Greek and Latin texts

The julia script `scripts/syntaxsite.jl` builds static web pages from the source data in this repository.  They are online at [https://neelsmith.github.io/eagl-texts/](https://neelsmith.github.io/eagl-texts/).



## Source data in this repository

- `texts`: citable texts in delimited-text format
- `annotations`: delimited-text files with syntactic annotations on those texts



## Reactive notebooks

This repository includes [Pluto notebooks](https://github.com/fonsp/Pluto.jl) for annotating and reading Greek and Latin texts.


### Notebooks to read syntactically annotated texts

In the `pluto/readers` directory:

- `readsentences.jl`: read texts with options to visualize syntax per sentence
- `readsubordination.jl`:  read texts with options to explore sentences by level of syntactic subordination

### Notebook to annotate citable texts

You can use `annotater/ctssyntaxer.jl`to annotate the syntax of a citable Greek text.

The notebook relies on an unpublished package (the invaluable [`PlutoGrid` package](https://github.com/lungben/PlutoGrid.jl) by Benjamin Lungwitz). For that reason, it comes with accompanying `Project.toml` and `Manifest.toml` files in the `pluto` directory.  If you start a Pluto server and open `pluto/ctssyntaxer.jl`, it should be able to build all the resources it needs (eventually: the first build especially will be slow).

Note that this limitation does not apply to notebooks for reading annoated texts. They Pluto's internal package manager, and do not need external `*.toml` files.



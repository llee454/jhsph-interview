README
======

This package contains the analysis code

Initializing the Build Environment
----------------------------------

```
cd analysis # enter the project root directory and run the following
opam switch create . 5.2.0+options --no-install
eval $(opam env)
opam update
opam upgrade
dune build interview.opam # to generate OPAM package file
opam install --deps-only . -y
dune build
dune runtest
```

Execution
---------

Use the following command fo execute the main script which outputs the results of the analysis:

```
dune exec src/main.exe
```
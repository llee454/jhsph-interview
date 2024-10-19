(lang dune 3.16)
(name interview)
(license GPL-3.0)
(authors "Larry D. Lee Jr. <llee454@gmail.com>")
(maintainers "Larry D. Lee Jr. <llee454@gmail.com>")
(source (github llee454/jhsph-interview))
(version 0.0.1)
(generate_opam_files)
(package
 (name interview)
 (synopsis "interview test responses.")
 (description "responses to an interview test.")
 (depends
  core
  dune
  ocaml-lsp-server
  ocamlformat
  ppx_jane
  eio_main
  vscoq-language-server
 )
)

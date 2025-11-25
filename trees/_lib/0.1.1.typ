// #import "@preview/ctheorems:1.1.3": *
// #import "@preview/lovelace:0.3.0": *
#import "@preview/scribe:0.2.0": *
#import "kodama.typ"



#let _to-string(it) = {
  if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(_to-string).join()
  } else if it.has("body") {
    _to-string(it.body)
  } else if it == [ ] {
    " "
  }
}


#let tree-level = state("tree-level", 1)
#let taxon-value = state("taxon-value", "")

#let embed(slug, text) = context if target() == "html" {
  kodama.embed(slug, text, numbering: true, open: true)
} else {
  context tree-level.update(x => x +1)
  taxon-value.update("")
  include "/" + slug + ".typst"
  context tree-level.update(x => x -1)
}

#let local(slug, text) = context if target() == "html" {
  kodama.local(slug, text)
} else {
  underline(text)
}

#let title(it) = context if target() == "html" {
  kodama.meta("title", it)
} else {
  let full = taxon-value.get() + it
  context heading(level: tree-level.get(), full)
}

#let taxon(it) = context if target() == "html" {
  kodama.meta("taxon", it)
} else {
  context taxon-value.update(it + ": ")
}

#let proof(it) = [
  *Proof*.
  #it
]

// Number Theory
#let legendre(a,b) = $(#a/#b)$
#let jacobi(a,b) = legendre(a,b)
#let gcd(..args) = ($"gcd"(#args.pos().join(","))$)

#let template(doc) = {
  set heading(numbering: "1.")
  set par(justify: true)

  show: scribe
  // show: thmrules
  //

  context if target() == "html" {
    show: kodama.template
    show math.equation.where(block: false): it => {
      html.elem("span", attrs: (role: "math"), html.frame(it))
    }
    show math.equation.where(block: true): it => {
      html.elem("figure", attrs: (role: "math"), html.frame(it))
    }
    doc
  } else {
    doc
  }
}

#import "@preview/scribe:0.2.0": *
#import "kodama.typ"

#let tree-level = state("tree-level", 1)
#let taxon-value = state("taxon-value", "")
#let skip-title = state("skip-title", false)

#let title(it) = context if target() == "html" {
  kodama.meta("title", it)
} else if skip-title.get() == false {
  heading(depth: tree-level.get(), taxon-value.get() + it)
} else {
  skip-title.update(x => false)
}

#let embed(slug, text) = context if target() == "html" {
  kodama.embed(slug, text, numbering: true, open: true)
} else {
  context tree-level.update(x => x +1)
  taxon-value.update("")
  if text == [] {
    include "/" + slug + ".typst"
  } else {
    // If the a title is given, override the one from the included tree
    title(text)
    context skip-title.update(x => true)
    include "/" + slug + ".typst"
    context skip-title.update(x => false)
  }
  context tree-level.update(x => x -1)
}

#let local(slug, text) = context if target() == "html" {
  kodama.local(slug, text)
} else {
  underline(text)
}


#let taxon(it) = context if target() == "html" {
  kodama.meta("taxon", it)
} else {
  context taxon-value.update(it + ": ")
}

#let proof(it) = context if text.lang == "de" [
  *Beweis*. #it
] else [
  *Proof*. #it
]

// Number Theory
#let legendre(a,b) = $(#a/#b)$
#let jacobi(a,b) = legendre(a,b)
#let gcd(..args) = ($"gcd"(#args.pos().join(","))$)

#let template(doc) = {
  show: scribe

  context if target() == "html" {
    show: kodama.template
    show math.equation.where(block: false): it => {
      html.elem("span", attrs: (role: "math"), html.frame(it))
    }
    show math.equation.where(block: true): it => {
      html.elem("figure", attrs: (role: "math"), html.frame(it))
    }
    doc
  } else if tree-level.get() == 1 {
    // dont override these in nested trees
    set heading(numbering: "1.")
    set par(justify: true)
    doc
  } else {
    doc
  }
}

#import "@preview/ctheorems:1.1.3": *
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

#let embed(slug, text) = context if target() == "html" {
  kodama.embed(slug, text, numbering: true, open: true)
} else {
  include "/" + slug + ".typst"
}

#let local(slug, text) = context if target() == "html" {
  kodama.local(slug, text)
} else {
  underline(text)
}

#let title(it) = context if target() == "html" {
  kodama.meta("title", it)
} else {
  heading(it)
}

#let taxon(it) = context if target() == "html" {
  kodama.meta("taxon", it)
} else {
  it
}

// Not working with html...
// #let proof = thmproof("proof", "Proof")
#let proof(it) = [ *#emph("Proof")*. #it #set align(right); $qed$ ]

// Number Theory
#let legendre(a,b) = $(#a/#b)$
#let jacobi(a,b) = legendre(a,b)
#let gcd(..args) = ($"gcd"(#args.pos().join(","))$)

#let template(doc) = {
  show: scribe
  // show: thmrules

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

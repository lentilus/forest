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
  [![#text](#slug)]
}

#let local(slug, text) = context if target() == "html" {
  kodama.local(slug, text) 
} else {
  [[#text](#slug)]
}

#let meta_heading(it) = {
  let args = _to-string(it).split("=").rev()
  let taxon = args.pop()
  let title = args.pop()
  context if target() == "html" {
    set text(size: 1em * 1/1.4, weight: "regular")
    kodama.meta("taxon", taxon)
    kodama.meta("title", title)
  } else {
    [ #taxon: #title]
  }
}

#let template(doc) = {
  show heading.where(level: 1): meta_heading
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
  } else {
    doc
  }
}

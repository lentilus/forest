#import "@preview/scribe:0.2.0": *
#import "@preview/fletcher:0.5.8": diagram, edge
#import "kodama.typ"

#let next-frame-id = state("next-frame-id", 1)
#let frames = state("frames", ((level: 0, taxon: none, title: none, id: 0),))
#let titles = state("titles", (:))
#let taxons = state("taxons", (:))

#let is-html() = target() == "html"

#let resolve-path(slug) = {
  assert(type(slug) == str, message: "embed: slug must be a string")
  assert(slug.len() > 0, message: "embed: slug must not be empty")
  let with-ext = if slug.ends-with(".typst") { slug } else { slug + ".typst" }
  if with-ext.starts-with("/") { with-ext } else { "/" + with-ext }
}

#let print-slug(slug) = context {
  place(left, dx: -30pt, dy: 0pt, raw(slug))
}

#let title(it) = context {
  let f = frames.get().last()
  let id = repr(f.id)
  if is-html() {
    kodama.meta("title", it)
  } else {
    titles.update(m => m + ((id): it))
  }
}

#let taxon(it) = context {
  let f = frames.get().last()
  let id = repr(f.id)
  if is-html() {
    kodama.meta("taxon", it)
  } else {
    taxons.update(m => m + ((id): it))
  }
}

#let embed(slug, text, numbering: true, open: true) = context {
  if is-html() {
    kodama.embed(slug, text, numbering: numbering, open: open)
  } else if open {
    let my-id = next-frame-id.get()
    next-frame-id.update(x => x + 1)
    let parent = frames.get().last()
    let initial-title = if text != [] { text } else { none }
    let initial-taxon = if text != [] { text } else { none }
    frames.update(s => s + ((
      level: parent.level + 1,
      taxon: initial-taxon,
      title: initial-title,
      id: my-id,
    ),))
    if initial-title != none {
      titles.update(m => m + ((repr(my-id),): initial-title))
    }
    if initial-taxon != none {
      taxons.update(m => m + ((repr(my-id),): initial-taxon))
    }
    print-slug(slug)
    include resolve-path(slug)
    frames.update(s => s.slice(0, -1))
  }
}

#let local(slug, text) = context {
  if is-html() { kodama.local(slug, text) } else { underline(text) }
}
#let external(dest, content) = link(dest, underline(content))
#let proof(it) = context {
  if text.lang == "de" { [*Beweis*. #it] } else { [*Proof*. #it] }
}
#let legendre(a, b) = $(#a/#b)$
#let jacobi(a, b) = legendre(a, b)
#let gcd(..args) = ($"gcd"(#args.pos().join(","))$)

#let template(doc) = {
  set heading(numbering: "1.")
  set par(justify: true)
  show heading.where(level: 1): set align(center)

  show: scribe
  show math.equation.where(block: false): it => {
    if is-html() { html.elem("span",   attrs: (role: "math"), html.frame(it)) } else { it }
  }
  show math.equation.where(block: true): it => {
    if is-html() { html.elem("figure", attrs: (role: "math"), html.frame(it)) } else { it }
  }
  show figure: it => {
    if is-html() { html.elem("figure", attrs: (class: "typst"), html.frame(it)) } else { it }
  }

  context {
    let html = is-html()
    let f = frames.get().last()
    let my-id = repr(f.id)
    let my-lvl = f.level
    let fin = titles.final()
    let my-title = titles.final().at(my-id, default: none)
    let my-taxon = taxons.final().at(my-id, default: none)
    let sep = if (my-taxon != none) and (my-title != none) {" : "} else {""}
    if not html {
      if my-lvl == 0 {
        heading(my-title, numbering: none,)
      } else if my-taxon == [Index] {
        heading(depth: my-lvl, my-title)
      } else if my-lvl != 0 {
        [*#my-taxon* *#my-title*]
      }
    }
  }

  doc
}

# slugger.online

The official website of **[slugger](https://github.com/Reefact/slugger)** — a .NET CLI and
library that draw readable `adjective-noun` names from JSON themes their user writes, and
that refuse a vocabulary which does not hold up.

> **Status: specification only.** Nothing is built yet. What this repository carries is the
> reference the site will be built from.

## The specification

[`docs/design/specification.md`](docs/design/specification.md) — what is decided, and why.
It is in French, by decision; everything else here is in English, and so is the site itself.

It describes the product vision, the audiences, the editorial principles, the information
architecture, the narrative, the playground, the comparative positioning, the technical
architecture, and what verifies each rule. It deliberately carries no state, no schedule and
no fact it is not the source of — §1.2 says why, and §2 says where those facts live instead.

Two sections are worth reading first, because they decide more than the others:

* **§3, product vision** — what slugger is not (it does not *slugify*), the promise, the six
  things a visitor has to understand, and the third argument: the library documents how to
  validate the one thing loading cannot check.
* **§10, the playground** — it runs the real engine in the browser, and serves two audiences:
  anyone drawing a name, and theme authors testing a theme of their own without installing
  anything. §10.4 names what that second use requires of the library.

## Licence

[Apache 2.0](LICENSE).

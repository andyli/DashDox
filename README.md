# DashDox

[Haxe](http://haxe.org/) API docset for [Dash](http://kapeli.com/dash).

## Install to Dash

  1. Go to Dash's *Preferences*.
  2. Switch to *Downloads* tab.
  3. Select *User Contributed*
  4. Find the *Haxe* row and press the *Download* button.

## Generate the docset

  1. Install [Haxe](http://haxe.org/).
  2. Build the haxe documentation by following the instruction of [Dox](https://github.com/dpeek/dox).
  3. Clone this repo: `git clone https://github.com/andyli/DashDox.git`.
  4. Install the dependency: `haxelib install build.hxml`.
  5. Build the generation program: `haxe build.hxml`
  6. Run it: `neko Main.n -name Haxe -html-doc path/to/dox/bin/pages -xml-doc path/to/dox/bin/xml -icon haxe.png -out . -clean`

# DashDox
[![Build Status](https://travis-ci.org/andyli/DashDox.svg?branch=master)](https://travis-ci.org/andyli/DashDox)

[Haxe](https://haxe.org/) API docset for [Dash](https://kapeli.com/dash) / [Zeal](https://zealdocs.org/).

## Install to Dash

  1. Go to Dash's *Preferences*.
  2. Switch to the *Downloads* tab.
  3. Select *User Contributed*.
  4. Find the *Haxe* row and press the *Download* button.

## Install to Zeal

  1. *Tools* -> *Docsets*.
  2. Click the *Add feed* button.
  3. Enter this feed URL: https://andyli.github.io/DashDox/haxe.xml
  4. Close. (It may tell you to wait, if so, wait a moment then click the close button again.)

## Generate the docset

  1. Install [Haxe](https://haxe.org/).
  2. Build the haxe documentation by following the instruction of [Dox](https://github.com/HaxeFoundation/dox).
  3. Clone this repo: `git clone https://github.com/andyli/DashDox.git`.
  4. Install the dependency: `haxelib install build.hxml`.
  5. Build the generation program: `haxe build.hxml`
  6. Run it: `neko Main.n -name Haxe -html-doc path/to/dox/bin/pages -xml-doc path/to/dox/bin/xml -icon haxe.png -out . -clean`

<p xmlns:dct="http://purl.org/dc/terms/" xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#">
  <a rel="license"
     href="https://creativecommons.org/publicdomain/zero/1.0/">
    <img src="https://licensebuttons.net/p/zero/1.0/80x15.png" style="border-style: none;" alt="CC0" />
  </a>
  To the extent possible under law,
  <span resource="[_:publisher]" rel="dct:publisher">
    <span property="dct:title">Andy Li</span></span>
  has waived all copyright and related or neighboring rights to
  <span property="dct:title">Haxe API docset generator</span>.
This work is published from:
<span property="vcard:Country" datatype="dct:ISO3166"
      content="HK" about="[_:publisher]">
  Hong Kong</span>.
</p>

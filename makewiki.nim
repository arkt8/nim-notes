import std/os
import std/strutils
import std/strscans
import std/strformat

const ext = @["md","nim"]

type
  Manual = object
    srcdir : string
    outdir : string
    content: seq[ManualSection]

  ManualSection = object
    descfile : string
    docs : seq[Doc]

  Doc = object
    file: tuple[ dir,name,ext,path:string ]
    title: string
    blocks: seq[DocBlock]

  DocBlock = tuple
    region: DocRegion
    linelist: seq[string]

  DocRegion {.pure.} = enum
    tstart, tbody, # text parts
    cstart, cbody, # code parts
    raw

  NimSyn {.pure.} = enum
    tstart = "##["
    tend="]##"



proc help(): void =
  echo "Usage:"
  echo paramStr(0) & " srcdir tgtdir "
  quit()


template slugify(s:string) : string =
  s.replace("_","-").replace(".","-")



proc processMarkdown(doc: var Doc) : bool =
  result = true
  doc.blocks.add((region: DocRegion.raw, linelist: @[]))


proc processNim(doc: var Doc): bool =

  result = true
  var blank : seq[string]
  var region : DocRegion
  var bnum = -1

  for l in lines( doc.file.path ) :

    # Limit detection
    if l.startsWith($NimSyn.tstart) and l.endsWith($NimSyn.tstart) :
      region = DocRegion.tstart

    elif l.endsWith($NimSyn.tend) :
      region = DocRegion.cstart

    # Blank lines
    elif l.isEmptyOrWhitespace :
      blank.add ""

    # First line entering a text region
    elif region == DocRegion.tstart :
      blank = @[]
      region = DocRegion.tbody
      bnum.inc()
      doc.blocks.add((region: region, linelist: @[l]))

    # First line entering a code region
    elif region == DocRegion.cstart :
      blank = @[]
      region = DocRegion.cbody
      bnum.inc()
      doc.blocks.add((region: region, linelist: @[l]))

    # Each line inside a code or text region
    elif region == DocRegion.tbody or region == DocRegion.cbody:
      for i in blank :
        doc.blocks[bnum].linelist.add i
      blank = @[]
      doc.blocks[bnum].linelist.add l


proc getTitle(lines:seq[string], title: var string) : void =
  var c = 0
  var l = lines.len

  while c < l :
    if lines[c].scanf("# $*$.", title) :
      break
    elif c < l-1 :
      let nl = lines[c+1]
      if nl.scanf("====$*$.",title) or nl.scanf("----$*$.",title) :
        title = lines[c]
        break
    c.inc


proc saveMarkdown(doc: var Doc, outdir: string) : void =
  var title : string
  let outpath = outdir & os.DirSep & doc.file.dir
  let outfile = outpath & os.DirSep & doc.file.name.slugify & ".md"
  outpath.createDir
  let file = open(outfile, fmWrite)
  for blk in doc.blocks :
    case blk.region :
      of DocRegion.raw :
        var rawlines : seq[string]
        for l in doc.file.path.lines : rawlines.add(l)
        if title == "" : getTitle(rawlines,title)
        file.writeline rawlines.join("\n")
      of DocRegion.tbody :
        file.writeLine( blk.linelist.join("\n") )
        if title == "" : getTitle(blk.linelist, title)
      of DocRegion.cbody :
        file.writeLine "```"&doc.file.ext
        file.writeLine blk.linelist.join("\n")
        file.writeLine "```"
      else : continue
    file.writeLine("")
  doc.title = if isEmptyOrWhitespace title : doc.file.name else: title
  doc.file.path = outfile

  doc.blocks = @[]


proc attachFile(manual: var Manual, file: string, pos: int) : void =
  var fpath, fname, fext : string

  if file.scanf("$*/$w.$w$.",fpath,fname,fext) and fext in ext :
    if fname == "intro" and fext == "md" :
      manual.content[pos].descfile = file
    else :
      var doc = Doc(file:(fpath,fname,fext,file))
      var ok = case fext :
        of "md"  : doc.processMarkdown
        of "nim" : doc.processNim
        else     : false
      if ok :
        doc.saveMarkdown(manual.outdir)
        manual.content[pos].docs.add doc


proc attachDir(manual: var Manual, dir:string) : void =
  manual.content.add( ManualSection() )
  var sManual = manual.content.len - 1 # Keep things sorted...
  for item in walkDir(dir) :
    case item.kind :
      of pcDir : manual.attachDir item.path
      of pcFile : manual.attachFile(item.path, sManual)
      else : discard


proc save(manual: var Manual) : void =
  let homefile = manual.outdir & os.DirSep & "Home.md"

  manual.outdir.createDir
  let home = open(homefile, fmWrite)
  for section in manual.content :
    echo $section
    if not section.descfile.isEmptyOrWhitespace :
      home.writeline( readFile(section.descfile) )
    for doc in section.docs :
      echo $doc.file, " ", $homefile
      home.writeLine( fmt("[{doc.title}]({doc.file.dir}/{doc.file.name})" ) )
    home.writeLine("")
  home.writeLine("")


proc build(idx: var Manual) : void =
  setCurrentDir idx.srcdir
  idx.attachDir(".")
  idx.save


block main:

  if paramCount() < 2 : help()
  var manual = Manual( srcdir: absolutePath ( paramStr 1 ),
                   outdir: absolutePath ( paramStr 2 ) )

  if not dirExists manual.srcdir : help()
  if not dirExists manual.outdir : createDir manual.outdir

  manual.build


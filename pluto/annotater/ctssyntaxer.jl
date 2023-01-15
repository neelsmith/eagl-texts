### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 548d7257-7eb2-4d7e-a2aa-aa0dc5b4ddb6
# ╠═╡ show_logs = false
begin
	using Pkg
	Pkg.activate(pwd())
	Pkg.update()
	Pkg.instantiate()

	Pkg.add("GreekSyntax")
	using GreekSyntax
	
	Pkg.add("LatinSyntax")
	using LatinSyntax

	Pkg.add("PlutoUI")
	using PlutoUI
	import PlutoUI: combine
	
	Pkg.add("Kroki")
	using Kroki

	Pkg.add("CitableBase")
	using CitableBase
	Pkg.add("CitableText")
	using CitableText
	Pkg.add("CitableCorpus")
	using CitableCorpus

	Pkg.add("Orthography")
	using Orthography

	Pkg.add("PolytonicGreek")
	using PolytonicGreek

	Pkg.add("LatinOrthography")
	using LatinOrthography
	
	Pkg.add("PlutoTeachingTools")
	using PlutoTeachingTools

	Pkg.add("HypertextLiteral")
	using HypertextLiteral
	
	Pkg.add("DataFrames")
	using DataFrames
	Pkg.add("UUIDs")
	using UUIDs

	Pkg.add(url = "https://github.com/lungben/PlutoGrid.jl")
	using PlutoGrid

	Pkg.status()
	
	md"""(*Unhide this cell to see environment setup.*)"""
end

# ╔═╡ eae1988e-b0b0-4fb0-bd52-c1156e67149e
TableOfContents() 

# ╔═╡ 0025d7bb-fc66-4f98-9def-4adfe0aeaf3a
nbversion = "0.8.1";

# ╔═╡ 94bcdb73-7994-49ab-b9dd-449768dc2ebf
md"""(*Notebook version **$(nbversion)**.*) *See version history* $(@bind history CheckBox(false))"""

# ╔═╡ e98cdbde-4b9b-4439-8ae2-dfed3d4879f4
if history
md"""
- **0.8.1**: Incorporates orthography to construct annotations correctly.
- **0.8.0**: Validate user input
- **0.7.1**: Redefine default data directory for new host site on aegl-texts.
- **0.7.0**: Works with either Greek or Latin texts.
- **0.6.0**: Allow loading source data from file or URL.
- **0.5.1**: Fixes a bug in serializing verbal expressions.
- **0.5.0**: Uses new `GreekSyntax` package to simplify notebook. Fixes syntax error in default color palette.
- **0.4.1**: fixes a boundary-checking error in using multiple connectors.
- **0.4.0**: reorganizes tips and instructions using `aside` from `PlutoTeachingTools`; allows selection of a *range* of connecting words; corrects bug in display of indented syntactic units.
- **0.3.0**: changes user interface for defining verbal units and grouping tokens by verbal unit.  Saving files uses a rational clickable button (the underdocumented `CounterButton` in PlutoUI).
- **0.2.0**: reorganizes notebook in preparation for publication of `GreekSyntax` package on juliahub, and changes to writing all delimited-text serialization of annotations to a single file.
- **0.1.1**: bug fixes, including important correction to sentence + group ID in export of token annotations.
- **0.1.0** initial version:  load a citable corpus from CEX source, validate its orthography and parse into sentence units citable by CTS URN, save annotation results to delimited-text files.
"""
	
else
		md""
	
	
end

# ╔═╡ cf7e2ea6-93dc-11ed-3673-af3c467b0f9e
md"""


## Annotate the syntax of a citable Greek or Latin text

> *Annotate the syntax of a citable Greek or Latin text, and save your annotations to simple delimited text files.*


"""

# ╔═╡ 6be1c3da-a7ae-4496-96b7-fc3a41a2418e
md"""### Prerequisites: configuring your notebook"""

# ╔═╡ f792e968-b88e-4565-b594-1794fad9991c
md"""*Please provide a title for your collection of annotations.*

*Title*: $(@bind title confirm(TextField(80; placeholder = "Title for text")))
"""

# ╔═╡ 04a90145-0437-4c34-bec3-91f109f1bc1a
begin
	defaultdir = joinpath(dirname(dirname(pwd())), "scratchpad")
	md"""*Directory where results will be saved*: $(@bind outputdir confirm(TextField(80, default = defaultdir)))"""
# *Title*: $(@bind title TextField(80; placeholder = "Title for text"))
end

# ╔═╡ 61e0062a-f2c1-48ec-b5ce-533607f3a476
md"""*Load citable text from* $(@bind srctype Select(["", "url", "file"]))"""

# ╔═╡ b679f220-5969-4e8d-87ed-9fa06f9c7e35
if srctype == "url"
	md"""
*Paste or type in a URL for the CEX source file to annotate.*	
	*Source URL*: $(@bind srcurl confirm(TextField(80; default = 
	"https://raw.githubusercontent.com/neelsmith/GreekAndLatinSyntax/main/data/texts/lysias1.cex")))
	"""



elseif srctype == "file"
	
	defaultsrcdir = joinpath(dirname(dirname(pwd())), "texts")
	md"""*Source directory*: $(@bind basedir confirm(TextField(80; default = defaultsrcdir)))"""
end

# ╔═╡ df550cd1-657b-4401-abbb-72ba7f93ad38
if srctype == "file"
	
	cexfiles = filter(readdir(basedir)) do fname
		endswith(fname, ".cex")
	end
	datasets = [""]
	for f in cexfiles
		push!(datasets,f)
	end
	md"""*Choose a file* $(@bind datafile Select(datasets))"""
end

# ╔═╡ 6ef835a0-2056-4dd8-a302-8017296d2ce9
begin
	orthomenu = ["litgreek" => "Greek: literary orthography", "latin23" => "Latin: 23-character alphabet","latin24" => "Latin: 24-character alphabet", "latin25" => "Latin: 25-character alphabet"]
	
md"""
*Language and orthography of your corpus*: $(@bind ortho Select(orthomenu))
"""
end

# ╔═╡ 95fb9dbf-4a52-44e0-b76d-140846bfb8ce
md"""*Title, output directory, source are all correct* $(@bind prereqsok CheckBox())"""

# ╔═╡ e931ff8d-299e-419e-b991-4a9caa94734e
html"""
<br/><br/>
<br/>"""

# ╔═╡ defb3d5b-07d6-4a9e-bfb8-f3b417265973
html"""
<br/><br/>
<br/>"""

# ╔═╡ 863f3c5f-f10f-4755-a74a-e011eefc6e14
md""" ## Customizing  the notebook's visual appearance


To learn how to customize the display of texts, check this option: $(@bind seecss CheckBox())
"""

# ╔═╡ 7126004e-586a-426f-bd91-3b02196900bb
md"""*Use default CSS* $(@bind defaultcss CheckBox(true))"""

# ╔═╡ ababc89a-b183-4cc6-afe1-61bc1d690b6c
css = if defaultcss
 	cssbody = GreekSyntax.defaultcss()
	 HTML("<style>$(cssbody)</style>")
	 
 else
	 
 html"""
<style>
 div.passage {
 	padding-top: 2em;
 	padding-bottom: 2em;
 
 }
  blockquote.subordination {
 	padding: 0em;
 
 }
  .connector {
 background: yellow;  
 font-style: bold;
}

.subject {
 	text-decoration: underline;
 	text-decoration-thickness: 3px;
}
.object {
 	text-decoration: underline;
 	text-decoration-style: wavy;
 }
 .verb {
 	border: thin solid black;
 	padding: 1px 3px;
 	
 }

 .unassigned {
 color: silver;
 }
 

span.tooltip{
  position: relative;
  display: inline;
}
span.tooltip:hover:after{ visibility: visible; opacity: 0.8; bottom: 20px; }
span.tooltip:hover:before{ visibility: visible; opacity: 0.8; bottom: 14px; }

span.tooltip:after{
  display: block;
  visibility: hidden;
  position: absolute;
  bottom: 0;
  left: 50%;
  opacity: 0.9;
  content: attr(tool-tips);
  height: auto;
  width: auto;
  min-width: 100px;
  padding: 5px 8px;
  z-index: 999;
  color: #fff;
  text-decoration: none;
  text-align: center;
  background: rgba(0,0,0,0.85);
  -webkit-border-radius: 5px;
  -moz-border-radius: 5px;
  border-radius: 5px;
}
span.tooltip:before {
  position: absolute;
  visibility: hidden;
  width: 0;
  height: 0;
  left: 50%;
  bottom: 0px;
  opacity: 0;
  content: "";
  border-style: solid;
  border-width: 6px 6px 0 6px;
  border-color: rgba(0,0,0,0.85) transparent transparent transparent;
}
 """
 end

# ╔═╡ 6892ed5c-cc3b-418a-9f1d-95ea985ae445
md"""*Use default color palette* $(@bind defaultcolors CheckBox(true))"""

# ╔═╡ da77076f-121e-40c6-aeae-05f2728ad918
palette = if defaultcolors
	
	GreekSyntax.defaultpalette
	
else
	["#79A6A3;",
	"#E5B36A;",
	"#C7D7CA;",
	"#E7926C;",
	"#D29DC0;",
	"#C2D6C4;",
	"#D291BC;",
	"E7DCCA;",
	"#FEC8D8;",
	"#F5CF89;",
	"#F394AF;"
]
end

# ╔═╡ 70e6314b-12ee-491c-95ca-85a464b2ed41
html"""
<br/><br/><br/><br/><br/><br/><br/><br/><br/>
<hr/>
"""

# ╔═╡ 6084a7fb-9f6d-4c1c-b0f8-b36ff1bd12a8
md"""> ## Documentation
> 
> ### How the notebook works
>
> Users should not need to look at any of the following cells in order to annotate the syntax of a citable text, but if you want to understand more about how the notebook works, the following cells include brief documentary text introducing the main computations in the notebook.
>
> Unfold the section *Why is this notebook so complicated?* for a broader discussion
> about the issues in using Pluto as an environment for editing data.
>
"""

# ╔═╡ d0880c49-23d8-4180-ad66-993ba8640555
md"""> ### Functions to validate prerequisites
>
> We check all user settings before exposing the rest of the notebook.

"""

# ╔═╡ 61e97fa8-ca3c-41f1-98e9-8b3ec0d6a811
"""True if title prerequisite is set."""
function titleok()
	@isdefined(title) && ! isempty(title)
end

# ╔═╡ 487a4a7a-12dd-4ee6-91ae-8e19b039fe06
"""True if srcurl prerequisite is set."""
function srcurlok()
	@isdefined(srcurl) && ! isempty(srcurl)
end

# ╔═╡ b387de43-504a-4e10-a157-ca2874a0f648
"""True if selected data file exists."""
function datafileok()
	@isdefined(datafile) && isfile(joinpath(basedir, datafile)) 
end

# ╔═╡ 3eda4f2c-5145-4472-9d4e-3aaeaff0f732
"""True if all prerequisites are defined"""
function prereqs()
	prereqsok && titleok() && isdir(outputdir) && ( srcurlok()  || datafileok())
end

# ╔═╡ 5d123a0b-b1c1-41a9-9c2f-d04bf635528b
if prereqs()
	md"""### Step 1. Annotate the connection of the sentence to its context."""
end

# ╔═╡ 34204b6e-032f-4a16-a27c-1adbdd4552ff
md"""> ### Global variables derived from *choice of data set*
>
> - `corpus`: a citable text corpus loaded from the user-supplied URL.
> - `orthotokens`: tokenization of `corpus` using literary Greek orthography
> - `tokencorpus`: derived from `corpus`, and citable at the token level
> - `badortho`: list of all orthographically invalid tokens.  Theyse are found with the `findinvalid` function.
> - `sentencesequence`: a sequence of tuples, each containing a sequence number, and a URN identifying the sentence as a range at the token level
>
> We use the `orthography` and `findinvalid` functions in creating these variables

"""

# ╔═╡ d7c3b7e9-6089-4670-a94b-24bd0fc55af5
corpus = if prereqs()
	if srctype == "url"
		fromcex(srcurl, CitableTextCorpus, UrlReader)
		
	elseif srctype == "file" && datafileok()
		fromcex(joinpath(basedir, datafile), CitableTextCorpus, FileReader)
	end
	
else
	nothing
end

# ╔═╡ be549c7d-84dc-4c54-9369-6c24981b61e2
"""True if corpus loaded successfully."""
function loadedok()
	! isnothing(corpus)
end

# ╔═╡ 96156fef-fd1a-4ca1-83aa-c9f836f5f644
"""Instantiate `OrthographicSystem` for user's menu choice.
"""
function orthography()
	if ortho == "litgreek"
		literaryGreek()
	elseif ortho == "latin23"
		latin23()
	else
		nothing
	end
end

# ╔═╡ 2492514f-6237-4ddd-829f-ed89a1754b5e
orthotokens = if loadedok()
	tokenize(corpus, orthography());
end

# ╔═╡ cced3ab8-d31c-4911-bda6-d393999e80ef
tokencorpus = isnothing(orthotokens) ? nothing : map(orthotokens) do t
	t[1]
end |> CitableTextCorpus

# ╔═╡ 9742760a-d15c-4a85-b115-bc02d781a438
sentencesequence = isnothing(corpus) ? nothing : parsesentences(corpus, orthography())

# ╔═╡ 01197fc5-c76a-406a-afd0-59fff59d0e56
if prereqs()
	md"""

*Choose a sentence to analyze (maximum $(length(sentencesequence)))*: $(@bind sentid NumberField(0:length(sentencesequence)))"""
end

# ╔═╡ 1db9ed09-5717-4a14-8b3e-d4e943300bf9
"""Compile list of all tokens that are orthographically
invalid in literary Greek orthography.
"""
function findinvalid(c)
	bad = []
	tokens = tokenize(c, orthography());
	for (t,ttype) in tokens
		if ttype isa Orthography.UnanalyzedToken
			push!(bad, t)
		end
	end
	bad
end

# ╔═╡ 52225c55-ad48-4e1a-a521-fe4dc802e5c1
badortho = if loadedok()
	findinvalid(corpus)
end

# ╔═╡ 0da2c2a5-0403-43e7-aac3-6c294c59b095
if prereqs()
	if ! isempty(badortho)
	warning_box(md"""Your text has **$(length(badortho))** orthographically invalid tokens.  This can affect the accuracy of tokenizing and parsing into sentence units.

You can unfold the list below to see a list of invalid tokens.  Consider whether you should correct your source text before annotating it.
""")
end
end

# ╔═╡ 63211b87-628a-47a2-9507-8d7351ec4fbb
if prereqs()
	reportlines = ["**Results**: for *$(title)*, loaded a corpus with  **$(length(corpus))** citable passages, and parsed **$(length(orthotokens))** tokens into **$(length(sentencesequence))** sentences."
]
	
	
	if isempty(badortho)
		push!(reportlines, "All tokens are orthographically valid.")	
	elseif length(badortho) == 1
		push!(reportlines, "**1** token is orthographically invalid.")	
	else
		push!(reportlines, "**$(length(badortho))** tokens are orthographically invalid.")	
	end
	
	Markdown.parse(join(reportlines,"\n"))
end


# ╔═╡ fdbd9313-7b75-4411-a2bd-0677941fc070
if prereqs() && ! isempty(badortho)
	ortholines = ["Orthographically invalid tokens:", ""]
	for cp in badortho
		push!(ortholines, string("- ", passagecomponent(cp.urn), ": ", cp.text))
 	end
	orthostr =  join(ortholines, "\n")
	orthomsg = Markdown.parse(orthostr)


	Foldable("See invalid tokens", orthomsg)

end

# ╔═╡ f9eb7ac5-0049-455a-b55b-33fdb5515dd7
md"""> ### Global variables derived from the user's *sentence selection*
>
> - `sentence`: the current selection from the `sentencesequence` list
> - `sentenceannotation`. A `SentenceAnnotation` (from the `GreekSyntax` package) for the current sentence. We use the function `connectorurn` in constructing this.
> - `sentencetokens`:  citable tokens for the current sentence. 
> - `sentenceorthotokens`: tokens for the current sentence including classificaiton by token type, as produced by tokenizing with the `Orthography` interface.
 

"""

# ╔═╡ ab8b3a18-7e91-41d5-b649-a98da35bfe48
# The currently selected sentence
# Check on existing of sentid!
sentence = if @isdefined(sentid)
	sentid == 0 ? nothing : sentencesequence[sentid]
else
	nothing
end

# ╔═╡ c4301d12-c62b-4161-8847-555d78ca346d
sentencetokens = isnothing(sentence) ? nothing : CitableCorpus.select(sentence.urn, tokencorpus)

# ╔═╡ 73c516de-52af-412d-805a-fd04910a23c7
if prereqs()
	if sentid == 0
		md""
	else 
		md"""*Choose connecting words from this many initial tokens:* $(@bind ninitial Slider(1:length(sentencetokens), show_value = true, default = 5) )
	"""
	
	end
end

# ╔═╡ 14586c88-3e6f-42da-85cb-9470c03e92e1
sentenceorthotokens = begin
	if isnothing(sentence)
		nothing
	else
		rangeindexing = CitableCorpus.indexurn(sentence.urn, tokencorpus)
		orthotokens[rangeindexing[1]:rangeindexing[2]]
	end
end

# ╔═╡ ab68c779-e090-486a-b30e-12a05376d9fe
"""Compose a CTS URN for the connecting word or words in a sentence."""
function connectorurn(sentencetokens, connections)
	
		psgref = if length(connections) == 1
			
			sentencetokens[connections[1]].urn |> passagecomponent
			
		else
			openpsg = sentencetokens[connections[1]].urn |> passagecomponent
			closepsg = sentencetokens[connections[end]].urn |> passagecomponent
			string(openpsg,"-", closepsg)
		end
		addpassage(sentencetokens[1].urn, psgref)
		
end

# ╔═╡ 78a55417-7588-4ddc-a977-89c1d3bca0b5
md"""> ### User interface for  *sentence selection*
"""

# ╔═╡ a3f6b69d-fc9f-4300-b933-99aabe1b726c
"""Compose a menu to select the connecting word from the first N tokens of the current sentence.
"""
function connectormenu()
	menu = Pair{Union{Int64,Missing, Nothing}, String}[missing => "", nothing => "asyndeton"]
	idx1 = CitableCorpus.indexurn(sentence.urn, tokencorpus)[1]
	idx2 = idx1 + ninitial - 1
	slice =  orthotokens[idx1:idx2]
	for (i,tkn) in enumerate(slice)
		if tkn[2] != LexicalToken()
			# omit: punctuation
		else
			pr = (i => string(i, ". ", tkn[1].text))
			push!(menu, pr)
		end
	end
	
	menu
end

# ╔═╡ 5ee0d8e6-3be6-4eed-8e73-1bc9b12f13be
if prereqs()
	if sentid == 0
		md""	
	else
	md"""*Connecting words*: 

$(@bind connectorlist MultiSelect(connectormenu()))
"""
	end
end

# ╔═╡ 1dc7ec37-fc96-4129-866b-88f5a6b2951b
# Make conditional on satisfaction of necessary conditions ...
sentenceannotation = if isnothing(sentence) 
		nothing 
elseif isnothing(connectorlist) || isnothing(connectorlist[1])
	SentenceAnnotation(
		sentence.urn,
		sentence.sequence,
		nothing
	)
else
SentenceAnnotation(
		sentence.urn,
		sentence.sequence,
		connectorurn(sentencetokens, connectorlist)	
	)	
end

# ╔═╡ 89df8479-12a3-40a9-aee7-87a5c47c1e61
"""Compose an HTML `blockquote` element setting highlighting on any connector tokens in `tknlist` with an index
appearing in the index list `idxlist`.
"""
function hl_connector(tknlist, idxlist)
	displaylines = ["<blockquote>"]
	for (i, t) in enumerate(tknlist)
		if i in idxlist
			push!(displaylines, " <span class=\"connector\">" * t[1].text *"</span>")
		else
		
			if t[2] isa LexicalToken
				push!(displaylines, " " * t[1].text)
			else
				push!(displaylines, t[1].text)
			end
		end
	end
	push!(displaylines, "</blockquote>")
	
	join(displaylines) 
end

# ╔═╡ 84900029-bba1-4f56-9f38-e45f39722d58
if prereqs()
	if ismissing(sentid) || sentid == 0
		md""

	else
		local currpsg = sentence.urn |> passagecomponent
		local str = hl_connector(sentenceorthotokens, connectorlist)
		
		if isempty(connectorlist)
			HTML("<i>Use the following selection box to identify one or more connecting words for this sentence, or select</i> <code>asyndeton</code>:<br/><blockquote><strong>$(currpsg)</strong>: " * str * "</blockquote>")
			
	
			elseif isempty(connectorlist)
			
			HTML("<p><b>Step 1 result:</b></p><blockquote><span class=\"connector\">Asyndeton: no connecting word.</span><br/><strong>$(currpsg)</strong>: " * str * "</blockquote>")
			
		else
			HTML("<p><b>Step 1 result:</b></p><blockquote><strong>$(currpsg)</strong>: " * str * "</blockquote>")
		end
	end
end

# ╔═╡ 702c10de-f79e-4071-bc1a-de148620e639
"""True if requirements for sentence-level annotation (step 1) are satisfied"""
function step1()
	if @isdefined(connectorlist) && ! isempty(connectorlist) && isnothing(connectorlist[1])
		# asyndeton
		true
		
	elseif @isdefined(connectorlist) == false || sentid == 0 || isempty(connectorlist) || isnothing(connectorlist[1])
		false
		
	else
		true
	end
end

# ╔═╡ 0de3aa92-8815-4285-9abb-ea6d507f8ee4
if step1()
	md"""### Step 2. Define verbal expressions, and groups tokens in verbal expressions"""
else
	md""
end

# ╔═╡ 637953de-ab10-4206-bb3e-b4ed54da1235
if step1()
	
	vutips = """
You may abbreviate any item with a minimum unique starting string (highlighted here in **bold-faced** letters).
	
*Syntactic type of verbal expression*

- **ind**ependent clause
- **s**ubordinate clause
- **c**ircumstantial participle
- **at**tributive participle
- **inf**initive in indirect statement
- **p**articiple in indirect statement
- **q**uote
- **as**ide

*Semantic type of verbal expression*

- **t**ransitive
- **i**ntransitive
- **l**inking
	

"""
	Foldable("Cheat sheet for annotating verbal expressions",Markdown.parse(vutips)) |> aside
end


# ╔═╡ a0f1c242-4a19-4085-be17-5d9b870b434a
if step1()
	local step1res = hl_connector(sentenceorthotokens, connectorlist)
	if isnothing(connectorlist[1]) # asyndeton!
		hdg = """<span class=\"connector\"><i>asyndeton</i></span>"""
		
		HTML("<i>Define verbal expressions in this sentence:</i><br/><br/><blockquote><strong>$(passagecomponent(sentenceannotation.range))</strong>  ($(hdg)): " * step1res * "</blockquote>")
	else
		HTML("<i>Define verbal expressions in this sentence:</i><br/><br/><blockquote><strong>$(passagecomponent(sentenceannotation.range))</strong>: " * step1res * "</blockquote>")
	end

end

# ╔═╡ 715cc820-563e-40f5-8fbe-ae3c5da80098
if step1() 
	md"""*Done assigning tokens* $(@bind tokensassigned CheckBox())
	"""  |> aside
else
	md""
end

# ╔═╡ 34335816-0b0e-486f-b01d-f09be94cb286
md"""> ### Global variable derived from the user's *definition of verbal expressions*
>
> - `verbalunits`: vector of `VerbalUnitAnnotations`. 
>
> We use the following functions to construct this:
>
> - `vusfromdf` 
> - `badvuvalues`
> - `vuok`
"""

# ╔═╡ 0fd133f8-9f42-42d2-abe7-34fc955a7250
"""True if all values in DataFrame can be used to construct valid `VerbalUnitAnnotation`.
"""
function vuok(vudataframe)
	vuvalsok = true
	for row in eachrow(vudataframe)
		strs = [
			row.passage, row.syntactic_type,
			row.semantic_type, string(row.depth),
			string(row.sentence)
		]
		try
			va = verbalunit(join(strs, "|"), orthography())
		catch e
			vuvalsok = false
		end
	end
	vuvalsok
end

# ╔═╡ 8b15255d-d824-499d-94d5-0ba34aed3fff
"""Collect error messages for any bad values for syntactic or semantic type
in data frame `vudataframe`.
"""
function badvuvalues(vudataframe)
	
	vuerrors =  []
	for row in eachrow(vudataframe)
		strs = [
			row.passage, row.syntactic_type,
			row.semantic_type, string(row.depth),
			string(row.sentence)
		]
		try
			va = verbalunit(join(strs, "|"), orthography())
		catch e
			push!(vuerrors, e.msg)
		end
	end
	vuerrors
end

# ╔═╡ 5c025e03-1da2-425a-9213-be715697f2b3
"""Create a vector of `VerbalUnitAnnotation`s from the user-edited
data frame `vudataframe`, or return `nothing` if there are errors.
"""
function vusfromdf(vudataframe)
	if vuok(vudataframe)
		verbals = VerbalUnitAnnotation[]
		for row in eachrow(vudataframe)
			strs = [
				row.passage, row.syntactic_type,
				row.semantic_type, string(row.depth),
				string(row.sentence)
			]
			try
				va = verbalunit(join(strs, "|"), orthography())
				push!(verbals, va)
			catch e
				
			end
		end
		verbals
	else
		nothing
	end
	
end

# ╔═╡ 4e432568-2d57-4064-9dc6-73ab3b78cbf8
md"""> ### UI for *defining verbal expressions*
>
> This depends on the editing trick discussed in the foldable section *Why is this notebooks so complicated?*.
>
> - `vusrcdf` is the template data frame we give to the PlutoGrid editing widget.  We create this with the `newvudf` function.
> - `vudf` is the data frame including the user's editing. We create this with the `createvudf` function.


"""

# ╔═╡ 9c3b5512-7e7c-42b2-81d3-6d43778c244d
"""Create a template DataFrame for recording verbal units"""
function newvudf()
	templatedf = DataFrame(
		syntactic_type = ["Independent clause"], 
		semantic_type = "ADD VALUE HERE", 
		depth = 1
	)
end

# ╔═╡ ca0e7f64-ea9c-4379-93a7-df2f82019a97
vusrcdf = newvudf()

# ╔═╡ 5ebca725-912f-49fa-8f9a-43833a62b0ed
let initialize  
	if step1()
	@bind vus editable_table(vusrcdf; filterable=true, pagination=true, height = 300)
	else
		md""
	end
end

# ╔═╡ edea857d-268d-418f-b08c-d78b088cdc44
"""Uses the user edit values for verbal units to create a DataFrame with complete data for verbal units including sentence identifier and correct passage identifier."""
function createvudf()
	spsg =  sentenceannotation.range |> passagecomponent
	nopsg = create_dataframe(vus)

	psg = []
	sem = []
	syn = []
	depths  = []
	sentenceurns = []
	vuidx = 0
	for row in eachrow(nopsg)
		vuidx = vuidx + 1
		push!(psg, string(spsg, ".", vuidx))
		push!(sem, row.semantic_type)
		push!(syn, row.syntactic_type)
		push!(depths, row.depth)
		push!(sentenceurns, sentenceannotation.range)

	end
	DataFrame(
		passage = psg,
		semantic_type = sem,
		syntactic_type = syn,
		depth = depths,
		sentence = sentenceurns
	)
end

# ╔═╡ 908b20bc-fcf8-40d1-9a0b-a4efe2b2ffd8
vudf = if step1() && !isnothing(vus)
	createvudf()
else
	nothing
end


# ╔═╡ a9735bd6-d270-483e-b724-5f2c1dd1b5b2
verbalunits = if isnothing(vudf)
	nothing
else
	vusfromdf(vudf)
end

# ╔═╡ e3b25956-c258-4887-b6dc-e0cb1742aa83
if step1() && @isdefined(vudf) && ! isnothing(vudf)
	if vuok(vudf) #! isnothing(vudf)
		HTML("<p>Defined groups:<p>" * htmlgrouplist(verbalunits)) |> aside
	else
		badvuvallines = ["Please correct the following errors in your definitions of verbal expressions (Unfold the *Cheat sheet for annotating verbal expressions* in the right column if you need help.)", ""]

		for s in  badvuvalues(vudf)
			push!(badvuvallines, "1. " * s)
		end
		badvuvalmsg = Markdown.parse(join(badvuvallines, "\n"))
		
		
		keep_working(badvuvalmsg)
		
	end
	
end

# ╔═╡ 72d51241-9ca7-42be-81f6-9a961ab62fe0
"""True if Step 2 editing is complete."""
function step2()
	@isdefined(vusdefined) && vusdefined && step1()
end

# ╔═╡ d602d574-16a6-47c9-9bcf-b34bf7ac47ce
md"""> ### Global variables derived from *assigning tokens to verbal expressions*
>
> - `intermediatetokens`. This is a Vector of `TokenAnnotations` for each token in the sentence, but without any assigned syntactic roles yet.
"""

# ╔═╡ 45f62b20-de3e-4520-b568-ea93f498be2c
md"""> ### UI for *assigning tokens to verbal expressions*
>
> Another example of the editing trick discussed in the foldable section *Why is this notebooks so complicated?*.
>
> - `tokengroupsdf`: the DataFrame we'll feed to the `PlutoGrid` widget. It has one row ready to edit for each lexical token in the sentence
> - `assignedtokensdf`: the DataFrame with user values, instantiated from the values in a `PlutoGrid` widget
"""

# ╔═╡ cf4c142e-3aad-46d4-be53-62292b779606
tokengroupssrcdf = if step1()
	local tokentuples = []
	for (tkn, tkntype) in sentenceorthotokens
		if typeof(tkntype) == LexicalToken
			push!(tokentuples, (passage = string(passagecomponent(tkn.urn)), token = string(tkn.text), group = 0))
		end
	end
	DataFrame(tokentuples)
else
	[]
end;

# ╔═╡ 59f712d2-12e2-44ef-b79c-b842a134a168
if step1()
	@bind tokengroups editable_table(tokengroupssrcdf; filterable=true, pagination=true)
else 
	md""
end

# ╔═╡ 17fcc9f4-5d1a-483d-94ab-ac710b510cd9
isnothing(tokengroupssrcdf) ? md"`assignedtokensdf` undefined" : describe(tokengroupssrcdf)

# ╔═╡ db319239-96da-4bf3-887c-ff953b56f109
assignedtokensdf = @isdefined(tokengroups) ? create_dataframe(tokengroups) : nothing ;

# ╔═╡ c140b87e-998b-435d-9c91-9babca73c5bf
intermediatetokens = if step1() 
	if isnothing(assignedtokensdf) || nrow(assignedtokensdf) == 0
		nothing
	else
		placeholder = TokenAnnotation[]

		local lexcount = 0
		for t in sentenceorthotokens
			if t[2] isa LexicalToken
				lexcount = lexcount + 1
				row = assignedtokensdf[lexcount, :]
				
				tknurn = addpassage(sentenceannotation.range, row.passage)
				txt = row.token
				vuid = row.group == 0 ? nothing : verbalunits[row.group].id
				push!(placeholder, TokenAnnotation(
				tknurn,
				"lexical",
				txt,
				vuid,
				nothing, nothing, nothing, nothing
				
			))
			else
				push!(placeholder, TokenAnnotation(
					t[1].urn,
					"ignore",
					t[1].text,
					0,
					nothing, nothing, nothing, nothing)
				)
			end
		end

		placeholder
	end
end

# ╔═╡ 5b76798a-69b0-4ac6-b55b-dfb0b204ec2f
if isnothing(intermediatetokens)
else
htmltext_indented(sentenceannotation, verbalunits, intermediatetokens, vucolor = false)  |> HTML
end

# ╔═╡ f113a61d-5ff1-4544-bf7a-3b87d9de0798
if isnothing(intermediatetokens)
else
 "<blockquote>" * htmltext(sentenceannotation, intermediatetokens) * "</blockquote>" |> HTML

end

# ╔═╡ ef91e94f-1a6b-4087-92f4-b5907c5736a4
isnothing(assignedtokensdf) ? md"`assignedtokensdf` undefined" : describe(assignedtokensdf)

# ╔═╡ 4e09278f-3f0c-451e-8e1a-5d2058b695f4
md"""> ### Global variables for *defining syntactic relations*
>
> - `syntaxannotations` The final Vector of `TokenAnnotation`s
>
> We use the `tokensyntaxok` and `tokensyntaxerrors` functions in making this Vector.
"""

# ╔═╡ a5c9a4d7-2cc1-4702-9d3e-c17bda50399a
md"""> ### UI for *defining syntactic relations*
>
> The final example of the editing trick discussed in the foldable section *Why is this notebooks so complicated?*.
> 
> - `syntaxsrcdf`: the DataFrame we'll feed to the PlutoGrid widget. It has one row ready to edit for each lexical token in the sentence.
> - `syntax`: the DataFrame with user edited values.
"""

# ╔═╡ 3b221a15-e014-4c7a-becd-dc16186c8c1b
syntaxsrcdf = if isnothing(intermediatetokens)
	nothing
else
	syntaxtuples = []
	lexcount = 0
	for  t in intermediatetokens
		if t.tokentype == "lexical"
			lexcount = lexcount + 1
			tupl = (
			passage = string(passagecomponent(t.urn)),
			reference = lexcount,
			token = t.text,
			node1 = missing, node1rel = missing, 
			node2 = missing, node2rel = missing
			)
			push!(syntaxtuples, tupl)
		end
	end

	#=
	if isempty(connectorlist) || isnothing(connectorlist[1])
		psg = sentencerange(sentence) |> passagecomponent
		deranged = replace(psg, "-" => "_")
		extrarow = (passage = string( "_asyndeton_",deranged), reference = seq + 1, token = "asyndeton", node1 = missing, node1rel = missing, node2 = missing, node2rel = missing)
		push!(syntaxstrings, extrarow)
	end
		=#
	syntaxtuples |> DataFrame

end;

# ╔═╡ dc599889-4314-422e-8ad5-9f8c74b5d4d9
isnothing(syntaxsrcdf) ? md"`assignedtokensdf` undefined" : describe(syntaxsrcdf)

# ╔═╡ 8158b56a-f0b2-4cc6-afc3-e6b19008bd28
"""True if Step 3 editing is complete."""
function step3()
	step1() && tokensassigned
end

# ╔═╡ 5d356a75-b397-4bee-883f-1237d7a6971d
if step3()
	md"""### Step 3. Define syntactic relations"""
else
	md""
end

# ╔═╡ d871b6f7-f9a9-4747-86b6-101ca7f3d48d
if step3() 
	HTML("""<h4>Edit syntactic relations</h4>

	""")
end

# ╔═╡ 99fb5e68-dc50-4ef0-93a9-a392c9036b60
if step3()
	if nrow(vudf) == 0
	md""
else
	syntaxtips = """
You may abbreviate any item with a minimum unique starting string (highlighted here in **bold-faced** letters).
	
*Syntactic type of token's relation*

- **con**junction
- **subo**rdinate conjunction
- **r**elative pronoun
- **u**nit verb
- **pre**dicate
- **subj**ect
- **di**rect address
- **com**plementary infinitive
- **sup**plementary participle
- **m**odal particle
- **ad**verbial
- **ab**solute
- **at**tributive
- **ar**ticle
- **pro**noun
- **da**tive
- **g**enitive

*Other pre-defined abbreviations*

- **o** == object
- **op** == 	object of preposition
- **s** == subject		
- **sc** == subordinate conjunction
		
"""
	
	Foldable("Cheat sheet for annotating syntactic relations",aside(Markdown.parse(syntaxtips))) |> aside
end
	else
		md""
	end

# ╔═╡ 5b6deb79-3e9c-493f-b33b-60928d6248cf
if step3()
	@bind syntaxdf editable_table(syntaxsrcdf; filterable=true, pagination=true)
else
	md""
end

# ╔═╡ c7b73446-17bf-4cf2-97e0-ac51a6f77acc
syntax = @isdefined(syntaxdf) ? create_dataframe(syntaxdf) : nothing;

# ╔═╡ 610f2928-7795-465d-86b6-5a3d2c38cf37

# Check on intermediatetokens, AND syntax
syntaxannotations = if isnothing(syntax) || isnothing(intermediatetokens)
	nothing
	
else
	newtokens = TokenAnnotation[]
	for tkn in intermediatetokens
		dfmatches = filter(row -> row.passage == passagecomponent(tkn.urn), syntax)
		if nrow(dfmatches) == 1
			cols = [string(tkn.urn), tkn.tokentype, tkn.text, tkn.verbalunit,
				string(dfmatches[1, :node1]),
				dfmatches[1, :node1rel],
				string(dfmatches[1, :node2]),
				dfmatches[1, :node2rel]
			]
			try
				push!(newtokens, token(join(cols, "|"), orthography()))
			catch e
			end
	
			
		else
			push!(newtokens, tkn)
		end
	end
	newtokens
end

# ╔═╡ 50820954-68ff-44df-9f07-e31af269f279
if step3()
	graphstr = mermaiddiagram(sentenceannotation, syntaxannotations)
	mermaid"""$(graphstr)"""

	
else 
	md""
end

# ╔═╡ 0c9bcdd2-7981-4292-b4e3-e68ad3a02e73
"""True if all values in DataFrame can be used to construct valid `VerbalUnitAnnotation`.
"""
function tokensyntaxok(syntaxframe)
	tokensok = true
	for tkn in intermediatetokens
		dfmatchesx = filter(row -> row.passage == passagecomponent(tkn.urn), syntax)
		if nrow(dfmatchesx) == 1
			cols = [string(tkn.urn), tkn.tokentype, tkn.text, tkn.verbalunit,
				string(dfmatchesx[1, :node1]),
				dfmatchesx[1, :node1rel],
				string(dfmatchesx[1, :node2]),
				dfmatchesx[1, :node2rel]
			]
			try 
				newta = token(join(cols, "|"), orthography())
			catch
				tokensok = false
			end
		end
	end
	tokensok
end

# ╔═╡ 8127de22-83d4-4eaa-99ef-892ebf3c7974
"""True if all values in DataFrame can be used to construct valid `VerbalUnitAnnotation`.
"""
function tokensyntaxerrors(syntaxframe)
	tokenerrors = []
	for tkn in intermediatetokens
		dfmatchesx = filter(row -> row.passage == passagecomponent(tkn.urn), syntax)
		if nrow(dfmatchesx) == 1
			cols = [string(tkn.urn), tkn.tokentype, tkn.text, tkn.verbalunit,
				string(dfmatchesx[1, :node1]),
				dfmatchesx[1, :node1rel],
				string(dfmatchesx[1, :node2]),
				dfmatchesx[1, :node2rel]
			]
			try 
				newta = token(join(cols, "|"), orthography())
			catch e
				push!(tokenerrors, e.msg)
			end
		end
	end
	tokenerrors
end

# ╔═╡ d374ee82-a2ed-4b6c-9b60-9f82faa9af3b
if ! isnothing(syntax)
	if tokensyntaxok(vudf) #! isnothing(vudf)
		#HTML("<p>Defined groups:<p>" * htmlgrouplist(verbalunits)) |> aside
	else
		
		badtknvallines = ["Please correct the following errors in your definitions of syntactic relations. (Unfold the *Cheat sheet for annotating syntactic relations* in the right column if you need help.)", ""]

		for s in  tokensyntaxerrors(vudf)
			push!(badtknvallines, "1. " * s)
		end
		badtknvalmsg = Markdown.parse(join(badtknvallines, "\n"))
		
	
		
		
		keep_working(badtknvalmsg)
		
	end
	
end

# ╔═╡ a172281e-eabc-41ff-b5cb-aa73ac691a92
isnothing(syntax) ? md"`assignedtokensdf` undefined" : describe(syntax)

# ╔═╡ d1c1e48c-f3ae-4392-8515-f05c10bfc7ee

md"""> ### File management
>
> The following cell attempts to create the full directory path for the user's selection for output directory.
>
> - `fname` is just the user's name for the project with spaces replaced by underscroes (because white spaces in file names are just evil).
> - `outputfile` is the full path the the file where output will be written.
>
> The `appendannotations` function uses the `GreekSyntax` library to format all the users' annotations as delimited text, and appends this to any existing content in `outputfile`.
>

"""

# ╔═╡ f889d827-1a13-49e0-a13d-59286da5fe45
mkpath(outputdir)

# ╔═╡ debb5ce9-540f-467c-bb42-32ce89896300
fname = replace(title, " " => "_")

# ╔═╡ e96fd15a-11d4-4063-b0c4-4cc18900af0c
if step3()
	
	md"""### Step 4. Save final results
	
*Save to file named* $(fname).cex $(@bind saves CounterButton("Save file"))
"""
end

# ╔═╡ 8feeb318-d51c-48e1-abd4-4c946ed3dc7c
outputfile = joinpath(outputdir, fname * ".cex")

# ╔═╡ a9d2249b-243c-485b-b572-c0642950ab7f
"""Append delimited-text representation of annotations to file `filename`.
"""
function appendannotations(filename, sents, vus, tkns; delimiter = "|")
	hdrlines = isfile(filename) ? readlines(filename) : []
	push!(hdrlines, "")
	push!(hdrlines, "//")
	push!(hdrlines, "// Automatically appended from Pluto notebook \"Analyze syntax of Greek text from a CTS source\" (version $(nbversion))")
	push!(hdrlines, "//")

	txt = join(hdrlines, "\n") * "\n#!sentences\n" * delimited(sents) * "\n\n#!verbal_units\n" * delimited(vus) * "\n\n#!tokens\n" * delimited(tkns)	

	
end

# ╔═╡ 77f7495e-85ea-4eaf-aaa3-866ae4bb9160
if step3()
	if saves > 0
		
		txt = appendannotations(outputfile, [sentenceannotation], verbalunits, syntaxannotations; delimiter = "|")
	
		
		open(outputfile, "w") do io
			write(io, txt)
		end
		tip(md"""Appended data for **sentence $(sentid)** to file $(outputfile).
		""") 
		
	end
end

# ╔═╡ f12dfef3-7b61-485b-9142-fa9473313b7b
md"""> ### Settings for visual formatting"""

# ╔═╡ 3ed465c3-512b-4489-8d7e-3d7fdf565c0c
"""Format user instructions with Markdown admonition."""
instructions(title, text) = Markdown.MD(Markdown.Admonition("tip", title, [text]))

# ╔═╡ d147da8f-3a14-4286-934c-9b52f3ed8a9c
begin
	overview = md"""
This notebook allows you to annotate the syntax of a citable Greek text, and save your annotations to simple delimited text files.

Begin by identifying a CEX source for a citable text to load.  The notebook parses the text into tokenized sentences: syntactic annotations are based on analyzing one sentence at a time.

Choose a sentence to annotate.  The notebook will prompt you, following the model [documented here](https://neelsmith.github.io/GreekSyntax/). The main steps are: 

1. Annotate the [connection of the sentence to its context](https://neelsmith.github.io/GreekSyntax/modelling/sentences/).
2. Identify the sentence's [verbal expressions](https://neelsmith.github.io/GreekSyntax/modelling/verbal_units/), and assign tokens in the sentence to the appropriate verbal expression.
3. Annotate the syntactic relation of tokens (see [https://neelsmith.github.io/GreekSyntax/modelling/tokens/](https://neelsmith.github.io/GreekSyntax/modelling/tokens/) and [https://neelsmith.github.io/GreekSyntax/modelling/syntax/](https://neelsmith.github.io/GreekSyntax/modelling/syntax/)).


When you have completely annotated a sentence, you can save the results to a delimited-text file.  If the file already exists, the new content will be appended to the file, so you can use a single file as you work through multiple sentences.
"""
	Foldable("What this notebook does", instructions("Overview of analyzing syntax", overview)) 
end


# ╔═╡ 389cb7fb-cced-4bc7-ab95-b23b1cb627c1
begin
	tipsmd = md"""

- As you complete each step of annotating a sentence, the next step is presented to you.
- Each step has notes to help you.  Use the dark triangle to unfold a help section.
- In the right column, you'll find reference material: cheat sheets for valid values, and a running summary of data you've entered.
- A table of contents is pinned to the top right of notebook. This can be useful as your notebook grows in length.  For example, if you save your annotatoins for a sentence, and want to continue with a new sentence, you can use the table of contents to jump directly to the section headed *Annotate the connection of the sentence to its context*.  You can hide the table of contents if it gets in your way.
"""
	Foldable("A few tips for navigating this notebook", instructions("Tips for navigating the notebook", tipsmd)) 
end

# ╔═╡ 9e800628-2e42-439d-b0d1-2782360b6882
begin
	loadmsg = md"""

Provide values for the following three input boxes:
	
1. Define a directory for saving results of your annotations. If you enter a directory that does not yet exist, the notebook will attempt to create it.
1. Paste or type a URL for a CEX source for a citable text into the second input box.
2. In the third input box, enter a title to use in formatting text and saving your annotations in local files.

For each input box, use the `Submit` button to verify your entry.  When you have verified all three input boxes, check `Output directory, source URL and title are all correct`.

It may take a moment for the notebook to download and parse your file.

"""
	Foldable("How to load texts to analyze", instructions("Loading files", loadmsg)) 
end


# ╔═╡ 5f41b976-8965-4cc0-862b-b76902d73ae4
begin
orthodetails = md"""


**Greek**: 

- *literary orthography*: texts in the standard orthography of printed editions of ancient Greek texts
- *epichoric Attic*: NOT CURRENTLY AVAILABLE


**Latin**:

- *23-character alphabet*: alphabet uses *i* and *u* for both consonantal and vocalic values
- *24-character alphabet*: alphabet distinguishes vocalic *u* from consonantal *v*, uses *i* for both consonantal and vocalic values
- *25-character alphabet*: alphabet distinguishes vocalic *u* and *i* from consonantal *v* and *j*, respectively

"""

Foldable("Details about language and orthography", instructions("Available choices of language and orthography", orthodetails))
end

# ╔═╡ c6186240-d5e9-44da-b67b-bbb674c97ea6
if prereqs()
	msg1 = md"""
1. Choose a sentence.
2. From the list labelled *Connecting words*, identify one or more connecting words (conjunction, particles) that connect the sentence to its broader context, or choose `asyndeton` if there is none.
	"""


		Foldable("Step 1 instructions", instructions("Annotating a sentence", msg1)) 

end

# ╔═╡ e551cc88-f1c3-4508-a3ae-7b81daafad1b
if step1()
	msg2 = md"""	

In this step, you will work with two data entry  tables.
	
1. In the first table, complete a row for each verbal expression.
1. In the second table, fill in the verbal expression's sequential number to group each token belonging to it. Any connecting words you identified in Step 1 should be left as verbal expression *0*. 


When you have associated each token with the correct verbal expression, check the box `Done assigning tokens` (at the end of the second table).

	
	"""

	Foldable("Step 2 instructions", instructions("Defining verbal units", msg2))
	
end

# ╔═╡ 76e31d77-b3e4-4922-812d-a242c90a3254
if step3()
	msg4 = md"""Associate each token with a token it depends on, and define their relation.  If the token is a conjunction or a relative clause, you should also 
	associate it with a second token and define that relation, too.

	Unfold the cheat sheet below to see a list of valid tags for relations.
	"""
	Foldable("Step 3 instructions",
	instructions("Annotating relations of tokens", msg4))
else
	md""
end

# ╔═╡ 88ebf7e0-9a13-48e7-98ea-a17d876248ab
begin
	if seecss
	cssmsg = md"""
The following two cells define the visual appearance of the text's formatting.  If you are familiar with CSS, you can modify them to tailor the presentation to your preferences.

1.  You can choose to use default CSS from the `GreekSyntax` package, or directly edit CSS values from the following cell.
2. `palette` is a series of colors that the notebook cycles through in highlighting different verbal expressions by color.	You can use a default color palette from `GreekSyntax`, or directly edit the cell to set RGB values.
"""
		instructions("Style your own", cssmsg)
	end
end

# ╔═╡ e3b9930a-1317-45fd-a56d-c27944a25529
begin
	whysocomplicated = md"""	

Because it's fundamentally at odds with what Pluto is all about!

#### Pluto is stateless

- this makes reactivity possible
- cells have a value
- you can't reassign variables

#### Interactive widgets

- wrap a javascript widget in Pluto so cell returns value of widget
- mutable value lives in the DOM only

#### Editing a table
	
- lungben's widget  [PlutoGrid](https://github.com/lungben/PlutoGrid.jl) lets you edit a DataFrame.  You start from a source data frame
- the widget returns a stream of data that you can use to create a new DataFrame with the edited values.  Now any other cell has access to the second DataFrame with edited values.

	"""

	Foldable("Why is this notebook so complicated?", instructions("Using Pluto as for editing data", whysocomplicated)) 
end

# ╔═╡ Cell order:
# ╟─eae1988e-b0b0-4fb0-bd52-c1156e67149e
# ╟─0025d7bb-fc66-4f98-9def-4adfe0aeaf3a
# ╟─548d7257-7eb2-4d7e-a2aa-aa0dc5b4ddb6
# ╟─94bcdb73-7994-49ab-b9dd-449768dc2ebf
# ╟─e98cdbde-4b9b-4439-8ae2-dfed3d4879f4
# ╟─cf7e2ea6-93dc-11ed-3673-af3c467b0f9e
# ╟─d147da8f-3a14-4286-934c-9b52f3ed8a9c
# ╟─389cb7fb-cced-4bc7-ab95-b23b1cb627c1
# ╟─6be1c3da-a7ae-4496-96b7-fc3a41a2418e
# ╟─9e800628-2e42-439d-b0d1-2782360b6882
# ╟─f792e968-b88e-4565-b594-1794fad9991c
# ╟─04a90145-0437-4c34-bec3-91f109f1bc1a
# ╟─61e0062a-f2c1-48ec-b5ce-533607f3a476
# ╟─b679f220-5969-4e8d-87ed-9fa06f9c7e35
# ╟─df550cd1-657b-4401-abbb-72ba7f93ad38
# ╟─6ef835a0-2056-4dd8-a302-8017296d2ce9
# ╟─5f41b976-8965-4cc0-862b-b76902d73ae4
# ╟─95fb9dbf-4a52-44e0-b76d-140846bfb8ce
# ╟─0da2c2a5-0403-43e7-aac3-6c294c59b095
# ╟─63211b87-628a-47a2-9507-8d7351ec4fbb
# ╟─fdbd9313-7b75-4411-a2bd-0677941fc070
# ╟─5d123a0b-b1c1-41a9-9c2f-d04bf635528b
# ╟─c6186240-d5e9-44da-b67b-bbb674c97ea6
# ╟─01197fc5-c76a-406a-afd0-59fff59d0e56
# ╟─73c516de-52af-412d-805a-fd04910a23c7
# ╟─84900029-bba1-4f56-9f38-e45f39722d58
# ╟─5ee0d8e6-3be6-4eed-8e73-1bc9b12f13be
# ╟─0de3aa92-8815-4285-9abb-ea6d507f8ee4
# ╟─e551cc88-f1c3-4508-a3ae-7b81daafad1b
# ╟─637953de-ab10-4206-bb3e-b4ed54da1235
# ╟─a0f1c242-4a19-4085-be17-5d9b870b434a
# ╟─5ebca725-912f-49fa-8f9a-43833a62b0ed
# ╟─e3b25956-c258-4887-b6dc-e0cb1742aa83
# ╟─5b76798a-69b0-4ac6-b55b-dfb0b204ec2f
# ╟─f113a61d-5ff1-4544-bf7a-3b87d9de0798
# ╟─59f712d2-12e2-44ef-b79c-b842a134a168
# ╟─715cc820-563e-40f5-8fbe-ae3c5da80098
# ╟─5d356a75-b397-4bee-883f-1237d7a6971d
# ╟─76e31d77-b3e4-4922-812d-a242c90a3254
# ╟─50820954-68ff-44df-9f07-e31af269f279
# ╟─d871b6f7-f9a9-4747-86b6-101ca7f3d48d
# ╟─99fb5e68-dc50-4ef0-93a9-a392c9036b60
# ╟─e931ff8d-299e-419e-b991-4a9caa94734e
# ╟─5b6deb79-3e9c-493f-b33b-60928d6248cf
# ╟─e96fd15a-11d4-4063-b0c4-4cc18900af0c
# ╟─d374ee82-a2ed-4b6c-9b60-9f82faa9af3b
# ╟─77f7495e-85ea-4eaf-aaa3-866ae4bb9160
# ╟─defb3d5b-07d6-4a9e-bfb8-f3b417265973
# ╟─863f3c5f-f10f-4755-a74a-e011eefc6e14
# ╟─88ebf7e0-9a13-48e7-98ea-a17d876248ab
# ╟─7126004e-586a-426f-bd91-3b02196900bb
# ╟─ababc89a-b183-4cc6-afe1-61bc1d690b6c
# ╟─6892ed5c-cc3b-418a-9f1d-95ea985ae445
# ╟─da77076f-121e-40c6-aeae-05f2728ad918
# ╟─70e6314b-12ee-491c-95ca-85a464b2ed41
# ╟─6084a7fb-9f6d-4c1c-b0f8-b36ff1bd12a8
# ╟─e3b9930a-1317-45fd-a56d-c27944a25529
# ╟─d0880c49-23d8-4180-ad66-993ba8640555
# ╟─3eda4f2c-5145-4472-9d4e-3aaeaff0f732
# ╟─61e97fa8-ca3c-41f1-98e9-8b3ec0d6a811
# ╟─487a4a7a-12dd-4ee6-91ae-8e19b039fe06
# ╟─b387de43-504a-4e10-a157-ca2874a0f648
# ╟─be549c7d-84dc-4c54-9369-6c24981b61e2
# ╟─34204b6e-032f-4a16-a27c-1adbdd4552ff
# ╟─d7c3b7e9-6089-4670-a94b-24bd0fc55af5
# ╟─2492514f-6237-4ddd-829f-ed89a1754b5e
# ╟─cced3ab8-d31c-4911-bda6-d393999e80ef
# ╟─52225c55-ad48-4e1a-a521-fe4dc802e5c1
# ╟─9742760a-d15c-4a85-b115-bc02d781a438
# ╟─96156fef-fd1a-4ca1-83aa-c9f836f5f644
# ╟─1db9ed09-5717-4a14-8b3e-d4e943300bf9
# ╟─f9eb7ac5-0049-455a-b55b-33fdb5515dd7
# ╟─ab8b3a18-7e91-41d5-b649-a98da35bfe48
# ╟─1dc7ec37-fc96-4129-866b-88f5a6b2951b
# ╟─c4301d12-c62b-4161-8847-555d78ca346d
# ╟─14586c88-3e6f-42da-85cb-9470c03e92e1
# ╟─ab68c779-e090-486a-b30e-12a05376d9fe
# ╟─78a55417-7588-4ddc-a977-89c1d3bca0b5
# ╟─a3f6b69d-fc9f-4300-b933-99aabe1b726c
# ╟─89df8479-12a3-40a9-aee7-87a5c47c1e61
# ╟─702c10de-f79e-4071-bc1a-de148620e639
# ╟─34335816-0b0e-486f-b01d-f09be94cb286
# ╟─a9735bd6-d270-483e-b724-5f2c1dd1b5b2
# ╟─0fd133f8-9f42-42d2-abe7-34fc955a7250
# ╟─8b15255d-d824-499d-94d5-0ba34aed3fff
# ╟─5c025e03-1da2-425a-9213-be715697f2b3
# ╟─4e432568-2d57-4064-9dc6-73ab3b78cbf8
# ╟─ca0e7f64-ea9c-4379-93a7-df2f82019a97
# ╟─908b20bc-fcf8-40d1-9a0b-a4efe2b2ffd8
# ╟─9c3b5512-7e7c-42b2-81d3-6d43778c244d
# ╟─edea857d-268d-418f-b08c-d78b088cdc44
# ╟─72d51241-9ca7-42be-81f6-9a961ab62fe0
# ╟─d602d574-16a6-47c9-9bcf-b34bf7ac47ce
# ╟─c140b87e-998b-435d-9c91-9babca73c5bf
# ╟─45f62b20-de3e-4520-b568-ea93f498be2c
# ╟─cf4c142e-3aad-46d4-be53-62292b779606
# ╟─17fcc9f4-5d1a-483d-94ab-ac710b510cd9
# ╟─db319239-96da-4bf3-887c-ff953b56f109
# ╟─ef91e94f-1a6b-4087-92f4-b5907c5736a4
# ╟─4e09278f-3f0c-451e-8e1a-5d2058b695f4
# ╟─610f2928-7795-465d-86b6-5a3d2c38cf37
# ╟─0c9bcdd2-7981-4292-b4e3-e68ad3a02e73
# ╟─8127de22-83d4-4eaa-99ef-892ebf3c7974
# ╟─a5c9a4d7-2cc1-4702-9d3e-c17bda50399a
# ╟─c7b73446-17bf-4cf2-97e0-ac51a6f77acc
# ╟─a172281e-eabc-41ff-b5cb-aa73ac691a92
# ╟─3b221a15-e014-4c7a-becd-dc16186c8c1b
# ╟─dc599889-4314-422e-8ad5-9f8c74b5d4d9
# ╟─8158b56a-f0b2-4cc6-afc3-e6b19008bd28
# ╟─d1c1e48c-f3ae-4392-8515-f05c10bfc7ee
# ╟─f889d827-1a13-49e0-a13d-59286da5fe45
# ╟─debb5ce9-540f-467c-bb42-32ce89896300
# ╟─8feeb318-d51c-48e1-abd4-4c946ed3dc7c
# ╟─a9d2249b-243c-485b-b572-c0642950ab7f
# ╟─f12dfef3-7b61-485b-9142-fa9473313b7b
# ╟─3ed465c3-512b-4489-8d7e-3d7fdf565c0c

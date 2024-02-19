### A Pluto.jl notebook ###
# v0.19.32

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

# ╔═╡ b299ef3e-0d10-11ee-1c90-cdb43d1046f1
# ╠═╡ show_logs = false
begin
	#=using Pkg
	Pkg.add("PlutoUI")
	Pkg.add("HypertextLiteral")
	Pkg.add("Downloads")
	Pkg.add("CSV")
	Pkg.add("DataFrames")
	Pkg.add("Orthography")
	Pkg.add("PolytonicGreek")
	Pkg.add("CitableBase")
	Pkg.add("CitableCorpus")
	Pkg.add("CitableText")

	Pkg.add(url="https://github.com/neelsmith/Kanones.jl")
	=#
	using PlutoUI, HypertextLiteral
	using Downloads
	using CSV, DataFrames
	using Orthography, PolytonicGreek
	using CitableBase, CitableCorpus, CitableText
	using Kanones
	md"""*Unhide this cell to see the Julia environment.*"""
end

# ╔═╡ 2557eed2-0af8-4a7c-a807-0753255fc19d
md"""*Notebook version **0.1.0**.  See version info* $(@bind versioninfo CheckBox())"""

# ╔═╡ 71e79010-a5a8-4b78-aefb-3e0c588497e2
if versioninfo
	md"""
- **0.1.0**: build a parser from download of current LSJ-based string parser
	"""
else
	md""
end

# ╔═╡ f78dfd75-0bd3-4e9c-8604-443d0ec92588
md"""# Use and update an LSJ parser to analyze a corpus"""

# ╔═╡ e5249452-50df-4be0-af31-f74b0b129560
md"""
!!! note "How this works..."

    - load a corpus from a CEX source. If a parser is already built, the corpus is immediately analyzed. This can take a couple of seconds, even on a small corpus.
    - (re)build a parser on demand (checkbox to activate building, button to prompt rebuilding).
"""

# ╔═╡ 9823bc1c-b719-49c3-8f01-8acd219ca67c
md"""## Load data"""

# ╔═╡ 23ea68f0-eb34-4b5d-8976-5bd706b6777d
md"""> Check the following box to build a parser for the first time. With the box checked, you can use the `Rebuild parser` button to rebuild it."""

# ╔═╡ c58f02d7-2506-4cb8-b0a1-11bce7b586d2
md"""*Build parser:* $(@bind build_ok CheckBox()) $(@bind rebuild Button("Rebuild parser")) *Include LSJ mining data* $(@bind lsjtoo CheckBox())"""

# ╔═╡ 28df2b78-497c-4ea9-8721-2629e8220674
md"""## View a passage"""

# ╔═╡ 144e8fc5-f1c6-4bae-a146-19b437b7881d
md"""## Recurring unanalyzed tokens"""

# ╔═╡ bd40d2ca-2f22-4784-888b-0a38c726fe0b
md"""### Unanalyzed singletons"""

# ╔═╡ 69d283dc-f71d-4cfd-add2-f4bbc55fe2f0
md""" ### See passages and parses for form"""

# ╔═╡ af175591-b8e8-48c3-a6d5-78b83d7756c4
md"""*Token (string value)* $(confirm(@bind s TextField(placeholder="θυγατέρα")))"""

# ╔═╡ 7b803068-4345-4c5d-915f-c159336ae12f
html"""
<br/><br/><br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/><br/><br/>
<hr/>
"""

# ╔═╡ 8583437e-f873-4e94-aec3-e27a8922d116
md"""> **Computation you shouldn't need to consult**"""

# ╔═╡ f53b222d-ef12-47ab-bd6c-e80131f94f8f
md"""> Counting"""

# ╔═╡ 2b77d1d2-32dc-4c62-8ce4-739dec0fec1b
md"""> Text selection"""

# ╔═╡ 1b8a2c60-8678-4517-9ed7-840ab689cf85
eaglbase = "https://raw.githubusercontent.com/neelsmith/eagl-texts/main/texts/"
	

# ╔═╡ 1d3b369e-5a0f-4392-a773-be5c75c52abd
eagltexts = [
	"" => "-- Choose a text --",
	"lysias1-filtered.cex" => "Lysias 1",
	"apollodorus-filtered.cex" => "Apollodorus",
	"oeconomicus-filtered.cex" => "Xenophon, Oeconomicus",
	"isaeus-filtered.cex" => "Isaeus",
	"against_neaera-filtered.cex" => "Demosthenes, Against Neaera",
	"herodotus-filtered.cex" => "Herodotus",
	"iliad-allen.cex" => "Iliad (Allen)"
	
]

# ╔═╡ 7291d0b0-6b10-402f-8acd-bd28cf4eb15c
md"""*Select a corpus to analyze*: $(@bind textchoice Select(eagltexts))"""

# ╔═╡ f7c3c9a3-e602-4877-94ec-5e6842348f2d
md"> Parser"

# ╔═╡ 08cee0da-ecd8-4670-a1f1-df522a936f4f
kroot = joinpath(pwd() |> dirname |> dirname, "Kanones.jl")

# ╔═╡ cc52eefd-c02c-4613-ae12-d3d187a4050e
if !isdir(kroot)
	md"""> ## ->>>> ERROR: you  need to have Kanones.jl checked out in an adjacent direxctory"""
else
end

# ╔═╡ d8248ee4-cf64-4076-9f94-491e3f4bf61b
"""Download and instantiate current LSJ parser."""
function lsjparser()
	url = "http://shot.holycross.edu/morphology/comprehensive-current.csv"
	f = Downloads.download(url)
	data = readlines(f)
	rm(f)
	# omit header line:
	StringParser(data[2:end])
end

# ╔═╡ c8a2e87d-2f1f-401f-94ac-835ff9d3ff70
lsj1 = nothing # build_ok ? lsjparser() : nothing

# ╔═╡ 06233f82-6ac2-457b-86e5-fd12c2fe8298
md"""**Initial LSJ parser**: $(lsj1)"""

# ╔═╡ c7ca88b6-6bf8-45aa-b16d-30cbc99c759f
"""Place holder function until this is provided in publication of next Kanones release."""
function coredata(repo = pwd(); lsjtoo = false)
	
    # 1. rules with demo vocab:
    lgr = joinpath(repo, "datasets", "literarygreek-rules")
    ionic = joinpath(repo, "datasets", "ionic")
    homeric = joinpath(repo, "datasets", "homeric")
    # 2. manually validated LSJ vocab:
    lsj = joinpath(repo, "datasets", "lsj-vocab")
    # 3. manually validated NOT in LSJ:
    extra = joinpath(repo, "datasets", "extra")

	
	# 4. any annotations in the local morphology directory:
	wip = joinpath(pwd() |> dirname, "morphology")
	
	# 5. Optionally, auto-quarried data from LSJ:
	if lsjtoo
		lsjmining = joinpath(dirname(repo), "LSJMining.jl", "kanonesdata", "lsjx")
		dataset([lgr, ionic, homeric, lsj, extra, wip, lsjmining]) 
	else
		dataset([lgr, ionic, homeric, lsj, extra, wip]) 	
	end
end

# ╔═╡ f5b03be0-35c6-437a-9348-f68fd356fa5b
"""Rebuild dataset and recompile parser."""
function recompile(root; withlsj)	
	@info("Starting to compile parser using $(root) for core data")
	
	coredata(root; lsjtoo = withlsj) |> stringParser
end

# ╔═╡ a4ec7226-02e2-4034-940c-e9f30b51817a
# ╠═╡ show_logs = false
parser = begin
	rebuild
	build_ok ? recompile(kroot; withlsj = lsjtoo) : nothing
	
end

# ╔═╡ 6405375f-061d-483f-bf3c-a4a2414c3625
isnothing(parser) ? md"**Parser**: no parser loaded." : md"""**Parser**: compiled a parser capable of analyzing **$(length(parser.entries))** forms."""

# ╔═╡ 28da3e9d-3f5b-4e93-a1ce-82aaa2d7e9a2
if isnothing(parser) || isempty(s)
	md""
else
	parseresults = parsetoken(s, parser)
	parsedisplay = ["**$(length(parseresults)) parses** for $(s)",""]
	
	for prs in parseresults
		push!(parsedisplay, "- " * string(prs))
	end
	join(parsedisplay,"\n") |> Markdown.parse
end

# ╔═╡ aed560de-ffe3-4b26-8b66-41e0cb54beea
md"> Analyzed corpus"

# ╔═╡ c54dcf7d-e923-4dab-987b-227bb151ae32
corpus = if isempty(textchoice)
	nothing
else
	fromcex(eaglbase * textchoice, CitableTextCorpus, UrlReader)
end

# ╔═╡ 0a4b67bd-7868-4cde-845d-2d85aa7d4171
begin
	
	if isnothing(corpus)
		@bind psgchoice Select(["" => "--No text selected--"])
	else
		menuhdr = ["" => "--Choose a passage--"]
		psgmenu = map(psg -> (passagecomponent(psg.urn) => passagecomponent(psg.urn)), corpus.passages)
		@bind psgchoice Select(vcat(menuhdr, psgmenu))
	end
end

# ╔═╡ fd3dd69c-91b2-4261-a9d9-59dcea113ef8
ortho =  literaryGreek()

# ╔═╡ 92d8d256-1f21-4fa3-a424-9ce355f9331a
tcorpus = isnothing(corpus) ? nothing : tokenizedcorpus(corpus,ortho, filterby = LexicalToken())

# ╔═╡ 0c3228ec-3023-4fa6-b0d8-7e11fb077b8a
vocab = isnothing(tcorpus) ? nothing : map(psg -> psg.text, tcorpus) |> unique

# ╔═╡ 63414fa1-5484-4361-9bbc-7c5221c86817
isnothing(corpus) ? md"**Text**: *none selected*." :  md"**Text**: citable corpus with **$(length(corpus))** citable passages, comprising **$(length(vocab))** distinct forms (tokens)."


# ╔═╡ 518caceb-d790-4d6b-9678-2197b0d4cbbd
# ╠═╡ show_logs = false
analyzedlexical = isnothing(corpus) || isnothing(parser) ? nothing : parsecorpus(tcorpus, parser)

# ╔═╡ 1825599f-24dc-4c20-af62-9f5545f236bf
if isempty(psgchoice) || isnothing(parser)
else
	#filter(psg -> startswith(passagecomponent(psg.urn), string(psgchoice, ".")), tcorpus.passages)
	atokenmatches = filter(atkn -> startswith(passagecomponent(atkn.ctoken.passage.urn), string(psgchoice, ".")), analyzedlexical.analyses)
	mdwords = []
	for tkn in atokenmatches
		tokentext = tkn.ctoken.passage.text
		if isempty(tkn.analyses)
			push!(mdwords, string("*", tokentext, "*"))
		else
			push!(mdwords, tokentext)
		end
	end
	hdr = "Passage: **$(psgchoice)**\n"
	hdr * "> " * join(mdwords, " ") |> Markdown.parse
end

# ╔═╡ 97ac1bc4-c910-47ba-9712-94a24aeb55f7
analyzedcount = if isnothing(analyzedlexical)
	nothing
else
	filter(at -> ! isempty(at.analyses), analyzedlexical.analyses) |> length
end

# ╔═╡ e33764ef-c482-47c3-a9f5-cd7509aeb292
analyzedpct = if isnothing(analyzedlexical)
	nothing
else
round(analyzedcount / length(analyzedlexical) * 100)
end

# ╔═╡ 63e8c2f9-4ce7-493a-9506-bba563ee7c78
lexurnstrs = isnothing(analyzedlexical) ? nothing : map(analyzedlexical) do alex
	lexx = map(a -> a.lexeme, alex.analyses) 
end |> Iterators.flatten |> collect .|> string |> unique

# ╔═╡ da178dfa-9e59-42ea-b873-4953518f48c2
if isnothing(analyzedlexical)
	md""
else
	
	md"""
Lexical tokens in corpus: **$(length(analyzedlexical))**

Analyzed tokens: **$(analyzedcount)** tokens (**$(analyzedpct)**% of), from **$(length(lexurnstrs))** lexemes.

"""
end

# ╔═╡ 3120740a-d34c-487b-b4ff-f16db52d5594
failed = isnothing(analyzedlexical) ? [] : filter(at -> isempty(at.analyses), analyzedlexical.analyses)

# ╔═╡ fa23a2e4-91e3-4d77-8a7a-45e54a7dd720
"Find passages where token with string value `s` occurs."
function passages(s)
	filter(analyzedlexical.analyses) do at
		at.ctoken.passage.text == nfkc(s)
	end
end

# ╔═╡ 8ffbee45-878f-4500-9563-52ff385344b0
if isempty(s) || isnothing(corpus)
	md""
else
	psglist = passages(nfkc(s))
	psgsmd = length(psglist) == 1 ?  ["**1 occurrence** of $(s)"] : ["**$(length(psglist)) occurrences** of $(s)",""]
	for p in psglist
		canonurn = collapsePassageBy(p.ctoken.passage.urn,1) |> passagecomponent
		canonpsgs = filter(p -> startswith(passagecomponent(p.urn), canonurn),  corpus.passages)
		rawtxt = length(canonpsgs) == 1 ? canonpsgs[1].text : "Hmm... Bad luck looking up $(canonurn) in corpus..."

		txt = replace(rawtxt, s => string("**", s, "**"))
		push!(psgsmd, string(" - `", canonurn, "` ", txt))
	end

	
	join(psgsmd, "\n") |> Markdown.parse

end

# ╔═╡ e455604c-4bf4-4ad7-9201-1ecb69c2f054
md"> Frequencies"

# ╔═╡ 84e4da1d-4082-4393-af39-3c2f828efd94
histo = isnothing(corpus) ? nothing :  corpus_histo(corpus, ortho, filterby = LexicalToken())

# ╔═╡ 8806f333-9486-4a81-be60-8a94a49862c1
failedstrs = PolytonicGreek.sortWords(map(psg -> psg.ctoken.passage.text, failed), ortho)

# ╔═╡ 8c0ea2a2-3892-4a27-aa07-3ec68b08ba56
failedsolos = filter(failedstrs) do s
	if ! haskey(histo, s)
		true
	else
		histo[s] == 1
	end
end

# ╔═╡ 95cf96fc-0108-4c2a-80a9-38bc9dbf71a1
hapaxfailedcount = length(failedsolos)

# ╔═╡ 909e3e41-a20e-4b4d-a4c9-be18480de049
hapaxfailedpct = if isnothing(analyzedlexical)
	nothing
else
	round(hapaxfailedcount / length(analyzedlexical) * 100)
end
	

# ╔═╡ bdf28d17-9446-42f3-9a6b-71874e7ffa73
if isnothing(analyzedlexical)
	md""
	else
md"""
Unanalyzed singletons: **$(hapaxfailedcount)** == **$(hapaxfailedpct)**%

	"""
	end

# ╔═╡ 4a8d9f9a-9e66-4fd4-8040-18320608ad3f
multifails = begin
	filter(failedstrs) do s
		if ! haskey(histo, s)
			true
		else
			histo[s] >= 2
		end
	end
end

# ╔═╡ a87082dc-7247-4619-a16e-bf32fbab3223
failcounts = begin
	failnums = []
	for s in unique(multifails)
		push!(failnums, (s, histo[s]))
	end
	sort(failnums, by = pr -> pr[2], rev = true)
end


# ╔═╡ 2e98352c-79c5-414f-9e4e-1cd537db20db
isempty(failcounts) ? md"" : md"""*Show unanalyzed forms occurring at least `n` times where `n` =*  $(@bind thresh NumberField(1:failcounts[1][2], default= failcounts[1][2]))"""

# ╔═╡ 626ee6a5-10eb-4d6c-ae37-fc5f7890fd14
multisum = if isnothing(analyzedlexical)
	nothing
else
	map(pr -> pr[2], failcounts) |> sum
end

# ╔═╡ 1b4bdd33-0a95-40e5-8c5a-80428646d602
multipct = if isnothing(analyzedlexical)
	nothing
else
	round(multisum / length(analyzedlexical) * 100)
end

# ╔═╡ fe286d8c-8f6b-4db6-b7bb-6281fb3500d8
if isnothing(analyzedlexical)
	md""
else
md"""**$(length(failcounts))** unanalyzed tokens occur multiple times,
	totalling  **$(multisum)** occurrences (**$(multipct)**% of corpus)
"""
end

# ╔═╡ ca156682-0366-4cc1-9ccb-9f6c6372e35a
overthresh = filter(pr -> pr[2] >= thresh, failcounts)	

# ╔═╡ f61a2900-ce35-495c-869c-424c7a2de134
if isnothing(analyzedlexical)
	md""
else

	overthresh_md = map(overthresh) do pr
		string("1. ", pr[1], " **", pr[2], "** occurrences")
	end
	
	Markdown.parse(join(overthresh_md, "\n"))
	
end

# ╔═╡ 5581b269-bea3-4620-9d90-5fe39ee25fef
threshtotal = isempty(overthresh) ? 0 : map(pr -> pr[2], overthresh) |> sum

# ╔═╡ 46ff7581-2747-49e1-8ab0-9db322cf820f
threshpct = threshtotal == 0 ? 0 : round((threshtotal / length(analyzedlexical)) * 100, digits = 1 )

# ╔═╡ 5e14151f-4bcf-430f-9253-a9c6f91e7ebe
threshtotal == 0 ? md"" : md"""Tokens occurring at least **$(thresh)** times: **$(length(overthresh))** tokens  (**$(threshtotal)** occurrences = $(threshpct)%)"""

# ╔═╡ 8738131f-7849-4d58-b1b6-a741ca1c5fef
md"> UI"

# ╔═╡ 53f26f18-0145-4d32-a21e-30cf6cc4dff9
"Make range selection widget"
function rangewidget()
	PlutoUI.combine() do Child
		@htl("""
		<i>Show slice of list from</i>
	
		$([
			@htl("$(name): $(Child(name, NumberField(1:length(failcounts))))</li>")
			for name in ["start", "end"]
		])
	
		""")
	end
end

# ╔═╡ c25d1110-4172-41f7-add6-b71122f63dc4
@bind rangevals confirm(rangewidget())

# ╔═╡ 0957d411-f468-4846-802e-9905c4c33b71
if isnothing(analyzedlexical)
	md""
else
	failedlist = map(failedsolos[rangevals[:start]:rangevals[:end]]) do s
		"- " * s	
	end
	Markdown.parse(join(failedlist, "\n"))
	
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
CitableBase = "d6f014bd-995c-41bd-9893-703339864534"
CitableCorpus = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
CitableText = "41e66566-473b-49d4-85b7-da83b66615d8"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
Kanones = "107500f9-53d4-4696-8485-0747242ad8bc"
Orthography = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PolytonicGreek = "72b824a7-2b4a-40fa-944c-ac4f345dc63a"

[compat]
CSV = "~0.10.11"
CitableBase = "~10.3.1"
CitableCorpus = "~0.13.5"
CitableText = "~0.16.1"
DataFrames = "~1.6.1"
HypertextLiteral = "~0.9.5"
Kanones = "~0.23.0"
Orthography = "~0.21.3"
PlutoUI = "~0.7.54"
PolytonicGreek = "~0.21.10"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "f8f9c51a8d56424820b6d0154aca859e15f0a6c6"

[[deps.ANSIColoredPrinters]]
git-tree-sha1 = "574baf8110975760d391c710b6341da1afa48d8c"
uuid = "a4c015fc-c6ff-483c-b24f-f7ea428134e9"
version = "0.0.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "793501dcd3fa7ce8d375a2c878dca2296232686e"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.2"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "02f731463748db57cc2ebfbd9fbc9ce8280d3433"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.7.1"

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

    [deps.Adapt.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AtticGreek]]
deps = ["DocStringExtensions", "Documenter", "Orthography", "PolytonicGreek", "Test", "TestSetExtensions", "Unicode"]
git-tree-sha1 = "167bca7bed48f7235c254c747b46d9733a3fc134"
uuid = "330c8319-f7ed-461a-8c52-cee5da4c0892"
version = "0.9.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.BitFlags]]
git-tree-sha1 = "2dc09997850d68179b69dafb58ae806167a32b1b"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.8"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "44dbf560808d49041989b8a96cae4cffbeb7966a"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.11"

[[deps.CitableBase]]
deps = ["DocStringExtensions", "Documenter", "Test", "TestSetExtensions"]
git-tree-sha1 = "cc4f1e1db392c4a05eb29026774d6f26ae8ca457"
uuid = "d6f014bd-995c-41bd-9893-703339864534"
version = "10.3.1"

[[deps.CitableCollection]]
deps = ["CSV", "CitableBase", "CitableObject", "CitableText", "CiteEXchange", "DocStringExtensions", "Documenter", "HTTP", "Tables", "Test", "TypedTables"]
git-tree-sha1 = "866abc4fb8ae2d3350a2ccd91f80a24b42e8343c"
uuid = "7b95b006-44c5-4794-afff-00ccebff52d7"
version = "0.4.6"

[[deps.CitableCorpus]]
deps = ["CitableBase", "CitableText", "CiteEXchange", "DocStringExtensions", "Documenter", "HTTP", "Tables", "Test"]
git-tree-sha1 = "f400484e7b0fc1707f9dfd288fa297a4a2d9a2ad"
uuid = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
version = "0.13.5"

[[deps.CitableObject]]
deps = ["CitableBase", "CiteEXchange", "DocStringExtensions", "Documenter", "Downloads", "Test", "TestSetExtensions"]
git-tree-sha1 = "86eb34cc98bc2c5b73dc96da5fe116adba903d56"
uuid = "e2b2f5ea-1cd8-4ce8-9b2b-05dad64c2a57"
version = "0.16.1"

[[deps.CitableParserBuilder]]
deps = ["CSV", "CitableBase", "CitableCorpus", "CitableObject", "CitableText", "Compat", "Dictionaries", "DocStringExtensions", "Documenter", "HTTP", "OrderedCollections", "Orthography", "StatsBase", "Test", "TestSetExtensions", "TypedTables"]
git-tree-sha1 = "8be86fb0193ebd8efb1c3a0dc147f62ff0893cf3"
uuid = "c834cb9d-35b9-419a-8ff8-ecaeea9e2a2a"
version = "0.25.1"

[[deps.CitableText]]
deps = ["CitableBase", "DocStringExtensions", "Documenter", "Test", "TestSetExtensions"]
git-tree-sha1 = "454711838d5b39d1a2329f8942f61dedbd042304"
uuid = "41e66566-473b-49d4-85b7-da83b66615d8"
version = "0.16.1"

[[deps.CiteEXchange]]
deps = ["CSV", "CitableBase", "DocStringExtensions", "Documenter", "HTTP", "Test"]
git-tree-sha1 = "da30bc6866a19e0235319c7fa3ffa6ab7f27e02e"
uuid = "e2e9ead3-1b6c-4e96-b95f-43e6ab899178"
version = "0.10.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "cd67fc487743b2f0fd4380d4cbd3a24660d0eec8"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.3"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "8cfa272e8bdedfa88b6aefbbca7c19f1befac519"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.3.0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DeepDiffs]]
git-tree-sha1 = "9824894295b62a6a4ab6adf1c7bf337b3a9ca34c"
uuid = "ab62b9b5-e342-54a8-a765-a90f495de1a6"
version = "1.2.0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "e82c3c97b5b4ec111f3c1b55228cebc7510525a2"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.25"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Documenter]]
deps = ["ANSIColoredPrinters", "Base64", "Dates", "DocStringExtensions", "IOCapture", "InteractiveUtils", "JSON", "LibGit2", "Logging", "Markdown", "REPL", "Test", "Unicode"]
git-tree-sha1 = "39fd748a73dce4c05a9655475e437170d8fb1b67"
uuid = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
version = "0.27.25"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "9f00e42f8d99fdde64d40c8ea5d14269a2e2c1aa"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.21"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Glob]]
git-tree-sha1 = "97285bbd5230dd766e9ef6749b80fc617126d496"
uuid = "c27321d9-0574-5035-807b-f59d2c89b15c"
version = "1.3.1"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "abbbb9ec3afd783a7cbd82ef01dcd088ea051398"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterableTables]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Requires", "TableTraits", "TableTraitsUtils"]
git-tree-sha1 = "70300b876b2cebde43ebc0df42bc8c94a144e1b4"
uuid = "1c8ee90f-4401-5389-894e-7a04a3dc0f4d"
version = "1.0.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.Kanones]]
deps = ["AtticGreek", "BenchmarkTools", "CSV", "CitableBase", "CitableCollection", "CitableCorpus", "CitableObject", "CitableParserBuilder", "CitableText", "Compat", "DataFrames", "Dates", "DelimitedFiles", "DocStringExtensions", "Documenter", "Downloads", "Glob", "HTTP", "OrderedCollections", "Orthography", "PolytonicGreek", "Query", "SplitApplyCombine", "StatsBase", "Tables", "Test", "TestSetExtensions", "Unicode"]
git-tree-sha1 = "aa86fcbaa0c81194ced16239925487ae0c9caaee"
uuid = "107500f9-53d4-4696-8485-0747242ad8bc"
version = "0.23.0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc6e1927ac521b659af340e0ca45828a3ffc748f"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.12+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Orthography]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "Compat", "DocStringExtensions", "Documenter", "OrderedCollections", "StatsBase", "Test", "TestSetExtensions", "TypedTables", "Unicode"]
git-tree-sha1 = "a337b43561a8b40890720d21fc2b866424465129"
uuid = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
version = "0.21.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "a935806434c9d4c506ba941871b327b96d41f2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "bd7c69c7f7173097e7b5e1be07cee2b8b7447f51"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.54"

[[deps.PolytonicGreek]]
deps = ["Compat", "DocStringExtensions", "Documenter", "Orthography", "Test", "TestSetExtensions", "Unicode"]
git-tree-sha1 = "fdd1745051464dfc6fa35d6c870cb5b82b48a290"
uuid = "72b824a7-2b4a-40fa-944c-ac4f345dc63a"
version = "0.21.10"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "88b895d13d53b5577fd53379d913b9ab9ac82660"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.Query]]
deps = ["DataValues", "IterableTables", "MacroTools", "QueryOperators", "Statistics"]
git-tree-sha1 = "a66aa7ca6f5c29f0e303ccef5c8bd55067df9bbe"
uuid = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
version = "1.0.0"

[[deps.QueryOperators]]
deps = ["DataStructures", "DataValues", "IteratorInterfaceExtensions", "TableShowUtils"]
git-tree-sha1 = "911c64c204e7ecabfd1872eb93c49b4e7c701f02"
uuid = "2aef5ad7-51ca-5a8f-8e88-e75cf067b44b"
version = "0.9.3"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "0e7508ff27ba32f26cd459474ca2ede1bc10991f"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "5165dfb9fd131cf0c6957a3a7605dede376e7b63"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.0"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SplitApplyCombine]]
deps = ["Dictionaries", "Indexing"]
git-tree-sha1 = "48f393b0231516850e39f6c756970e7ca8b77045"
uuid = "03a91e81-4c3e-53e1-a0a4-9c0c8f19dd66"
version = "1.2.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "1d77abd07f617c4868c33d4f5b9e1dbb2643c9cf"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.2"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableShowUtils]]
deps = ["DataValues", "Dates", "JSON", "Markdown", "Unicode"]
git-tree-sha1 = "2a41a3dedda21ed1184a47caab56ed9304e9a038"
uuid = "5e66a065-1f0a-5976-b372-e0b8c017ca10"
version = "0.2.6"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "78fecfe140d7abb480b53a44f3f85b6aa373c293"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.2"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TestSetExtensions]]
deps = ["DeepDiffs", "Distributed", "Test"]
git-tree-sha1 = "3a2919a78b04c29a1a57b05e1618e473162b15d0"
uuid = "98d24dd4-01ad-11ea-1b02-c9a08f80db04"
version = "2.0.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "1fbeaaca45801b4ba17c251dd8603ef24801dd84"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.2"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.TypedTables]]
deps = ["Adapt", "Dictionaries", "Indexing", "SplitApplyCombine", "Tables", "Unicode"]
git-tree-sha1 = "d911ae4e642cf7d56b1165d29ef0a96ba3444ca9"
uuid = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"
version = "1.4.3"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─b299ef3e-0d10-11ee-1c90-cdb43d1046f1
# ╟─2557eed2-0af8-4a7c-a807-0753255fc19d
# ╟─71e79010-a5a8-4b78-aefb-3e0c588497e2
# ╟─f78dfd75-0bd3-4e9c-8604-443d0ec92588
# ╟─e5249452-50df-4be0-af31-f74b0b129560
# ╟─cc52eefd-c02c-4613-ae12-d3d187a4050e
# ╟─9823bc1c-b719-49c3-8f01-8acd219ca67c
# ╟─7291d0b0-6b10-402f-8acd-bd28cf4eb15c
# ╟─23ea68f0-eb34-4b5d-8976-5bd706b6777d
# ╟─c58f02d7-2506-4cb8-b0a1-11bce7b586d2
# ╟─06233f82-6ac2-457b-86e5-fd12c2fe8298
# ╟─6405375f-061d-483f-bf3c-a4a2414c3625
# ╟─63414fa1-5484-4361-9bbc-7c5221c86817
# ╟─da178dfa-9e59-42ea-b873-4953518f48c2
# ╟─28df2b78-497c-4ea9-8721-2629e8220674
# ╟─0a4b67bd-7868-4cde-845d-2d85aa7d4171
# ╟─1825599f-24dc-4c20-af62-9f5545f236bf
# ╟─144e8fc5-f1c6-4bae-a146-19b437b7881d
# ╟─fe286d8c-8f6b-4db6-b7bb-6281fb3500d8
# ╟─2e98352c-79c5-414f-9e4e-1cd537db20db
# ╟─5e14151f-4bcf-430f-9253-a9c6f91e7ebe
# ╟─f61a2900-ce35-495c-869c-424c7a2de134
# ╟─bd40d2ca-2f22-4784-888b-0a38c726fe0b
# ╟─bdf28d17-9446-42f3-9a6b-71874e7ffa73
# ╟─c25d1110-4172-41f7-add6-b71122f63dc4
# ╟─0957d411-f468-4846-802e-9905c4c33b71
# ╟─69d283dc-f71d-4cfd-add2-f4bbc55fe2f0
# ╟─af175591-b8e8-48c3-a6d5-78b83d7756c4
# ╟─28da3e9d-3f5b-4e93-a1ce-82aaa2d7e9a2
# ╟─8ffbee45-878f-4500-9563-52ff385344b0
# ╟─7b803068-4345-4c5d-915f-c159336ae12f
# ╟─8583437e-f873-4e94-aec3-e27a8922d116
# ╟─f53b222d-ef12-47ab-bd6c-e80131f94f8f
# ╟─909e3e41-a20e-4b4d-a4c9-be18480de049
# ╟─95cf96fc-0108-4c2a-80a9-38bc9dbf71a1
# ╟─97ac1bc4-c910-47ba-9712-94a24aeb55f7
# ╟─e33764ef-c482-47c3-a9f5-cd7509aeb292
# ╟─626ee6a5-10eb-4d6c-ae37-fc5f7890fd14
# ╟─1b4bdd33-0a95-40e5-8c5a-80428646d602
# ╟─ca156682-0366-4cc1-9ccb-9f6c6372e35a
# ╟─5581b269-bea3-4620-9d90-5fe39ee25fef
# ╟─46ff7581-2747-49e1-8ab0-9db322cf820f
# ╟─2b77d1d2-32dc-4c62-8ce4-739dec0fec1b
# ╟─1b8a2c60-8678-4517-9ed7-840ab689cf85
# ╟─1d3b369e-5a0f-4392-a773-be5c75c52abd
# ╟─f7c3c9a3-e602-4877-94ec-5e6842348f2d
# ╟─08cee0da-ecd8-4670-a1f1-df522a936f4f
# ╟─d8248ee4-cf64-4076-9f94-491e3f4bf61b
# ╠═c8a2e87d-2f1f-401f-94ac-835ff9d3ff70
# ╠═a4ec7226-02e2-4034-940c-e9f30b51817a
# ╟─f5b03be0-35c6-437a-9348-f68fd356fa5b
# ╟─c7ca88b6-6bf8-45aa-b16d-30cbc99c759f
# ╟─aed560de-ffe3-4b26-8b66-41e0cb54beea
# ╟─c54dcf7d-e923-4dab-987b-227bb151ae32
# ╟─fd3dd69c-91b2-4261-a9d9-59dcea113ef8
# ╟─92d8d256-1f21-4fa3-a424-9ce355f9331a
# ╟─0c3228ec-3023-4fa6-b0d8-7e11fb077b8a
# ╟─518caceb-d790-4d6b-9678-2197b0d4cbbd
# ╟─63e8c2f9-4ce7-493a-9506-bba563ee7c78
# ╟─3120740a-d34c-487b-b4ff-f16db52d5594
# ╟─fa23a2e4-91e3-4d77-8a7a-45e54a7dd720
# ╟─e455604c-4bf4-4ad7-9201-1ecb69c2f054
# ╟─a87082dc-7247-4619-a16e-bf32fbab3223
# ╟─84e4da1d-4082-4393-af39-3c2f828efd94
# ╟─8806f333-9486-4a81-be60-8a94a49862c1
# ╟─8c0ea2a2-3892-4a27-aa07-3ec68b08ba56
# ╟─4a8d9f9a-9e66-4fd4-8040-18320608ad3f
# ╟─8738131f-7849-4d58-b1b6-a741ca1c5fef
# ╟─53f26f18-0145-4d32-a21e-30cf6cc4dff9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

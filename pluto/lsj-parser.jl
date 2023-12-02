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
	using Pkg
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
lsj1 = build_ok ? lsjparser() : nothing

# ╔═╡ 06233f82-6ac2-457b-86e5-fd12c2fe8298
md"""**Initial LSJ parser**: $(lsj1)"""

# ╔═╡ a4ec7226-02e2-4034-940c-e9f30b51817a
# ╠═╡ show_logs = false
parser = begin
	rebuild
	#build_ok ? recompile(kroot; withlsj = lsjtoo) : nothing
	nothing
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
# ╟─c8a2e87d-2f1f-401f-94ac-835ff9d3ff70
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

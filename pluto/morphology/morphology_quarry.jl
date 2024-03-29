### A Pluto.jl notebook ###
# v0.19.26

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

# ╔═╡ e73845ec-f7f6-11ed-01a3-75bd5188678f
begin
	using Dictionaries
	using Downloads
	using CitableParserBuilder
	using Orthography 
	using PolytonicGreek
	using CitableBase, CitableText, CitableCorpus
	using Kanones

	using StatsBase
	using OrderedCollections
	using DataFrames
	
	using Plots
	plotly()
	
	using PlutoUI
end

# ╔═╡ e871f548-3764-4c16-9a27-64fd1b603b86
menu = ["" => "", 
	joinpath(dirname(pwd()), "texts", "oeconomicus.cex") => "Xenophon Oeconomicus",
	joinpath(dirname(pwd()), "texts", "lysias1.cex") => "Lysias 1"
]

# ╔═╡ 17e57a5f-12b2-4e47-8bd2-de5e0f2b5c5c
md"""*To see the Pluto environment, unhide the following cell.*"""

# ╔═╡ 5187fb8e-8186-435f-b2de-318a60b38264
md"""## 1. Citable text"""

# ╔═╡ 92a2622f-5c83-4341-ba8d-dc864dd3c556
md"""Choose a text: $(@bind src Select(menu))"""

# ╔═╡ b5cbb1a9-ee3b-4236-af73-84fa9f278665
corpus = isempty(src) ? nothing : fromcex(src, CitableTextCorpus, FileReader)

# ╔═╡ e06efadb-4dc7-463e-aad5-e6e198c72db2
md"""## 2. Citable tokens"""

# ╔═╡ 66cef781-a849-4ff5-bc48-66d7dcd88c61
lg = literaryGreek()

# ╔═╡ 6dce46e6-b25b-49c5-a8ba-03c3953356c2
citabletokens = isnothing(corpus) ? nothing : tokenize(corpus, lg)

# ╔═╡ 725bb091-aef0-471e-a36e-9bae7598e6a8
md"""## 3. Analyzed tokens"""

# ╔═╡ 188a3b26-90bd-4764-882b-cdc43757b991
md"""Use a delimited-text source to build a DFParser: can be either a URL or a local file."""

# ╔═╡ e5f799bf-ecc4-4ffa-a114-7391b98f8be6
# Alternative to local file: use a URL:
begin
	#parsersrc = "https://raw.githubusercontent.com/neelsmith/Kanones.jl/dev/parsers/current-core.csv"
	#parser = dfParser(Downloads.download(parsersrc))
end

# ╔═╡ fdb04419-a763-498b-a28f-4e899b8bb5e2
parsersrc = "/Users/nsmith/Dropbox/_kanones/literarygreek-all-2023-05-25.csv"

# ╔═╡ e41f7627-bf49-4844-a49d-51714c1ee91d
# ╠═╡ show_logs = false
parser = dfParser(read(parsersrc))

# ╔═╡ 8bc02373-164c-4b32-9cb8-6d41a37e2626
# ╠═╡ show_logs = false
analyzedlexical = isnothing(corpus) ? nothing : parsecorpus(tokenizedcorpus(corpus,lg, filterby = LexicalToken()), parser)

# ╔═╡ ab586cf9-3cc0-456a-9ff1-c8650184d0fb
md"""##### Example applications"""

# ╔═╡ cd4584d5-278e-4115-9723-ac3e171f49ee
exampleform = "ποιησαίμην"

# ╔═╡ c84a16d7-ae9d-4e80-959f-5e20df34aed0
md"""Parsing yields a vector of `Analysis` objects."""

# ╔═╡ 8813b5a9-cc32-4ee7-9d39-02d92de8b37a
parses = parsetoken(exampleform, parser)

# ╔═╡ 8b4548b7-2565-4811-b9f0-eb234f6d26ac
# This is crude. Need functions to extract lexemes from these analyses.
# For this demo, we just take the lexeme member of the first parse. :-(
parsedlex = parses[1].lexeme

# ╔═╡ 97f0937d-ab49-4918-8f1d-99d9990e7ff4
lexstring =  string(parsedlex)

# ╔═╡ 1dada4ae-8737-465a-942a-5fc9df4be1c4
isnothing(analyzedlexical) ? nothing : stringsforlexeme(analyzedlexical.analyses, lexstring)

# ╔═╡ 5b3fbd77-d4e1-459b-9eec-a40d335d3c0e
isnothing(analyzedlexical) ? nothing : passagesforlexeme(analyzedlexical.analyses, lexstring)

# ╔═╡ d030db85-f4a0-4729-b6d5-d1a3c1ea6057
md""" ## 4. Indexing tokens and lexemes"""

# ╔═╡ bd270d84-da87-4fe5-bf33-11a6f695f71f
tokenindex = isnothing(corpus) ? nothing : corpusindex(corpus, lg)

# ╔═╡ 7bbc9d70-5a54-4508-a27b-e49c8ece039c
# ╠═╡ show_logs = false
lexdict  =  isnothing(analyzedlexical) ? nothing :  lexemedictionary(analyzedlexical.analyses, tokenindex)

# ╔═╡ 50f7c7ce-c0d3-41de-906c-424371962547
md""" ##### Example application"""

# ╔═╡ 2a97632e-2e83-448a-96d9-d933408fb31b
md"The token index is a simple index of a token's string value to a vector of CTS URNs:"

# ╔═╡ c378543b-5274-4d95-a758-d8961955f7f5
isnothing(tokenindex) ? nothing : tokenindex[exampleform]

# ╔═╡ dc373828-65cd-4585-a2c4-b9a12204df59
md"""The lexical index is a two-tier index:  the string value of the lexeme URN yields a token index (that is, an index of token strings to CTS URNs."""

# ╔═╡ 85faea2d-6083-4551-bce1-ae07a3b6546b
isnothing(lexdict) ? nothing : lexdict[lexstring]

# ╔═╡ 2c120b2c-15db-4834-af49-32a6d4971aba
isnothing(lexdict) ? nothing : lexdict[lexstring][exampleform]

# ╔═╡ 129c8993-113f-47a6-a31c-e4c3f3c87798
isnothing(lexdict) ? nothing :  tokenindex[exampleform] == lexdict[lexstring][exampleform]

# ╔═╡ 47791d64-2517-4625-8402-c9d16a07ba3e
md""" ## 5. Surveying morphology of a corpus: tokens and lexemes"""

# ╔═╡ 3f42716a-4b5e-4983-b934-8892045eaf37
md"""### Histograms of tokens and lexemes"""

# ╔═╡ 17350592-8a0d-4db8-99a4-ae1f4a7dfba1
histo = isnothing(corpus) ? nothing :  corpus_histo(corpus, lg, filterby = LexicalToken())#, normalizer =  knormal)

# ╔═╡ 4d3ca7ee-220c-430c-90c0-7d0827a7c974
"""Histogram of lexemes properly belongs in `CitableParserBuilder`."""
function lexemehisto(alist; labeller = string)
	flattened = map(at -> at.analyses, alist) |> Iterators.flatten |> collect
	lexflattened = map(at -> labeller(at.lexeme), flattened)
	sort!(OrderedDict(countmap(lexflattened)); byvalue=true, rev=true)
end

# ╔═╡ 49ec57f7-507e-45bd-9862-f59935a2b949
analyzedlexical

# ╔═╡ f804125e-2c78-4637-bea8-c816fadf4b4e
md""" #### Find unanalyzed"""

# ╔═╡ b7e4eab6-a986-4614-bde8-becfe1baff58
failed = isnothing(analyzedlexical) ? nothing : filter(at -> isempty(at.analyses), analyzedlexical.analyses)

# ╔═╡ 4855b2b6-1a4b-4ded-b9fd-70315d25aa70
"""Histogram of forms properly belongs in `CitableParserBuilder`."""
function formshisto(alist)
	flattened = map(at -> at.ctoken.passage.text, alist) |> collect
	
	sort!(OrderedDict(countmap(flattened)); byvalue=true, rev=true)
end

# ╔═╡ fc4dae2b-56f2-49c4-ae78-93229a5e4b44
isnothing(failed) ? nothing :  formshisto(failed)

# ╔═╡ ab14c401-6b81-4f92-a76a-25fdfce303c4
md""" ## 6. Label lexemes"""

# ╔═╡ 7f7167f5-b401-4535-b530-708a142fb35c
# ╠═╡ show_logs = false
 labeldict = Kanones.lsjdict()

# ╔═╡ cc58effb-d9a8-40ae-813f-dbda4eaa0caf
# ╠═╡ show_logs = false
labeldictx = Kanones.lsjxdict()

# ╔═╡ ec1037e5-33db-46f5-b7a9-93e23450ca11
function hacklabel(lexurn)
	s = string(lexurn)
	if startswith(s, "lsjx.")
		stripped = replace(s, "lsjx." => "")
		haskey(labeldictx, stripped) ? string(s, "@", labeldictx[stripped]) : string(s, "@labelmissing")
	elseif startswith(s, "lsj.")
		stripped = replace(s, "lsj." => "")
		haskey(labeldict, stripped) ? string(s, "@", labeldict[stripped]) : 
		string(s, "@labelmissing")
	else
		string(lexurn, "@nolabel")
	end
end

# ╔═╡ 496e7221-f4c1-4088-a2f8-bf85b913ee55
isnothing(analyzedlexical) ? nothing : lexemehisto(analyzedlexical.analyses, labeller = hacklabel)

# ╔═╡ cba2e310-f210-4edb-b3db-358829a6abde
md""" ### 7. Surveying morphology of Greek corpus: forms"""

# ╔═╡ 621da80b-5cce-4f79-9cd9-90ddd76bdf61
md"""#### "Parts of speech" (analytical type)"""

# ╔═╡ 8a2bdbb7-7aad-45e7-afc6-d55007b7ea66
"Compute histogram of morphological forms."
function poshisto(alist)
	flattened = map(at -> at.analyses, alist) |> Iterators.flatten |> collect
	# analyzedtokens.analyses[1].analyses[1].form
	morphflattened = map(at -> string(typeof(greekForm(at.form))), flattened)
	sort!(OrderedDict(countmap(morphflattened)); byvalue=true, rev=true)
end

# ╔═╡ babe0667-4ff7-4511-9a0b-40f2d84ed48a
posh = isnothing(analyzedlexical) ? nothing : poshisto(analyzedlexical)

# ╔═╡ e19913c8-7c3c-440f-9395-3d9ce8d8e7a7
begin
	if isnothing(posh)
	else
	poslabels  = keys(posh) |> collect
	poshvals = map(k -> posh[k], poslabels)
	bar(poslabels, poshvals, title = "'Part of speech' (analytical type)", xrotation = -45, xticks = :all, legend = false)
	end
end

# ╔═╡ bc805623-c0e6-4ff6-90a1-dff0fede62e6
md"""#### All individual forms"""

# ╔═╡ 91ed541a-05b5-400c-94cd-0544b11dcc06
"Compute histogram of morphological forms."
function morphhisto(alist)
	flattened = map(at -> at.analyses, alist) |> Iterators.flatten |> collect
	# analyzedtokens.analyses[1].analyses[1].form
	morphflattened = map(at -> label(greekForm(at.form)), flattened)
	sort!(OrderedDict(countmap(morphflattened)); byvalue=true, rev=true)
end

# ╔═╡ 17f35d7a-ebb7-45d4-877e-6665e9e3290e
mh = isnothing(analyzedlexical) ? nothing : morphhisto(analyzedlexical)

# ╔═╡ be561d1d-0cf6-4c89-ab15-4e733e2b712b
md""" #### Person-number of finite verbs"""

# ╔═╡ 551958f8-3284-487d-a25b-01a36b1c1013
"Compute histogram of person-number combinations for finite verbs."
function pnhisto(alist)
	flattened = map(at -> at.analyses, alist) |> Iterators.flatten |> collect
	finites = filter(a -> greekForm(a.form) isa GMFFiniteVerb, flattened)
	pns = map(at -> label(gmpPerson(greekForm(at.form))) * " " * label(gmpNumber(greekForm(at.form))), finites)
	
	sort!(OrderedDict(countmap(pns)); byvalue=true, rev=true)
end

# ╔═╡ d64fe501-7e29-4e03-ad69-eb78891e4227
pnh = isnothing(analyzedlexical) ? nothing : pnhisto(analyzedlexical)

# ╔═╡ fb273b04-0497-4277-9e3b-d31c4edf96cb
begin
	if isnothing(pnh)
	else
	pnhlabels  = keys(pnh) |> collect
	pnhvals = map(k -> pnh[k], pnhlabels)
	bar(pnhlabels, pnhvals, title = "Person-number combinations", xrotation = -45, xticks = :all, legend = false)
	end
end

# ╔═╡ 5aa2d5f1-8095-472b-b083-d76ea5c75052
md""" #### Mood of finite verbs"""

# ╔═╡ 597f3d08-e464-4cf1-9978-21e07bac0799
"Compute histogram of person-number combinations for finite verbs."
function moodhisto(alist)
	flattened = map(at -> at.analyses, alist) |> Iterators.flatten |> collect
	finites = filter(a -> greekForm(a.form) isa GMFFiniteVerb, flattened)
	moods = map(at -> label(gmpMood(greekForm(at.form))), finites)
	
	sort!(OrderedDict(countmap(moods)); byvalue=true, rev=true)
end

# ╔═╡ 544ae06d-4266-4681-aaac-abe791658410
moodh = isnothing(analyzedlexical) ? nothing : moodhisto(analyzedlexical)

# ╔═╡ f49cc7d6-e2e2-45c9-a30c-fa3871a1b349
begin
	if isnothing(moodh)
	else
	moodlabels  = keys(moodh) |> collect
	moodvals = map(k -> moodh[k], moodlabels)
	bar(moodlabels, moodvals, title = "Mood", xrotation = -45, xticks = :all, legend = false)
	end
end

# ╔═╡ ec99f80f-56c8-4085-a487-8970b4325247
md""" #### Tense-voice of all verbal forms"""

# ╔═╡ 9875fcdd-facf-4204-b628-5b0574760bb7
"Compute histogram of person-number combinations for finite verbs."
function tvhisto(alist)
	flattened = map(at -> at.analyses, alist) |> Iterators.flatten |> collect
	verbs = filter(a -> greekForm(a.form) isa GMFFiniteVerb || greekForm(a.form) isa GMFInfinitive || greekForm(a.form) isa GMFParticiple , flattened)
	tvs = map(at -> label(gmpTense(greekForm(at.form))) * " " * label(gmpVoice(greekForm(at.form))), verbs)
	
	sort!(OrderedDict(countmap(tvs)); byvalue=true, rev=true)
end

# ╔═╡ 2a570046-4851-4cd3-aa90-3020667359f1
tvh = isnothing(analyzedlexical) ? nothing : tvhisto(analyzedlexical)

# ╔═╡ 92181982-74db-4c3e-adff-1f803f637d34
begin
	if isnothing(tvh)
	else
	tvlabels  = keys(tvh) |> collect
	tvvals = map(k -> tvh[k], tvlabels)
	bar(tvlabels, tvvals, title = "Tense-voice combinations (finite and non-finite)", xrotation = -45, xticks = :all, legend = false)
	end
end

# ╔═╡ d5934aed-1990-45b5-a1b6-4cdfe0bde7da
md""" #### Tense-mood-voice combinations"""

# ╔═╡ 7556409b-ee74-4f9f-9e02-d927ca1ae157
"Compute histogram of person-number combinations for finite verbs."
function tmvhisto(alist)
	flattened = map(at -> at.analyses, alist) |> Iterators.flatten |> collect
	finites = filter(a -> greekForm(a.form) isa GMFFiniteVerb, flattened)
	tmvs = map(at -> label(gmpTense(greekForm(at.form))) * " " *  label(gmpMood(greekForm(at.form))) * " " * label(gmpVoice(greekForm(at.form))), finites)
	
	sort!(OrderedDict(countmap(tmvs)); byvalue=true, rev=true)
end

# ╔═╡ aa56b89b-74a7-44d2-83bb-717235596664
tmvh = isnothing(analyzedlexical) ? nothing : tmvhisto(analyzedlexical)

# ╔═╡ a982c017-bd1a-4141-bebf-7385190a2ad3
begin
	if isnothing(tmvhisto)
	else
	tmvlabels  = keys(tmvh) |> collect
	tmvvals = map(k -> tmvh[k], tmvlabels)
	bar(tmvlabels, tmvvals, title = "Tense-mood-voice combinations", xrotation = -45, xticks = :all, legend = false)
	end
end

# ╔═╡ 5407c0cd-e30c-4652-854a-11a27687b871
html"""
<br/>
<br/>
<br/>
<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
"""

# ╔═╡ 24d33c4d-e59d-49c8-8fc8-459e0637f25e
md"""
---


> Stuff to review
"""

# ╔═╡ 96e13fbe-fe1d-4c12-b535-2a39926189b7
md"""### Core vocabulary: compare sets of tokens"""

# ╔═╡ 0f14ab53-2da6-4287-8380-25fb428d2c4f
vocab1 = keys(histo1) |> collect


# ╔═╡ d68c208c-a234-475d-8702-55691ebf096a
vocab2 = keys(histo2) |> collect

# ╔═╡ dc7bee7b-b924-4ad9-8230-485f9c228bca
md"""Compare top n vocabulary items: 

*n* $(@bind vocabsize Slider(100:10:1000; default=100, show_value=true))"""

# ╔═╡ 490e9116-fa5e-4f0f-ae4f-e15b3c2c3e87
overlaps = filter(s -> s in vocab2[1:vocabsize], vocab1[1:vocabsize])


# ╔═╡ 363d38e6-2116-49a3-94f0-721c941180fc
missinglists = begin
	

	in1not2 = String[]
	for s in vocab1[1:vocabsize]
		if s in vocab2[1:vocabsize]
		else
			push!(in1not2, s)
		end
	end

	in2not1 = String[]
	for s in vocab2[1:vocabsize]
		if s in vocab1[1:vocabsize]
		else
			push!(in2not1, s)
		end
	end
	(missing1 = in2not1, missing2 = in1not2, )
end

# ╔═╡ 7b9429d1-932d-4dae-98a3-4101bfdbe7ef
md"""## Vocabulary comparisons: lexemes"""

# ╔═╡ a95e1a70-fda3-46a3-919e-7149fb30655c
md"""Download current Kanones *core* data, and instantiate a parser:"""

# ╔═╡ fb413fd7-557e-47fc-bbf0-f6f6440b293c
# This is already in Kanones `dev` branch as `lexemes`
function pulllexemes(dfp::DFParser)
    DataFrames.select(dfp.df, :Lexeme) |> unique
end

# ╔═╡ efa8ae03-b471-4d55-a842-ccbb09d5ff3a
lexx = pulllexemes(parser)

# ╔═╡ fd6a733f-0f40-42a4-9482-6bb66659d070
begin
	labels = []
	for l in Matrix{String}(lexx)
		stripped = replace(l, "lsj." => "")
	   if haskey(labeldict, stripped)
	       push!(labels, "$(stripped) -> $(labeldict[stripped])")
		   else
		   push!(labels, "$(stripped) -> NOLABEL")
	   end
	end
	labels
end

# ╔═╡ b4bf2388-429e-44f7-b918-5bcadb1a523a
md"""Let's do some parsing..."""

# ╔═╡ 5719d0da-9f69-4305-a3e1-ca3f0ab4c9a8
wordlist1 = begin
	wl1 = String[]
	for k in keys(histo1)
		push!(wl1, k)
	end
	wl1
end

# ╔═╡ aeb8fbb5-dc44-45bb-a90a-7e0710f25f6e
wordlist2 = begin
	wl2 = String[]
	for k in keys(histo2)
		push!(wl2, k)
	end
	wl2
end

# ╔═╡ 7287dc19-be34-4cb3-bc0e-d838f3565f8b
# ╠═╡ show_logs = false
parseresults1 = parselist(wordlist1, parser)

# ╔═╡ b04fa238-dfcb-446e-b731-609dd05f65e9
analyses1 = values(parseresults1) |> Iterators.flatten |> collect

# ╔═╡ c273ab1f-437a-4b76-8b31-aff484f00a14
# ╠═╡ show_logs = false
parseresults2 = parselist(wordlist2, parser)

# ╔═╡ 6a295c87-e06b-4129-8710-5227ca02167f
eg = parseresults1["τοὺς"]

# ╔═╡ 9830bb9d-90a4-44e9-9b70-ab9d5dfd0aab
function lexlabel(u::LexemeUrn, dict)
	stripped = replace(string(u), "lsj." => "")
	if haskey(dict, stripped)
		stripped * ": " * dict[stripped]
	else
		stripped * ": NO LABEL"
	end
end

# ╔═╡ 0c1f1e66-215f-4db2-bddb-41df060e978e
lexlabel(eg[1].lexeme, labeldict)

# ╔═╡ 32bd7000-28aa-46dc-a49d-87d6fe21b80f
eg[1].lexeme |> string

# ╔═╡ 7dc70a52-bf32-4aea-9705-a251ae08c632
md"""### Map tokens to analyses"""

# ╔═╡ 27521a1c-c188-42aa-9c0d-384bf65ff15b
tokens1 = tokenizedcorpus(corpus1, literaryGreek(), filterby = LexicalToken())

# ╔═╡ 8d6da432-3110-41a6-aeb1-7a43c7e54d59
c1analyses = map(t -> parseresults1[t.text], tokens1)

# ╔═╡ 01605233-80e4-4d55-83a7-e0937db35630
c1analyses |> length

# ╔═╡ af2e70a3-a693-488e-b6a9-369a2ec30d41
md""" ## Surveying analyses"""

# ╔═╡ ce804e31-3e0e-4922-8a2b-86d4355d47cd
lexemehisto(analyzedtokens.analyses)

# ╔═╡ 02f60db8-9a87-4178-968a-54c1bc7931c6


# ╔═╡ c7e8aaa2-a8ff-4268-a2f8-6eb77230b19a
function surveyforms(alist)
	map(a -> a.form, alist)
end

# ╔═╡ e45776ac-6db2-4da4-aa05-7e98c4da22be
lexsurvey = surveylexemes(c1analyses, labeldict)

# ╔═╡ 06c835b0-ba8f-42e8-a967-c1585db65155
ys1 = lexsurvey |> values |> collect 

# ╔═╡ 5d1e7f02-1fbe-455c-bffb-ef0fe6fcff25
typeof(ys1)

# ╔═╡ 53ab67da-3239-4c1b-bdab-a9745450f79e
xs1 = lexsurvey |> keys |> collect 

# ╔═╡ 4506c7b9-1734-4c40-83df-67cd808656ee
bar(xs1, ys1, ticktext = ys1)

# ╔═╡ 7c38ea51-c71c-4b78-8c36-a01d3c24c323
begin
	trace = bar(xs1, ys1, ticktext = ys1)


	plot(trace)

end

# ╔═╡ b788cb5a-04f4-4d39-9ce8-1a723cc313bb
typeof(xs1)

# ╔═╡ 63b234f7-2559-47b2-b15f-1046d6a5fa0a
surveyforms(analyses1)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CitableBase = "d6f014bd-995c-41bd-9893-703339864534"
CitableCorpus = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
CitableParserBuilder = "c834cb9d-35b9-419a-8ff8-ecaeea9e2a2a"
CitableText = "41e66566-473b-49d4-85b7-da83b66615d8"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dictionaries = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
Kanones = "107500f9-53d4-4696-8485-0747242ad8bc"
OrderedCollections = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
Orthography = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PolytonicGreek = "72b824a7-2b4a-40fa-944c-ac4f345dc63a"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
CitableBase = "~10.2.4"
CitableCorpus = "~0.13.3"
CitableParserBuilder = "~0.24.0"
CitableText = "~0.15.2"
DataFrames = "~1.5.0"
Dictionaries = "~0.3.25"
Kanones = "~0.16.4"
OrderedCollections = "~1.6.0"
Orthography = "~0.21.0"
Plots = "~1.38.12"
PlutoUI = "~0.7.51"
PolytonicGreek = "~0.18.2"
StatsBase = "~0.33.21"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.1"
manifest_format = "2.0"
project_hash = "97854bbc9d4f12dabe2a7fb533cd6c0c0fa0b2ca"

[[deps.ANSIColoredPrinters]]
git-tree-sha1 = "574baf8110975760d391c710b6341da1afa48d8c"
uuid = "a4c015fc-c6ff-483c-b24f-f7ea428134e9"
version = "0.0.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "76289dc51920fdc6e0013c872ba9551d54961c24"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.2"

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
deps = ["DocStringExtensions", "Documenter", "Orthography", "PolytonicGreek", "Test", "Unicode"]
git-tree-sha1 = "1d75f26ccea30d5982e9123429c725f64acc0e7f"
uuid = "330c8319-f7ed-461a-8c52-cee5da4c0892"
version = "0.8.6"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "ed28c86cbde3dc3f53cf76643c2e9bc11d56acc7"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.10"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.CitableBase]]
deps = ["DocStringExtensions", "Documenter", "HTTP", "Test"]
git-tree-sha1 = "80afb8990f22cb3602aacce4c78f9300f67fdaae"
uuid = "d6f014bd-995c-41bd-9893-703339864534"
version = "10.2.4"

[[deps.CitableCorpus]]
deps = ["CitableBase", "CitableText", "CiteEXchange", "DocStringExtensions", "Documenter", "HTTP", "Tables", "Test"]
git-tree-sha1 = "57d761843bd930006d2563f43455db6eb756186c"
uuid = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
version = "0.13.3"

[[deps.CitableObject]]
deps = ["CitableBase", "CiteEXchange", "DocStringExtensions", "Documenter", "Downloads", "Test"]
git-tree-sha1 = "e147d2fa5fd4c036fd7b0ba0d14bf60d26dfefd2"
uuid = "e2b2f5ea-1cd8-4ce8-9b2b-05dad64c2a57"
version = "0.15.1"

[[deps.CitableParserBuilder]]
deps = ["CSV", "CitableBase", "CitableCorpus", "CitableObject", "CitableText", "Compat", "DataStructures", "DocStringExtensions", "Documenter", "HTTP", "OrderedCollections", "Orthography", "StatsBase", "Test", "TestSetExtensions", "TypedTables"]
git-tree-sha1 = "bc50aed21a98a00d9e50e43ebb8682c06d759037"
uuid = "c834cb9d-35b9-419a-8ff8-ecaeea9e2a2a"
version = "0.24.0"

[[deps.CitableText]]
deps = ["CitableBase", "DocStringExtensions", "Documenter", "Test"]
git-tree-sha1 = "87c096e67162faf21c0983a29396270cca168b4e"
uuid = "41e66566-473b-49d4-85b7-da83b66615d8"
version = "0.15.2"

[[deps.CiteEXchange]]
deps = ["CSV", "CitableBase", "DocStringExtensions", "Documenter", "HTTP", "Test"]
git-tree-sha1 = "8637a7520d7692d68cdebec69740d84e50da5750"
uuid = "e2e9ead3-1b6c-4e96-b95f-43e6ab899178"
version = "0.10.1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "be6ab11021cd29f0344d5c4357b163af05a48cba"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.21.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "7a60c856b9fa189eb34f5f8a6f6b5529b7942957"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "96d823b94ba8d187a6d8f0826e731195a74b90e9"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.2.0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "738fec4d684a9a6ee9598a8bfee305b26831f28c"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.2"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "aa51303df86f8626a962fccb878430cdb0a97eee"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.5.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

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
git-tree-sha1 = "58fea7c536acd71f3eef6be3b21c0df5f3df88fd"
uuid = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
version = "0.27.24"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "8b8a2fd4536ece6e554168c21860b6820a8a83db"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.7"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "19fad9cd9ae44847fe842558a744748084a722d1"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.7+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.Glob]]
git-tree-sha1 = "97285bbd5230dd766e9ef6749b80fc617126d496"
uuid = "c27321d9-0574-5035-807b-f59d2c89b15c"
version = "1.3.1"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "ba9eca9f8bdb787c6f3cf52cb4a404c0e349a0d1"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.9.5"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

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

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6f2675ef130a300a112286de91973805fcc5ffbc"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.91+0"

[[deps.Kanones]]
deps = ["AtticGreek", "BenchmarkTools", "CSV", "CitableBase", "CitableCorpus", "CitableObject", "CitableParserBuilder", "CitableText", "Compat", "DataFrames", "DelimitedFiles", "DocStringExtensions", "Documenter", "Downloads", "Glob", "HTTP", "Orthography", "PolytonicGreek", "Query", "SplitApplyCombine", "Test", "TestSetExtensions", "Unicode"]
git-tree-sha1 = "6884f62d66f9b2b279219925592df8b0a579e560"
uuid = "107500f9-53d4-4696-8485-0747242ad8bc"
version = "0.16.4"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "099e356f267354f46ba65087981a77da23a279b7"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.0"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

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

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "0a1b7c2863e44523180fdb3146534e265a91870b"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.23"

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
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

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

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9ff31d101d987eb9d66bd8b176ac7c277beccd09"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.20+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.Orthography]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "Compat", "DocStringExtensions", "Documenter", "OrderedCollections", "StatsBase", "Test", "TestSetExtensions", "TypedTables", "Unicode"]
git-tree-sha1 = "1577210e4841afc80338a4b6a8d9939410a4cdb1"
uuid = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
version = "0.21.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "a5aef8d4a6e8d81f171b2bd4be5265b01384c74c"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.10"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "f92e1315dadf8c46561fb9396e525f7200cdc227"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.5"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "3c5106dc6beba385fd1d37b9bf504271f8bfa916"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.38.13"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "b478a748be27bd2f2c73a7690da219d0844db305"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.51"

[[deps.PolytonicGreek]]
deps = ["Compat", "DocStringExtensions", "Documenter", "Orthography", "Test", "TestSetExtensions", "Unicode"]
git-tree-sha1 = "074c271af405e0885031efe0622b78c36840ad4a"
uuid = "72b824a7-2b4a-40fa-944c-ac4f345dc63a"
version = "0.18.2"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "259e206946c293698122f63e2b513a7c99a244e8"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "213579618ec1f42dea7dd637a42785a608b1ea9c"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.4"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

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

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "77d3c4726515dca71f6d80fbb5e251088defe305"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.18"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "ef28127915f4229c971eb43f3fc075dd3fe91880"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.2.0"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

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
git-tree-sha1 = "45a7769a04a3cf80da1c1c7c60caf932e6f4c9f7"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.6.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableShowUtils]]
deps = ["DataValues", "Dates", "JSON", "Markdown", "Test"]
git-tree-sha1 = "14c54e1e96431fb87f0d2f5983f090f1b9d06457"
uuid = "5e66a065-1f0a-5976-b372-e0b8c017ca10"
version = "0.2.5"

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
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TestSetExtensions]]
deps = ["DeepDiffs", "Distributed", "Test"]
git-tree-sha1 = "3a2919a78b04c29a1a57b05e1618e473162b15d0"
uuid = "98d24dd4-01ad-11ea-1b02-c9a08f80db04"
version = "2.0.0"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.TypedTables]]
deps = ["Adapt", "Dictionaries", "Indexing", "SplitApplyCombine", "Tables", "Unicode"]
git-tree-sha1 = "d911ae4e642cf7d56b1165d29ef0a96ba3444ca9"
uuid = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"
version = "1.4.3"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["ConstructionBase", "Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "ba4aa36b2d5c98d6ed1f149da916b3ba46527b2b"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.14.0"

    [deps.Unitful.extensions]
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "e2d817cc500e960fdbafcf988ac8436ba3208bfd"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.3"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "ed8d92d9774b077c53e1da50fd81a36af3744c1c"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─e871f548-3764-4c16-9a27-64fd1b603b86
# ╟─17e57a5f-12b2-4e47-8bd2-de5e0f2b5c5c
# ╟─e73845ec-f7f6-11ed-01a3-75bd5188678f
# ╟─5187fb8e-8186-435f-b2de-318a60b38264
# ╟─92a2622f-5c83-4341-ba8d-dc864dd3c556
# ╠═b5cbb1a9-ee3b-4236-af73-84fa9f278665
# ╟─e06efadb-4dc7-463e-aad5-e6e198c72db2
# ╠═66cef781-a849-4ff5-bc48-66d7dcd88c61
# ╠═6dce46e6-b25b-49c5-a8ba-03c3953356c2
# ╟─725bb091-aef0-471e-a36e-9bae7598e6a8
# ╟─188a3b26-90bd-4764-882b-cdc43757b991
# ╠═e5f799bf-ecc4-4ffa-a114-7391b98f8be6
# ╠═fdb04419-a763-498b-a28f-4e899b8bb5e2
# ╠═e41f7627-bf49-4844-a49d-51714c1ee91d
# ╠═8bc02373-164c-4b32-9cb8-6d41a37e2626
# ╟─ab586cf9-3cc0-456a-9ff1-c8650184d0fb
# ╠═cd4584d5-278e-4115-9723-ac3e171f49ee
# ╟─c84a16d7-ae9d-4e80-959f-5e20df34aed0
# ╟─8813b5a9-cc32-4ee7-9d39-02d92de8b37a
# ╠═8b4548b7-2565-4811-b9f0-eb234f6d26ac
# ╠═97f0937d-ab49-4918-8f1d-99d9990e7ff4
# ╠═1dada4ae-8737-465a-942a-5fc9df4be1c4
# ╠═5b3fbd77-d4e1-459b-9eec-a40d335d3c0e
# ╟─d030db85-f4a0-4729-b6d5-d1a3c1ea6057
# ╠═bd270d84-da87-4fe5-bf33-11a6f695f71f
# ╠═7bbc9d70-5a54-4508-a27b-e49c8ece039c
# ╟─50f7c7ce-c0d3-41de-906c-424371962547
# ╟─2a97632e-2e83-448a-96d9-d933408fb31b
# ╠═c378543b-5274-4d95-a758-d8961955f7f5
# ╟─dc373828-65cd-4585-a2c4-b9a12204df59
# ╠═85faea2d-6083-4551-bce1-ae07a3b6546b
# ╠═2c120b2c-15db-4834-af49-32a6d4971aba
# ╠═129c8993-113f-47a6-a31c-e4c3f3c87798
# ╟─47791d64-2517-4625-8402-c9d16a07ba3e
# ╟─3f42716a-4b5e-4983-b934-8892045eaf37
# ╠═17350592-8a0d-4db8-99a4-ae1f4a7dfba1
# ╠═4d3ca7ee-220c-430c-90c0-7d0827a7c974
# ╠═496e7221-f4c1-4088-a2f8-bf85b913ee55
# ╠═49ec57f7-507e-45bd-9862-f59935a2b949
# ╟─f804125e-2c78-4637-bea8-c816fadf4b4e
# ╠═b7e4eab6-a986-4614-bde8-becfe1baff58
# ╟─4855b2b6-1a4b-4ded-b9fd-70315d25aa70
# ╠═fc4dae2b-56f2-49c4-ae78-93229a5e4b44
# ╟─ab14c401-6b81-4f92-a76a-25fdfce303c4
# ╠═7f7167f5-b401-4535-b530-708a142fb35c
# ╠═cc58effb-d9a8-40ae-813f-dbda4eaa0caf
# ╠═ec1037e5-33db-46f5-b7a9-93e23450ca11
# ╟─cba2e310-f210-4edb-b3db-358829a6abde
# ╟─e19913c8-7c3c-440f-9395-3d9ce8d8e7a7
# ╟─fb273b04-0497-4277-9e3b-d31c4edf96cb
# ╟─92181982-74db-4c3e-adff-1f803f637d34
# ╟─f49cc7d6-e2e2-45c9-a30c-fa3871a1b349
# ╟─a982c017-bd1a-4141-bebf-7385190a2ad3
# ╟─621da80b-5cce-4f79-9cd9-90ddd76bdf61
# ╟─8a2bdbb7-7aad-45e7-afc6-d55007b7ea66
# ╟─babe0667-4ff7-4511-9a0b-40f2d84ed48a
# ╟─bc805623-c0e6-4ff6-90a1-dff0fede62e6
# ╟─91ed541a-05b5-400c-94cd-0544b11dcc06
# ╟─17f35d7a-ebb7-45d4-877e-6665e9e3290e
# ╟─be561d1d-0cf6-4c89-ab15-4e733e2b712b
# ╟─551958f8-3284-487d-a25b-01a36b1c1013
# ╟─d64fe501-7e29-4e03-ad69-eb78891e4227
# ╟─5aa2d5f1-8095-472b-b083-d76ea5c75052
# ╟─597f3d08-e464-4cf1-9978-21e07bac0799
# ╟─544ae06d-4266-4681-aaac-abe791658410
# ╟─ec99f80f-56c8-4085-a487-8970b4325247
# ╟─9875fcdd-facf-4204-b628-5b0574760bb7
# ╠═2a570046-4851-4cd3-aa90-3020667359f1
# ╟─d5934aed-1990-45b5-a1b6-4cdfe0bde7da
# ╟─7556409b-ee74-4f9f-9e02-d927ca1ae157
# ╟─aa56b89b-74a7-44d2-83bb-717235596664
# ╠═5407c0cd-e30c-4652-854a-11a27687b871
# ╟─24d33c4d-e59d-49c8-8fc8-459e0637f25e
# ╟─96e13fbe-fe1d-4c12-b535-2a39926189b7
# ╟─0f14ab53-2da6-4287-8380-25fb428d2c4f
# ╟─d68c208c-a234-475d-8702-55691ebf096a
# ╟─dc7bee7b-b924-4ad9-8230-485f9c228bca
# ╟─490e9116-fa5e-4f0f-ae4f-e15b3c2c3e87
# ╟─363d38e6-2116-49a3-94f0-721c941180fc
# ╟─7b9429d1-932d-4dae-98a3-4101bfdbe7ef
# ╟─a95e1a70-fda3-46a3-919e-7149fb30655c
# ╟─fb413fd7-557e-47fc-bbf0-f6f6440b293c
# ╟─efa8ae03-b471-4d55-a842-ccbb09d5ff3a
# ╠═fd6a733f-0f40-42a4-9482-6bb66659d070
# ╟─b4bf2388-429e-44f7-b918-5bcadb1a523a
# ╠═5719d0da-9f69-4305-a3e1-ca3f0ab4c9a8
# ╠═aeb8fbb5-dc44-45bb-a90a-7e0710f25f6e
# ╠═7287dc19-be34-4cb3-bc0e-d838f3565f8b
# ╠═b04fa238-dfcb-446e-b731-609dd05f65e9
# ╠═c273ab1f-437a-4b76-8b31-aff484f00a14
# ╠═6a295c87-e06b-4129-8710-5227ca02167f
# ╠═0c1f1e66-215f-4db2-bddb-41df060e978e
# ╠═9830bb9d-90a4-44e9-9b70-ab9d5dfd0aab
# ╠═32bd7000-28aa-46dc-a49d-87d6fe21b80f
# ╟─7dc70a52-bf32-4aea-9705-a251ae08c632
# ╠═27521a1c-c188-42aa-9c0d-384bf65ff15b
# ╠═8d6da432-3110-41a6-aeb1-7a43c7e54d59
# ╠═01605233-80e4-4d55-83a7-e0937db35630
# ╟─af2e70a3-a693-488e-b6a9-369a2ec30d41
# ╠═ce804e31-3e0e-4922-8a2b-86d4355d47cd
# ╠═02f60db8-9a87-4178-968a-54c1bc7931c6
# ╠═c7e8aaa2-a8ff-4268-a2f8-6eb77230b19a
# ╠═4506c7b9-1734-4c40-83df-67cd808656ee
# ╠═7c38ea51-c71c-4b78-8c36-a01d3c24c323
# ╠═06c835b0-ba8f-42e8-a967-c1585db65155
# ╠═53ab67da-3239-4c1b-bdab-a9745450f79e
# ╠═5d1e7f02-1fbe-455c-bffb-ef0fe6fcff25
# ╠═b788cb5a-04f4-4d39-9ce8-1a723cc313bb
# ╠═e45776ac-6db2-4da4-aa05-7e98c4da22be
# ╠═63b234f7-2559-47b2-b15f-1046d6a5fa0a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

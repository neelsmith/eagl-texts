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

# ╔═╡ 4fa2c004-746d-448b-a163-fa6c396f1003
# ╠═╡ show_logs = false
begin
	using PlutoUI
	using GreekSyntax
	using LatinSyntax
	using LatinOrthography, PolytonicGreek
	using Downloads
	using CitableText
	using Dates
	md"""*Unhide this cell to see environment configuration.*"""
end

# ╔═╡ 7e0a834e-ab93-4320-9119-cbd04495dc9b
nbversion = "0.1.1";

# ╔═╡ 5ede902b-be5d-479a-9816-209b1adb7ce8
md"""**Notebook version $(nbversion)**  *See version history* $(@bind history CheckBox())"""

# ╔═╡ 31d7e8b4-e4b3-450e-9401-f4256dfe8d53
if history
	md"""
- **0.1.1**:  correct label in footer text
- **0.1.0**: initial release	
	"""
end

# ╔═╡ 93b49926-9104-11ed-19c6-df715bde3818
md"""# Build a web site for syntactically annotated texts

"""

# ╔═╡ 24abee74-963f-465a-b889-b88ecddca4f3
begin
	defaultoutdir = joinpath(dirname(pwd()),"scratchpad")
	md"""*Output directory* $(@bind  outputdir confirm(TextField(80; default = defaultoutdir)))
	"""
end

# ╔═╡ 3d38cad6-d10e-4eac-b33c-1cb15ac8f198
md"""
*Label for text* $(@bind textlabel
	TextField(80; placeholder = 
	"Lysias, Oration 1"))
"""

# ╔═╡ 690f1218-fa0f-4410-9ec2-6d4846189111
begin
	orthomenu = ["litgreek" => "Greek: literary orthography", "latin23" => "Latin: 23-character alphabet","latin24" => "Latin: 24-character alphabet", "latin25" => "Latin: 25-character alphabet"]
	
md"""
*Language and orthography of your corpus*: $(@bind ortho Select(orthomenu))
"""
end

# ╔═╡ 6f8812cd-5bcb-4db7-a431-bc7402b0d187
md"""*Load annotations from* $(@bind srctype Select(["", "url", "file"]))"""

# ╔═╡ 45bb7468-adfe-41c9-9ab9-d3c597e380f8
if srctype == "url"
	md"""*Source URL*: $(@bind url TextField(80; default = 
	"https://raw.githubusercontent.com/neelsmith/eagl-texts/main/annotations/Lysias1_annotations.cex"))
	"""
elseif srctype == "file"
	
	defaultdir = joinpath(dirname(pwd()), "annotations")
	md"""*Source directory*: $(@bind basedir TextField(80; default = defaultdir))"""
end

# ╔═╡ 2fd228b9-1a78-49c9-862e-3e7e11a3b2e0
if srctype == "file"
	
	cexfiles = filter(readdir(basedir)) do fname
		endswith(fname, ".cex")
	end
	datasets = [""]
	for f in cexfiles
		push!(datasets,f)
	end
	md"""*Choose a file* $(@bind dataset Select(datasets))"""
end

# ╔═╡ ca9cc614-b1c3-4b31-a263-e80a09a978a0
md"""*All settings correct: Go!* $(@bind runit CheckBox())"""

# ╔═╡ 60c5db9e-5185-42e1-a5cd-49ec516f07f3
html"""
<br/><br/><br/>
<hr/>
"""

# ╔═╡ d8df443c-44b0-4243-ae40-9ad1a684281f
md"> Check settings and load data"

# ╔═╡ c1274e8d-2bb5-4979-b46c-20b8993cb915
	csspage = GreekSyntax.defaultcss() * "blockquote.guide {\n background-color: #f2f2f2;}"


# ╔═╡ 5f0898f7-bc7d-479c-a304-c84ded1a9a90
if runit
			
	open(joinpath(outputdir, "syntax.css"), "w") do io
		#write(io, GreekSyntax.defaultcss() * "\n")
		write(io, csspage)
	end

	open(joinpath(outputdir, "page.css"), "w") do io
		write(io, GreekSyntax.pagecss())
		
	end


	md"""*Wrote CSS files to $(outputdir).*"""	
else
	md"""*Waiting to write CSS files...*"""
end


# ╔═╡ 792a44c9-093d-431d-9277-a77163433570
"""Make directory for syntax diagrams."""
function mkpngdir(outdir)
	imgdir = if startswith(outdir, "/")
		joinpath(outdir, "pngs")
	else
		joinpath(pwd(), outdir, "pngs")
	end
	mkpath(imgdir)
end

# ╔═╡ 3e11aa5f-f020-4229-95c6-3f64145738ed
pngdir = mkpngdir(outputdir)

# ╔═╡ cb126faf-7678-4087-999b-349e03ab929f
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

# ╔═╡ 9447b4e0-e2e3-4c5f-9958-ede1549d0027
(sentences, groups, tokens) = if srctype == "file"
	src = joinpath(basedir, dataset) |> readlines
	readdelimited(src, orthography())
elseif srctype == "url"
	src = Downloads.download(url) |> readlines
	readdelimited(src, orthography())
else
	(nothing, nothing, nothing)
end

# ╔═╡ 49f787aa-63ec-4883-ac98-49310bdad7d8
"True if all settings are OK"
function settingsok()
	if ! isdir(outputdir) || isempty(textlabel) || isnothing(sentences)
		false
	else
		true
	end
end

# ╔═╡ d0e510b8-edab-4249-9609-fd082225def2
md"""> Functions composing HTML"""

# ╔═╡ 903326cf-c9eb-45fd-b6a9-d131bebab02a

"""Wrap page title and body content in HTML elements,
and include link to syntax.css.
"""
function wrap_page(title, content)
    """<html>
    <head>
    <title>$(title)</title>
    <link rel=\"stylesheet\" href=\"syntax.css\">
    <link rel=\"stylesheet\" href=\"page.css\">
    </head>
    <body>$(content)</body>
    </html>"""
end

# ╔═╡ 3faa116c-df96-4110-bf43-daef4b4ccdb1

"""Compose navigation links for page with index `idx`.
"""
function navlinks(idx::Int, sentencelist::Vector{SentenceAnnotation})
    nxt = ""
    prev = ""
    if idx == 1
        nxtpsg = sentences[idx + 1].range |> passagecomponent
        nxt = "<a href=\"./$(nxtpsg).html\">$(nxtpsg)</a>"
    
        prev = ""
        
    elseif idx == length(sentences)
        nxt = ""

        prevpsg = sentences[idx - 1].range |> passagecomponent
        prev = "<a href=\"./$(prevpsg).html\">$(prevpsg)</a>"

    else
        nxtpsg = sentences[idx + 1].range |> passagecomponent
        nxt = "<a href=\"./$(nxtpsg).html\">$(nxtpsg)</a>"

        prevpsg = sentences[idx - 1].range |> passagecomponent
        prev = "<a href=\"./$(prevpsg).html\">$(prevpsg)</a>"
    end
nav = "<p class=\"nav\">$(prev) | $(nxt)</p>"
end

# ╔═╡ 5fff3d5c-ff81-444f-b8f1-4c12ded8e25b

"""Compose HMTL page for sentence number `idx`.
"""
function webpage(idx, sentences, groups, tokens, versionid)
    sentence = sentences[idx]
    @info("$(idx). Writing page for $(sentence.sequence) == $(sentence.range)...")

    # Compose parts of page content:

    #  Heading and subheading
    psg = passagecomponent(sentence.range)
    pagetitle = "$(textlabel),  $(psg)"
    hdg = "<h1>$(pagetitle)</h1>"
    subhead = "<p>Sentence $(sentence.sequence)</p>"
	guide = """<blockquote class="guide"><p>Indentation shows level of subordination; <span class="verb">verbs</span> are boxed, <span class="subject">subjects</span> marked with thick underline, and <span class="object">objects</span> with wavy underline.</p></blockquote>"""
    # navigation links
    nav = navlinks(idx, sentences)

    # Continuous text view:
    plaintext = htmltext(sentence.range, sentences, tokens, sov = false, vucolor = false, syntaxtips = true)

    txtdisplay = "<div class=\"passage\">" * htmltext_indented(sentence, groups, tokens, sov = true, vucolor = false) * "</div>"

    
    m = now() |> monthname
    d = now() |> day
    y = now() |> year
    footer = "<footer>Site created by Pluto notebook <code>simplepage.jl</code>, version $(versionid), on $(m) $(d), $(y).</footer>"

    # String all the parts together!
    htmlparts = [hdg, nav, subhead, plaintext, guide, txtdisplay, footer]
    bodycontent = join(htmlparts, "\n\n")
    wrap_page(pagetitle, bodycontent)
end


# ╔═╡ 2f4f4048-3998-4743-aa5c-641e82e23c22

"""Write HTML page for sentence `num` to HTML file.
"""
function publishsentence(num, sentences, groups, tokens, versionid; pngdir = pngdir, outdir = outputdir)
    idx = findfirst(s -> s.sequence == num, sentences)
    sentence = sentences[idx]
    psg = passagecomponent(sentence.range)
    pagehtml = webpage(idx, sentences, groups, tokens, versionid)
    open(joinpath(outputdir, "$(psg).html"), "w") do io
        write(io, pagehtml)
    end
    @info("Done: wrote HTML page for sentence $(num) in $(outputdir) as $(psg).html.")
end

# ╔═╡ 94054ecf-5089-4f36-a94d-62de91ff022a
"""Write HTML pages for all sentences in `sentences`.
"""
function publishall(sentences, groups, tokens, versionid)
    for sentence in sentences
		publishsentence(sentence.sequence, sentences, groups, tokens, versionid)   
    end
    @info("Done: wrote $(length(sentences)) HTML pages linked to accompanying PNG file in $(outputdir). (Now in $(pwd()))")
end

# ╔═╡ f6337759-7c80-43db-b050-a7895e201542
if ! runit 
else
	if settingsok()		
		publishall(sentences, groups, tokens, nbversion)
		md"""**Done**: wrote **$(length(sentences))** HTML pages linked to accompanying PNG file in *$(outputdir)*."""
	else
		md"""*Please complete settings.*"""
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CitableText = "41e66566-473b-49d4-85b7-da83b66615d8"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
GreekSyntax = "5497687e-e4d1-4cb6-b14f-a6a808518ccd"
LatinOrthography = "1e3032c9-fa1e-4efb-a2df-a06f238f6146"
LatinSyntax = "48187f9f-78ff-4060-b31e-d855612fbaec"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PolytonicGreek = "72b824a7-2b4a-40fa-944c-ac4f345dc63a"

[compat]
CitableText = "~0.15.2"
GreekSyntax = "~0.13.8"
LatinOrthography = "~0.6.0"
LatinSyntax = "~0.3.2"
PlutoUI = "~0.7.49"
PolytonicGreek = "~0.18.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.1"
manifest_format = "2.0"
project_hash = "684c789085c335d5238467d868a7e236be23c37a"

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
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "SnoopPrecompile", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "c700cce799b51c9045473de751e9319bdd1c6e94"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.9"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

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
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DeepDiffs]]
git-tree-sha1 = "9824894295b62a6a4ab6adf1c7bf337b3a9ca34c"
uuid = "ab62b9b5-e342-54a8-a765-a90f495de1a6"
version = "1.2.0"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "e82c3c97b5b4ec111f3c1b55228cebc7510525a2"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.25"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

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
git-tree-sha1 = "6030186b00a38e9d0434518627426570aac2ef95"
uuid = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
version = "0.27.23"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

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

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GreekSyntax]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "Compat", "DocStringExtensions", "Documenter", "Kroki", "Orthography", "PolytonicGreek", "StringDistances", "Test", "TestSetExtensions"]
git-tree-sha1 = "4f044cab8a69e2e0d1370e52dc130bc732e1174b"
uuid = "5497687e-e4d1-4cb6-b14f-a6a808518ccd"
version = "0.13.8"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "eb5aa5e3b500e191763d35198f859e4b40fff4a6"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.7.3"

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
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "0cf92ec945125946352f3d46c96976ab972bde6f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.3.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.Kroki]]
deps = ["Base64", "CodecZlib", "DocStringExtensions", "HTTP", "JSON", "Markdown", "Reexport"]
git-tree-sha1 = "a3235f9ff60923658084df500cdbc0442ced3274"
uuid = "b3565e16-c1f2-4fe9-b4ab-221c88942068"
version = "0.2.0"

[[deps.LatinOrthography]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "DocStringExtensions", "Documenter", "Orthography", "Test"]
git-tree-sha1 = "d1c33e2385125a1dd2298a3863b7f23905a35e79"
uuid = "1e3032c9-fa1e-4efb-a2df-a06f238f6146"
version = "0.6.0"

[[deps.LatinSyntax]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "DocStringExtensions", "Documenter", "GreekSyntax", "LatinOrthography", "Orthography", "StringDistances", "Test", "TestSetExtensions"]
git-tree-sha1 = "802d0c45b6630e15bd7faa28233098cc88368cb6"
uuid = "48187f9f-78ff-4060-b31e-d855612fbaec"
version = "0.3.2"

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
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "946607f84feb96220f480e0422d3484c49c00239"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.19"

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
git-tree-sha1 = "6503b77492fd7fcb9379bf73cd31035670e3c509"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Orthography]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "Compat", "DocStringExtensions", "Documenter", "OrderedCollections", "StatsBase", "Test", "TestSetExtensions", "TypedTables", "Unicode"]
git-tree-sha1 = "0aa5a500c45a258d33788403f34e276d92db36f3"
uuid = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
version = "0.18.2"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "8175fc2b118a3755113c8e68084dc1a9e63c61ee"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.3"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eadad7b14cf046de6eb41f13c9275e5aa2711ab6"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.49"

[[deps.PolytonicGreek]]
deps = ["Compat", "DocStringExtensions", "Documenter", "Orthography", "Test", "TestSetExtensions", "Unicode"]
git-tree-sha1 = "00f72906132b912e3247ffa6ddb60031693d4305"
uuid = "72b824a7-2b4a-40fa-944c-ac4f345dc63a"
version = "0.18.0"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

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

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "c02bd3c9c3fc8463d3591a62a378f90d2d8ab0f3"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.17"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

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
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StringDistances]]
deps = ["Distances", "StatsAPI"]
git-tree-sha1 = "ceeef74797d961aee825aabf71446d6aba898acb"
uuid = "88034a9c-02f8-509d-84a9-84ec65e18404"
version = "0.11.2"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

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
deps = ["Random", "Test"]
git-tree-sha1 = "94f38103c984f89cf77c402f2a68dbd870f8165f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.11"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.TypedTables]]
deps = ["Adapt", "Dictionaries", "Indexing", "SplitApplyCombine", "Tables", "Unicode"]
git-tree-sha1 = "ec72e7a68a6ffdc507b751714ff3e84e09135d9e"
uuid = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"
version = "1.4.1"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

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
# ╟─7e0a834e-ab93-4320-9119-cbd04495dc9b
# ╟─4fa2c004-746d-448b-a163-fa6c396f1003
# ╟─5ede902b-be5d-479a-9816-209b1adb7ce8
# ╟─31d7e8b4-e4b3-450e-9401-f4256dfe8d53
# ╟─93b49926-9104-11ed-19c6-df715bde3818
# ╟─24abee74-963f-465a-b889-b88ecddca4f3
# ╟─3d38cad6-d10e-4eac-b33c-1cb15ac8f198
# ╟─690f1218-fa0f-4410-9ec2-6d4846189111
# ╟─6f8812cd-5bcb-4db7-a431-bc7402b0d187
# ╟─45bb7468-adfe-41c9-9ab9-d3c597e380f8
# ╟─2fd228b9-1a78-49c9-862e-3e7e11a3b2e0
# ╟─ca9cc614-b1c3-4b31-a263-e80a09a978a0
# ╟─f6337759-7c80-43db-b050-a7895e201542
# ╟─60c5db9e-5185-42e1-a5cd-49ec516f07f3
# ╟─d8df443c-44b0-4243-ae40-9ad1a684281f
# ╟─9447b4e0-e2e3-4c5f-9958-ede1549d0027
# ╟─3e11aa5f-f020-4229-95c6-3f64145738ed
# ╟─5f0898f7-bc7d-479c-a304-c84ded1a9a90
# ╟─c1274e8d-2bb5-4979-b46c-20b8993cb915
# ╟─49f787aa-63ec-4883-ac98-49310bdad7d8
# ╟─792a44c9-093d-431d-9277-a77163433570
# ╟─cb126faf-7678-4087-999b-349e03ab929f
# ╟─d0e510b8-edab-4249-9609-fd082225def2
# ╠═94054ecf-5089-4f36-a94d-62de91ff022a
# ╟─2f4f4048-3998-4743-aa5c-641e82e23c22
# ╠═5fff3d5c-ff81-444f-b8f1-4c12ded8e25b
# ╟─903326cf-c9eb-45fd-b6a9-d131bebab02a
# ╟─3faa116c-df96-4110-bf43-daef4b4ccdb1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

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

# ╔═╡ e2562890-53f7-48c4-bf6e-67cb40c3e8b8
# ╠═╡ show_logs = false
begin 
	using Pkg
	Pkg.add("Downloads")
	Pkg.add("PlutoUI")
	Pkg.add(url = "https://github.com/neelsmith/Kanones.jl")
	using Downloads
	using Kanones
	using PlutoUI
	md"""*Unhide this cell to see Julia environment*."""
end

# ╔═╡ aee80418-901d-4fc9-8448-ba7516cdaeb9
md"""
!!! note "Hey"
"""

# ╔═╡ c5b0d8da-abdd-4843-a7b4-2eb5cef095cb
md"""*Build parser* $(@bind doit CheckBox()) *Term to parse* $(@bind token confirm(TextField(placeholder="δουλεύω")))"""

# ╔═╡ 7b72057d-95d7-4da6-a5ba-7fb7b39fb1e1
html"""
<br/><br/><br/><br/>
<br/><br/><br/><br/>
"""

# ╔═╡ a9777b74-b0ab-4cdb-b4df-a307f32008b3
md"""> **Download data and instantiate parser**"""

# ╔═╡ 0eec4a38-9093-11ee-3acc-bd9760140462
url = "http://shot.holycross.edu/morphology/comprehensive-current.csv"

# ╔═╡ 868a2091-b650-4cbe-ad29-8fd270ae9bf4
"""Download current version of comprehensive parser.
"""
function getparserdata(u)
	f = Downloads.download(u)
	data = readlines(f)
	rm(f)
	# omit header line:
	data[2:end]
end

# ╔═╡ 9673d718-9469-400b-98b1-24cfa8fe078e
parserdata = doit ? getparserdata(url) : []

# ╔═╡ fd7c8666-316e-406a-8410-a60973e798d9
parser = isempty(parserdata) ? nothing : StringParser(parserdata)

# ╔═╡ 7bdbb152-553e-4de3-99d9-81ed042ac8b1
if isnothing(parser)  
	nothing
elseif isempty(token)
	md"""*No token entered*"""
else
	parses = parsetoken(token, parser)
	#map(p -> label(p), parses)
		
end

# ╔═╡ bc4d1206-8b48-4d15-80f9-423d66071188
"""Download current LSJ parser data and build a DataFrameParser."""
function lsjparser(u)
	f = Downloads.download(u)
	data = read(f)
	rm(f)
	commafied = replace(f, "|" => ",")
	tempdatafile = tempname()
	open(tempdatafile,"w") do io
		write(tempdatafile, commafied)
	end
	parser = dfParser(tempdatafile)
	rm(tempdatafile)
	parser
end

# ╔═╡ 45edfc8a-19a2-4f52-8499-5efff5e80e40
lsjp = lsjparser(url)

# ╔═╡ bc8bc96e-8942-4bdd-a5ee-7cae5fb32ea3
parsetoken("δουλεύω", lsjp)


# ╔═╡ Cell order:
# ╟─e2562890-53f7-48c4-bf6e-67cb40c3e8b8
# ╟─aee80418-901d-4fc9-8448-ba7516cdaeb9
# ╟─c5b0d8da-abdd-4843-a7b4-2eb5cef095cb
# ╟─7bdbb152-553e-4de3-99d9-81ed042ac8b1
# ╟─7b72057d-95d7-4da6-a5ba-7fb7b39fb1e1
# ╟─a9777b74-b0ab-4cdb-b4df-a307f32008b3
# ╠═fd7c8666-316e-406a-8410-a60973e798d9
# ╠═9673d718-9469-400b-98b1-24cfa8fe078e
# ╟─0eec4a38-9093-11ee-3acc-bd9760140462
# ╟─868a2091-b650-4cbe-ad29-8fd270ae9bf4
# ╠═bc4d1206-8b48-4d15-80f9-423d66071188
# ╠═45edfc8a-19a2-4f52-8499-5efff5e80e40
# ╠═bc8bc96e-8942-4bdd-a5ee-7cae5fb32ea3

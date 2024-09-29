module TexAssistant

    import ArgParse
    import TOML
    import BibTeX

    include("utils.jl")
    include("regexs.jl")
    include("split_comment.jl")
    include("expand_input.jl")
    include("extract_sections_to_files.jl")
    include("settings.jl")
    include("extractors.jl")
    include("tex_match.jl")
    include("import_ref.jl")

    function __init__()
        _fill_regexs!()
    end

end
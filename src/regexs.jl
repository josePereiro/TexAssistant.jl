## ------------------------------------------------------------------------------------------------------------------
const REGEXS = Dict{Symbol, Regex}()


function _fill_regexs!()

    ## --------------------------------------------------------
    _blank = "\\t\\s"
    REGEXS[:TEX_COMMENT_REGEX] = Regex("^(?<uncomment>[^%]*)(?<comment>%.*\$)")

    ## --------------------------------------------------------
    # ASS SECTION
    _head = "%%"
    _blank = "\\t\\s"
    _fill = "-"
    texass_cmd_reg_str(reg_str_to_insert) = string(
        "^[$(_blank)]*", 
        "$(_head)[$(_blank)]*", 
            "TexAssistant:", "[$(_blank)]+", 
            reg_str_to_insert,
            "[$(_blank)]*", 
        "[$(_blank)$(_fill)]*\$"
    )
    # Ex: "   %% TexAssistant: section{Section Name} ----------- "
    reg_str = texass_cmd_reg_str(string("section{", "(?<label>.*)", "}"))
    REGEXS[:TEXASS_SECTION_REGEX] = Regex(reg_str)
    # Ex: "   %% TexAssistant: end{label} ----------- "
    reg_str = texass_cmd_reg_str("end{(?<label>.*)}")
    REGEXS[:TEXASS_END_REGEX] = Regex(reg_str)

    ## --------------------------------------------------------
    # INPUT_FILE_REGEX 
    # Ex: \input{sub.tex}
    _blank = "\\t\\s"
    _back = "\\\\"
    REGEXS[:TEX_INPUT_CMD_REGEX] = Regex("^[$(_blank)]*$(_back)input{(?<label>.*?)}$(_back)*\$")

    ## --------------------------------------------------------
    # TEX SECTIONS 
    # Ex: \section{Cool section}
    # Ex: \subsection{Cool section}
    # Ex: \subsubsection{Cool section}
    _blank = "\\t\\s"
    _back = "\\\\"
    REGEXS[:TEX_SECTION_CMD_REGEX] = Regex("^[$(_blank)]*$(_back)section{(?<label>.*?)}.*\$")
    REGEXS[:TEX_SUBSECTION_CMD_REGEX] = Regex("^[$(_blank)]*$(_back)subsection{(?<label>.*?)}.*\$")
    REGEXS[:TEX_SUBSUBSECTION_CMD_REGEX] = Regex("^[$(_blank)]*$(_back)subsubsection{(?<label>.*?)}.*\$")

    ## --------------------------------------------------------
    # TEX BEGIN
    # Ex: \begin{document}
    # Ex: \end{document}
    _blank = "\\t\\s"
    _brakets = "(?:\\[(?<arg>.*)\\])"
    _back = "\\\\"
    REGEXS[:TEX_END_REGEX] = Regex("^[$(_blank)]*$(_back)end{(?<label>.*)}$(_back)*\$")
    REGEXS[:TEX_BEGIN_REGEX] = Regex("^[$(_blank)]*$(_back)begin{(?<label>.*)}$(_back)*$(_brakets)?$(_back)*\$")

    ## --------------------------------------------------------
    # INDENT
    _blank = "\\t\\s"
    REGEXS[:INDENT] = Regex("^(?<indent>[$(_blank)]*)?.*")

end
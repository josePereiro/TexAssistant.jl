## --------------------------------------------------------------------------
function extract_input_file(line)
        
    # extract uncomment
    uncomment, _ = split_comment(line)

    reg = REGEXS[:TEX_INPUT_CMD_REGEX]
    inputm = match(reg, uncomment)
    return isnothing(inputm) ? "" : inputm[:label]
end

## --------------------------------------------------------------------------
# tex section
function _extract_tex_label(line, secregex)
        
    # extract uncomment
    uncomment, _ = split_comment(line)

    match_ = match(secregex, uncomment)
    return isnothing(match_) ? "" : match_[:label]
end

extract_tex_section_label(line) = _extract_tex_label(line, REGEXS[:TEX_SECTION_CMD_REGEX])
extract_tex_subsection_label(line) = _extract_tex_label(line, REGEXS[:TEX_SUBSECTION_CMD_REGEX])
extract_tex_subsubsection_label(line) = _extract_tex_label(line, REGEXS[:TEX_SUBSUBSECTION_CMD_REGEX])

extract_tex_begin_label(line) = _extract_tex_label(line, REGEXS[:TEX_BEGIN_REGEX])
extract_tex_end_label(line) = _extract_tex_label(line, REGEXS[:TEX_END_REGEX])


## --------------------------------------------------------------------------
# texass
function _extract_texass_label(line, reg)
    match_ = match(reg, line)
    return isnothing(match_) ? "" : match_[:label]
end
extract_texass_sec_name(line) = _extract_texass_label(line, REGEXS[:TEXASS_SECTION_REGEX])
extract_texass_end_label(line) = _extract_texass_label(line, REGEXS[:TEXASS_END_REGEX])

## --------------------------------------------------------------------------
# utils
function extract_indent(line)
    match_ = match(REGEXS[:INDENT], line)
    return isnothing(match_) ? "" : match_[:indent]
end
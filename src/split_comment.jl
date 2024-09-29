function split_comment(line)
    reg = REGEXS[:TEX_COMMENT_REGEX]
    cmtm = match(reg, line)
    return isnothing(cmtm) ? 
        (;uncomment = line, comment = "") : 
        (;uncomment = cmtm[:uncomment], comment = cmtm[:comment])
end
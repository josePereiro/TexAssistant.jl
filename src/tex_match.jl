function match_begin(line)
    reg = REGEXS[:TEX_BEGIN_REGEX]
    return match(reg, line)
end

function match_end(line)
    reg = REGEXS[:TEX_END_REGEX]
    return match(reg, line)
end
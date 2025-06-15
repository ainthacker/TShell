 Universal Auto-Completion Plugin
# Herhangi bir komut için --help ve man sayfalarından otomatik tamamlama

# Komutun parametrelerini ve açıklamalarını al
_get_command_help() {
    local cmd=$1
    local help_text=""
    
    # Önce --help dene
    if $cmd --help &>/dev/null; then
        help_text=$($cmd --help 2>/dev/null)
    elif $cmd -h &>/dev/null; then
        help_text=$($cmd -h 2>/dev/null)
    else
        # Hata çıktısından da bilgi al
        help_text=$($cmd 2>&1 | head -30)
    fi
    
    # Parametreleri ve açıklamalarını çıkar
    echo "$help_text" | awk '
    /^[[:space:]]*-[[:alnum:]]/ || /^[[:space:]]*--[[:alnum:]-]+/ {
        gsub(/^[[:space:]]+/, "")
        if (match($0, /^(-{1,2}[[:alnum:]-]+)/)) {
            param = substr($0, RSTART, RLENGTH)
            desc  = substr($0, RLENGTH + 1)
            gsub(/^[[:space:],:]+/, "", desc)
            gsub(/[[:space:]]+$/, "", desc)
            if (length(desc) > 60) {
                desc = substr(desc, 1, 60) "..."
            }
            if (desc != "") print param ":" desc; else print param
        }
    }'
}

# Önbellek sistemi
declare -A _help_cache

_get_cached_help() {
    local cmd=$1
    local cache_key=$(basename "$cmd")
    if [ -z "${_help_cache[$cache_key]}" ]; then
        _help_cache[$cache_key]=$(_get_command_help "$cmd")
    fi
    echo "${_help_cache[$cache_key]}"
}

# Ana tamamlama fonksiyonu
_universal_completion() {
    local cmd="${words[1]}"
    local -a completions
    if ! command -v "$cmd" &>/dev/null; then return 1; fi
    local help_info=$(_get_cached_help "$cmd")
    while IFS= read -r line; do
        [[ -n "$line" ]] && completions+=("$line")
    done <<< "$help_info"
    case "${words[CURRENT-1]}" in
        -f|--file|-o|--output|-c|--config) _files; return 0;;
        -d|--dir|--directory) _directories; return 0;;
        -p|--port) _values 'ports' '80:HTTP' '443:HTTPS' '22:SSH' '21:FTP'; return 0;;
        *) [[ ${#completions[@]} -gt 0 ]] && _describe 'options' completions; return 0;;
    esac
}

# ZSH completion sistemi
autoload -Uz compinit
compinit

# Varsayılan tamamlama olarak ayarla
compdef _universal_completion -default-

# Prompt ayarları - Parrot OS stili
autoload -U colors && colors
if [[ $EUID -ne 0 ]]; then
    # Normal kullanıcı prompt'u - iki satırlı gerçek newline
    PROMPT=$'┌─[%F{green}%n@%m%f]─[%F{blue}%~%f]
└──╼ %F{cyan}$%f '
else
    PROMPT=$'┌─[%F{red}%n@%m%f]─[%F{blue}%~%f]
└──╼ %F{red}#%f '
fi

# Test fonksiyonu
test_help() {
    local cmd=$1
    echo "=== $cmd parametreleri ==="
    _get_command_help "$cmd"
}

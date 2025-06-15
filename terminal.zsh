# Universal Auto-Completion Plugin
# Herhangi bir komut için --help ve man sayfalarından otomatik tamamlama

# Komutun tam yardım bilgilerini al (parsing yapmadan)
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
    
    # Tüm yardım metnini olduğu gibi döndür
    echo "$help_text"
}

# Önbellek sistemi
declare -A _help_cache
declare -A _help_shown

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
    if ! command -v "$cmd" &>/dev/null; then return 1; fi
    
    case "${words[CURRENT-1]}" in
        -f|--file|-o|--output|-c|--config) _files; return 0;;
        -d|--dir|--directory) _directories; return 0;;
        -p|--port) _values 'ports' '80:HTTP' '443:HTTPS' '22:SSH' '21:FTP'; return 0;;
        *) 
            # Help bilgisini sadece bir kez göster
            local help_key="${cmd}_${BUFFER}"
            if [[ -z "${_help_shown[$help_key]}" ]]; then
                local help_info=$(_get_cached_help "$cmd")
                if [[ -n "$help_info" ]]; then
                    # Clear screen üst kısmını temizle ve help'i göster
                    clear
                    printf "\033[1;34m=== %s Help Information ===\033[0m\n" "$cmd"
                    printf "%s\n" "$help_info"  
                    printf "\033[1;34m========================\033[0m\n"
                    printf "\033[1;32mComplete the command using the information above:\033[0m\n"
                    # Orijinal prompt'u tekrar göster
                    printf "┌─[%s@%s]─[%s]\n" "$USER" "$(hostname)" "$(pwd | sed "s|$HOME|~|")"
                    printf "└──╼ \033[0;36m$\033[0m %s" "$BUFFER"
                    
                    # Bu komut için help gösterildi olarak işaretle
                    _help_shown[$help_key]=1
                    
                    # Completion'ı başarısız olarak işaretle
                    return 1
                fi
            fi
            
            # Normal completion için boş dön
            return 1;;
    esac
}

# ZSH completion sistemi
autoload -Uz compinit
compinit

# Universal completion'ı tüm komutlar için otomatik olarak uygula
compdef _universal_completion -default-

# Tüm executable dosyalar için otomatik olarak uygula  
_compdef_all() {
    for cmd in $(compgen -c); do
        compdef _universal_completion "$cmd" 2>/dev/null
    done
}
_compdef_all

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

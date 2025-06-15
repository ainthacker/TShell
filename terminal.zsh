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
    
    # Komut değiştiğinde help cache'i temizle
    if [[ "$cmd" != "${_last_cmd:-}" ]]; then
        _help_shown=()
        _last_cmd="$cmd"
    fi
    
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
                    # Help bilgisini göster (geçmişi silmeden)
                    printf "\n\033[1;34m=== %s Help Information ===\033[0m\n" "$cmd"
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

# File completion widget for Shift+TAB  
_shift_tab_completion() {
    # Mevcut buffer'dan son kelimeyi al
    local words=(${(z)BUFFER})
    local current_word="${words[-1]}"
    
    # Eğer boşlukla bitiyorsa, yeni kelime başlıyoruz
    if [[ $BUFFER[-1] == ' ' ]]; then
        current_word=""
    fi
    
    # File pattern oluştur
    local pattern="${current_word}*"
    local matches=(${~pattern})
    
    if [[ ${#matches[@]} -eq 1 && -e "${matches[1]}" ]]; then
        # Tek match var, tamamla
        local match="${matches[1]}"
        
        # Boşluk varsa quote et (en yaygın durum)
        if [[ $match == *\ * ]]; then
            # Double quote kullan - daha güvenli
            match="\"${match//\"/\\\"}\""
        fi
        
        if [[ $BUFFER[-1] == ' ' ]]; then
            BUFFER="${BUFFER}${match}"
        else
            # Son kelimeyi değiştir
            BUFFER="${BUFFER%${current_word}}${match}"
        fi
        CURSOR=${#BUFFER}
        
        # Eğer dizinse, / ekle
        if [[ -d "${matches[1]}" ]]; then
            BUFFER="${BUFFER}/"
            CURSOR=${#BUFFER}
        fi
    elif [[ ${#matches[@]} -gt 1 ]]; then
        # Birden fazla match, listele
        zle -M "Multiple matches: ${matches[*]}"
    else
        zle -M "No matches found for: ${pattern}"
    fi
}

# Widget olarak kaydet
zle -N _shift_tab_completion

# Shift+TAB key binding - Birden fazla denemeli
bindkey '^[[Z' _shift_tab_completion    # Shift+TAB (çoğu terminal)
bindkey '\e[Z' _shift_tab_completion    # Shift+TAB (alternatif)  
bindkey '^[^I' _shift_tab_completion    # ESC+TAB
bindkey '\e^I' _shift_tab_completion    # ESC+TAB (alternatif)
bindkey '^I^[[Z' _shift_tab_completion  # TAB+Shift kombination

# Test fonksiyonu
test_help() {
    local cmd=$1
    echo "=== $cmd parametreleri ==="
    _get_command_help "$cmd"
}

# Help cache'i temizle (komut çalıştırıldığında)
reset_help_shown() {
    _help_shown=()
}

# ZSH hook - komut çalıştırılmadan önce help cache'i temizle
autoload -U add-zsh-hook
add-zsh-hook preexec reset_help_shown

# Key sequence test fonksiyonu
test_key_sequence() {
    echo "Press Shift+TAB and then Enter to see the key sequence:"
    read -k key_sequence
    echo "Key sequence: $key_sequence"
    echo "Hex: $(echo -n "$key_sequence" | xxd)"
}

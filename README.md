# Universal Terminal Auto-Completion

🚀 **A powerful ZSH plugin that provides intelligent auto-completion for ANY command-line tool**

Transform your terminal experience with dynamic parameter extraction from help pages and man documentation. No more memorizing complex command syntax!

## Features

- **Universal Compatibility**: Works with ANY command (system tools, GitHub tools, custom scripts)
- **Dynamic Parameter Extraction**: Automatically parses `--help`, `-h`, and man pages
- **Intelligent Descriptions**: Shows parameter descriptions alongside options
- **Performance Optimized**: Built-in caching system for fast completions
- **🎨 Beautiful Parrot OS Style Prompt**: Clean, informative terminal prompt
- **🔐 Security-Focused**: Perfect for penetration testers and security analysts
- **📁 Context-Aware**: Smart completions for files, directories, ports, and more

## 🎯 Perfect For

- **Security Professionals**: Works seamlessly with tools like `masscan`, `radare2`, `volatility`, `binwalk`
- **Developers**: Supports any CLI tool including `docker`, `kubectl`, `git`, `npm`
- **System Administrators**: Enhanced experience with `systemctl`, `iptables`, `tcpdump`
- **Anyone**: Improves productivity with ANY command-line application

##  Quick Start

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/universal-terminal-completion.git
   cd universal-terminal-completion
   ```

2. **Add to your ZSH configuration:**
   ```bash
   echo "source $(pwd)/terminal.zsh" >> ~/.zshrc
   ```

3. **Reload your terminal:**
   ```bash
   source ~/.zshrc
   ```

That's it! 

##  Usage Examples

1. **TAB** - Shows command help information
2. **Shift+TAB** - Provides file/directory completion


### Security Tools
```bash
# Nmap with intelligent completions
nmap -[TAB]
# Shows: -sS:TCP SYN scan, -sU:UDP scan, -O:OS detection, etc.

# Binwalk with descriptions
binwalk -[TAB]
# Shows: -e:extract files, -B:analyze entropy, -E:scan for executable code, etc.

# Exiftool with metadata options
exiftool -[TAB]
# Shows: -all:show all metadata, -gps:GPS information, -overwrite_original, etc.
```

### Development Tools
```bash
# Docker commands
docker run -[TAB]
# Shows: -d:detached mode, -p:publish ports, -v:bind mount volume, etc.

# Git operations
git commit -[TAB]
# Shows: -m:commit message, -a:stage all changes, --amend:modify last commit, etc.
```

### System Administration
```bash
# Systemctl services
systemctl -[TAB]
# Shows: start:start service, stop:stop service, status:show status, etc.

# Network analysis
tcpdump -[TAB]
# Shows: -i:interface, -w:write to file, -r:read from file, etc.
```

##  Beautiful Terminal Prompt

The plugin includes a stunning Parrot OS-style prompt:

```
┌─[username@hostname]─[/current/directory]
└──╼ $ 
```

**Features:**
- 🟢 **Green** for normal users
- 🔴 **Red** for root users
- 📍 **Full path display** - no more `pwd` needed
- 🎯 **Clean, professional appearance**

## ⚙️ How It Works

1. **Dynamic Analysis**: When you press TAB, the plugin:
   - Runs `command --help` or `command -h`
   - Parses the output using advanced AWK patterns
   - Extracts parameters and descriptions
   - Caches results for performance

2. **Smart Context**: Recognizes parameter types:
   - `-f`, `--file` → File browser
   - `-d`, `--directory` → Directory browser
   - `-p`, `--port` → Common port suggestions
   - `-i`, `--interface` → Network interfaces

3. **Universal Fallback**: If specific completions aren't available, provides intelligent defaults

## 🔧 Advanced Configuration

### Custom Parameter Patterns
The plugin automatically recognizes these parameter patterns:
- Short options: `-a`, `-b`, `-c`
- Long options: `--verbose`, `--output`, `--help`
- Combined formats: `-p, --port PORT`

### Performance Tuning
- **Caching**: Results are cached per command for faster subsequent completions
- **Lazy Loading**: Only processes help text when needed
- **Optimized Parsing**: Efficient AWK patterns for fast text processing

## 🛠️ Compatibility

### Supported Shells
- ✅ **ZSH** (Primary support)
- ⚠️ **Bash** (Limited - ZSH recommended)

### Tested Operating Systems
- ✅ **Parrot OS**
- ✅ **Kali Linux**
- ✅ **Ubuntu/Debian**
- ✅ **Arch Linux**
- ✅ **macOS** (with ZSH)

### Popular Tools Tested
- **Security**: `nmap`, `binwalk`, `exiftool`, `metasploit`, `burpsuite`, `wireshark`
- **Development**: `docker`, `kubectl`, `git`, `npm`, `yarn`, `pip`
- **System**: `systemctl`, `iptables`, `tcpdump`, `netstat`, `ps`, `htop`

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Report Bugs**: Found an issue? Open an issue with details
2. **Suggest Features**: Have ideas? We'd love to hear them
3. **Submit PRs**: Improvements and fixes are always welcome
4. **Documentation**: Help improve our docs
5. **Testing**: Test with new tools and report compatibility




## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **ZSH Community**: For the powerful completion system
- **Parrot OS Team**: For the beautiful terminal aesthetic inspiration
- **Security Community**: For testing and feedback with security tools

---

⭐ **If this project helped you, please give it a star!** ⭐

Made with ❤️ for the terminal enthusiasts and security professionals worldwide. 

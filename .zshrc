# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
#ZSH_THEME="theunraveler"
ZSH_THEME="af-magic"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration
source $HOME/.shconfigsecret.sh

#Neovim remap
alias v="nvim"
alias vim="nvim"
alias vi="nvim"
alias dotfiles="/usr/bin/git --git-dir=${HOME}/.dotfiles/ --work-tree=${HOME}"

if  [[ "$HOST" == "tboard" ]]; then
    research_path=/media/hdd0/research
elif [[ "$HOST" == "TBIT" ]]; then
    research_path=${HOME}/school/grad/research
fi

alias res="cd ${research_path}"
alias spec="cd ${research_path}/spec"
alias ts="cd ${research_path}/shared/customPass/llvm-test-suite"
alias cur="cd ${research_path}/shared/customPass"
alias proj="cd ${HOME}/projects"
alias ta="cd ${HOME}/ta"
alias hdd0="cd /media/hdd0"
alias virt="cd /media/hdd0/virt"

#Neovim runtime path

#if ! [[ "$HOST" == "tboard" ]]; then
#    export VIMRUNTIME=${HOME}/applications/nvim-linux64/share/nvim/runtime/
#fi

# Add vim controls to zsh
bindkey -v
bindkey "^?" backward-delete-char
bindkey "^W" backward-kill-word
bindkey "^H" backward-delete-char
bindkey "^U" backward-kill-line

# export MANPATH="/usr/local/man:$MANPATH"
export TERM="xterm-256color"

## for emacs
if [[ $EMACS = "t" ]] then
    #PROMPT="%# "  # make the prompt simple
    #unsetopt zle  # turn off advanced line editting
    alias ls="ls -A"
    #ls_pager=( cat ) # ls is simple piped to cat
    #ls_flags=( -A )  # default ls flags
fi

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export TOOL_ASM_PATH=${research_path}/hc_as.S
export CUSTOM_C=${research_path}/shared/customPass/llvm-project/build/bin/clang
export CUSTOM_CC=${research_path}/shared/customPass/llvm-project/build/bin/clang++
export RISCV=/media/hdd0/virt/riscv/bin

export YED_LIB_DIR=$HOME/.local/lib/yed/plugins
export YED_CONFIG_DIR=$HOME/.config/yed

#Lean2 imports
export LEAN_PATH=/home/hayden/github/lean2/library:/home/hayden/school/cs704/project/electrolysis/thys:/usr/lib/lean/library/
#export LEAN_PATH=/home/hayden/school/cs704/project/electrolysis/thys:/usr/lib/lean/library/:/home/hayden/github/mathlib/src
#export LEAN_PATH=/home/hayden/github/mathlib/src/
export LEAN2_BIN=/home/hayden/github/lean2/bin/lean

#Rustc env var (lean verification)
export CFG_COMPILER_HOST_TRIPLE=x86_64-unknown-linux-gnu

export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$RISCV/bin:$PATH
export PATH=$HOME/.emacs.d/bin:$PATH

#export IBMQ_TOKEN=$HOME/.config/ibmq.token

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/hayden/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/hayden/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/hayden/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/hayden/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

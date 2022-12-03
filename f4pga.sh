export F4PGA_INSTALL_DIR=/opt/f4pga
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/f4pga/xc7/conda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/f4pga/xc7/conda/etc/profile.d/conda.sh" ]; then
        . "/opt/f4pga/xc7/conda/etc/profile.d/conda.sh"
    else
        export PATH="/opt/f4pga/xc7/conda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
conda activate xc7

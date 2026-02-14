fish_add_path /usr/local/texlive/2025/bin/x86_64-linux
alias gpu-status="echo \"NVIDIA GPU:\" && lspci -nnk | grep -A 3 \"NVIDIA.*AD106M\" | grep \"Kernel driver\" && echo \"Intel GPU:\" && lspci -nnk | grep -A 3 \"Intel.*UHD\" | grep \"Kernel driver\" && echo \"Enable and disable the dedicated NVIDIA GPU with gpu-to-vm and gpu-to-host\""

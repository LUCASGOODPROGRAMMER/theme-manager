echo "🔹 Checagem completa Arch + Hyprland + NVIDIA 🔹"; echo

# 1️⃣ NVIDIA Driver
echo "1️⃣ Verificando driver NVIDIA..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi
else
    echo "❌ nvidia-smi não encontrado"
fi
echo

# 2️⃣ Módulos carregados
echo "2️⃣ Verificando módulos carregados..."
lsmod | grep -e nvidia -e i915
echo

# 3️⃣ Initramfs
echo "3️⃣ Verificando initramfs..."
ls -lh /boot/initramfs-*.img
echo

# 4️⃣ Variáveis de ambiente
echo "4️⃣ Verificando variáveis do Hyprland / Wayland..."
echo "WLR_RENDERER: $WLR_RENDERER"
echo "MOZ_ENABLE_WAYLAND: $MOZ_ENABLE_WAYLAND"
echo

# 5️⃣ Hyprland logs e status
echo "5️⃣ Status do Hyprland..."
echo "Monitores:"
hyprctl monitors
echo
echo "Janelas abertas:"
hyprctl clients
echo
echo "Atalhos configurados:"
hyprctl binds
echo

echo "✅ Checagem concluída!"

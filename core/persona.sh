_distro_persona() {
    local id="$1"
    case $id in
        kali) echo "Penetration testing powerhouse. You don't break into systems — you liberate data." ;;
        parrot) echo "Security meets privacy. You wear a hoodie not for fashion, but for opsec." ;;
        linuxmint) echo "The elegant everyday companion. You value stability and tradition over bleeding edge." ;;
        arch) echo "You read the Arch Wiki before breakfast. Yes, you use Arch. No, you won't stop mentioning it." ;;
        blackarch) echo "Kali's darker, more extensive cousin. 3000+ tools installed. You've used maybe 30." ;;
        ubuntu) echo "The people's distro. You just want things to work, and that's perfectly valid." ;;
        fedora) echo "Red Hat's playground. You like your software fresh but not raw." ;;
        nobara) echo "Fedora, but make it gaming. Proton and drivers handled for you." ;;
        ultramarine) echo "Fedora with the Pantheon desktop. Beautiful and modern." ;;
        manjaro) echo "Arch for the rest of us. You want AUR access without the terminal trauma." ;;
        debian) echo "The universal operating system. Rock-solid stability is your love language." ;;
        pop) echo "System76's masterpiece. Tiling by default, and now you can't go back." ;;
        gentoo) echo "You compile your kernel while waiting for your coffee to brew. USE flags > hobbies." ;;
        void) echo "The independent spirit. runit over systemd, and you're tired of pretending otherwise." ;;
        nixos) echo "Reproducible builds are your passion. Your entire config is one git repo." ;;
        solus) echo "The independent that just works. You chose Budgie and never looked back." ;;
        slackware) echo "The oldest living distro. You probably have a beard made of terminal scrollback." ;;
        alpine) echo "Minimalist to the core. You measure efficiency in megabytes." ;;
        zorin) echo "Windows refugee done right. You're helping friends escape the Microsoft ecosystem." ;;
        elementary) echo "macOS for Linux. Your desktop is pixel-perfect and your dock is immaculate." ;;
        opensuse) echo "YaST is your secret weapon. You love a good GUI tool that doesn't get in the way." ;;
        endeavouros) echo "Arch with training wheels, but the training wheels are cool." ;;
        garuda) echo "Arch but make it gamer. Your desktop looks like a neon racing simulator." ;;
        mageia) echo "Mandriva's spiritual successor. You're part of the loyal French resistance." ;;
        artix) echo "Arch without systemd. Because init systems are worth arguing about." ;;
        deepin) echo "Beauty above all else. Your desktop looks better than most proprietary OSes." ;;
        raspbian) echo "You keep Linux running on hardware that has no right to run it. The underdog champion." ;;
        *) echo "An explorer of the Linuxverse. Every distro has a story, and you're here for all of them." ;;
    esac
}

_de_persona() {
    local de="$1"
    local de_lower
    de_lower=$(echo "$de" | tr '[:upper:]' '[:lower:]')

    case "$de_lower" in
        *kde*|*plasma*) echo "Power user with style. You customize everything down to the animation curves." ;;
        *gnome*) echo "Minimalist and productive. You love extensions but pretend stock GNOME is enough." ;;
        *xfce*) echo "Running that 2008 laptop without breaking a sweat. Function over form, always." ;;
        *mate*) echo "GNOME 2 forever. You still haven't forgiven the GNOME team for version 3." ;;
        *cinnamon*) echo "The classic desktop, perfected. Linux Mint's finest contribution to humanity." ;;
        *budgie*) echo "Sleek, independent, and underrated. You have great taste." ;;
        *lxqt*) echo "Modern toolkit, minimal footprint. You appreciate good engineering." ;;
        *i3*|*sway*|*bspwm*|*qtile*|*dwm*|*awesome*) echo "The mouse is for amateurs. You navigate your computer with keystrokes alone." ;;
        *hyprland*|*wayfire*) echo "Your desktop is a VFX demo reel. Blur, animations, and eye candy everywhere." ;;
        *enlightenment*) echo "You were there in the 90s. You've seen window managers come and go." ;;
        *deepin*) echo "Beauty first. You think Linux desktops should look as good as they work." ;;
        *pantheon*) echo "macOS done right, on Linux. Every pixel has a purpose." ;;
        *cosmic*) echo "The new kid on the block. You're betting on Rust and System76's vision." ;;
        *lxde*) echo "Lightweight before lightweight was cool. Your desktop flies on a potato." ;;
        *) echo "You forge your own path. Desktop environments are just suggestions to you." ;;
    esac
}

_cpu_persona() {
    local model="$1"
    local cores="$2"
    local model_lower
    model_lower=$(echo "$model" | tr '[:upper:]' '[:lower:]')

    local gen=""
    local brand=""
    local msg=""

    if echo "$model_lower" | grep -qi "intel"; then
        brand="Intel"
        gen=$(echo "$model" | grep -oP 'i[3-9][ -]\K(\d{1,2})' 2>/dev/null)
        if [ -z "$gen" ]; then
            gen=$(echo "$model" | grep -oP 'i[3-9]-?\K(\d{1,2})' 2>/dev/null)
        fi
        case $gen in
            4) msg="Haswell. The classic that refuses to die. A golden era of Intel." ;;
            5) msg="Broadwell. The forgotten generation. Your CPU is a collector's item." ;;
            6) msg="Skylake. The modern classic. DDR4's coming-out party." ;;
            7) msg="Kaby Lake. Solid workhorse. Nothing flashy, just gets the job done." ;;
            8) msg="Coffee Lake. The multi-core revolution. Suddenly 6 cores was the baseline." ;;
            9) msg="Coffee Lake Refresh. More of the same, but more of it. Respectable." ;;
            10) msg="Comet Lake. The last of the 14nm era. You held the line." ;;
            11) msg="Rocket Lake. The swan song. IPC improvements but you deserved better." ;;
            12) msg="Alder Lake. The hybrid revolution. Big.LITTLE for desktops, and it's glorious." ;;
            13|14) msg="Raptor Lake. Peak performance. Nothing else comes close right now." ;;
            *) msg="A timeless Intel chip. It's not about the generation, it's how you use it." ;;
        esac
    elif echo "$model_lower" | grep -qi "amd"; then
        brand="AMD"
        local ryzen_gen=""
        ryzen_gen=$(echo "$model" | grep -oP '\d{4}' | head -1 | cut -c1)
        case $ryzen_gen in
            1) msg="Zen 1. The comeback kid. AMD rose from the ashes with this one." ;;
            2) msg="Zen+. The refinement. Not a revolution, but a promise of what was coming." ;;
            3) msg="Zen 2. The core count war. AMD made 12 and 16 cores the new normal." ;;
            4) msg="Zen 3. The gaming king. AMD took the crown and didn't look back." ;;
            5) msg="Zen 4. DDR5 and AM5. The future is here, and it's expensive." ;;
            7) msg="Zen 5. The latest and greatest. Your CPU is a statement of intent." ;;
            *) msg="AMD. The underdog story that became the champion arc. Great choice." ;;
        esac
    else
        brand=$(echo "$model" | awk '{print $1}')
        msg="Unique architecture. You don't follow the crowd, you blaze the trail."
    fi

    local core_msg=""
    if [ "$cores" -le 2 ]; then
        core_msg="$cores cores — humble but honest. It's not about the size of the core count..."
    elif [ "$cores" -le 4 ]; then
        core_msg="$cores cores. The sweet spot for everyday warriors."
    elif [ "$cores" -le 8 ]; then
        core_msg="$cores cores. Multitasking? You don't even know the meaning of lag."
    elif [ "$cores" -le 16 ]; then
        core_msg="$cores cores. You compile code, render video, and host a Minecraft server — simultaneously."
    else
        core_msg="$cores cores. Is this a workstation or a supercomputer? Yes."
    fi

    echo "$brand — $core_msg"
    echo "$msg"
}

_ram_persona() {
    local total_gb="$1"
    local ddr_type="$2"

    local size_msg=""
    if [ "$total_gb" -le 2 ]; then
        size_msg="2 GB or less. You run Alpine and you LIKE it."
    elif [ "$total_gb" -le 4 ]; then
        size_msg="$total_gb GB. Tight, but your lightweight WM makes it work."
    elif [ "$total_gb" -le 8 ]; then
        size_msg="$total_gb GB. The budget sweet spot. Gets the job done."
    elif [ "$total_gb" -le 16 ]; then
        size_msg="$total_gb GB. The modern standard. Plenty of headroom."
    elif [ "$total_gb" -le 32 ]; then
        size_msg="$total_gb GB. You keep at least 3 Chromium tabs open just to flex."
    elif [ "$total_gb" -le 64 ]; then
        size_msg="$total_gb GB. You run VMs for fun. Your RAM disk has a RAM disk."
    else
        size_msg="$total_gb GB. Do you render 8K videos or just hate money?"
    fi

    local ddr_msg=""
    case "${ddr_type,,}" in
        ddr|ddr2) ddr_msg="DDR? That's retro computing territory. Respect." ;;
        ddr3) ddr_msg="DDR3. A classic pairing for a classic system. It served us well." ;;
        ddr4) ddr_msg="DDR4. The reliable workhorse of the last decade. Still going strong." ;;
        ddr5) ddr_msg="DDR5. Bleeding edge. Your wallet feels lighter, but those bandwidth numbers..." ;;
        *) ddr_msg="Unknown DDR type. Mysterious. We like that." ;;
    esac

    echo "$size_msg"
    echo "$ddr_msg"
}

BOX_W=58

_sep() {
    local n=$(( BOX_W + 2 ))
    local line=""
    local i=0
    while [ "$i" -lt "$n" ]; do
        line="${line}═"
        i=$(( i + 1 ))
    done
    echo "$line"
}

_pad() {
    local content="$1"
    local len
    len=$(echo -e "$content" | sed 's/\x1b\[[0-9;]*m//g' | wc -m)
    local pad=$(( BOX_W - len ))
    [ "$pad" -lt 2 ] && pad=2
    echo -e "${YELLOW}║${NC} $content$(printf '%*s' "$pad" '') ${YELLOW}║${NC}"
}

_pad_lines() {
    local text="$1"
    local maxw=$(( BOX_W - 4 ))
    while IFS= read -r line; do
        local len
        len=$(echo -e "$line" | sed 's/\x1b\[[0-9;]*m//g' | wc -m)
        if [ "$len" -le "$maxw" ]; then
            _pad "$line"
        else
            local wrapped
            wrapped=$(echo "$line" | fold -s -w "$maxw")
            while IFS= read -r sub; do
                _pad "$sub"
            done <<< "$wrapped"
        fi
    done <<< "$text"
}

_dot() {
    local n=$(( BOX_W - 2 ))
    echo -e "${YELLOW}║${NC}  $(printf '%*s' "$n" '' | tr ' ' '·')  ${YELLOW}║${NC}"
}

show_persona() {
    local distro_id=""
    local pretty_name=""
    if [ -f /etc/os-release ]; then
        distro_id=$(grep -oP '(?<=^ID=)[a-z]+' /etc/os-release)
        pretty_name=$(grep -oP '(?<=^PRETTY_NAME=")[^"]*' /etc/os-release)
    fi

    local desktop="${XDG_CURRENT_DESKTOP:-}"
    [ -z "$desktop" ] && desktop=$(basename "${DESKTOP_SESSION:-}" 2>/dev/null)
    [ -z "$desktop" ] && desktop=$(command -v gnome-session &>/dev/null && echo "GNOME" || true)
    [ -z "$desktop" ] && desktop="Unknown"

    local cpu_model=""
    local cpu_cores=0
    if [ -f /proc/cpuinfo ]; then
        cpu_model=$(grep -m1 "model name" /proc/cpuinfo | sed 's/.*: //')
        cpu_cores=$(grep -c "processor" /proc/cpuinfo)
    fi

    local ddr_type=""
    if command -v dmidecode &>/dev/null; then
        ddr_type=$(dmidecode --type 17 2>/dev/null | grep "^[[:space:]]*Type:" | head -1 | awk '{print $2}')
        [ "$ddr_type" = "Unknown" ] && ddr_type=""
    fi

    local total_bytes
    total_bytes=$(free -b 2>/dev/null | awk '/^Mem:/ {print $2}')
    local ram_gb
    if [ -n "$total_bytes" ] && [ "$total_bytes" -gt 0 ] 2>/dev/null; then
        ram_gb=$(( (total_bytes + 1073741823) / 1073741824 ))
    else
        ram_gb=0
    fi

    local ram_total="${ram_gb} GB"
    local ram_detail="$ram_total"
    [ -n "$ddr_type" ] && ram_detail="$ram_detail — $ddr_type"

    local distro_persona
    distro_persona=$(_distro_persona "$distro_id")
    local de_persona
    de_persona=$(_de_persona "$desktop")
    local cpu_output
    cpu_output=$(_cpu_persona "$cpu_model" "$cpu_cores")
    local ram_output
    ram_output=$(_ram_persona "$ram_gb" "$ddr_type")

    local sep
    sep=$(_sep)

    echo ""
    echo -e "${YELLOW}╔${sep}╗${NC}"
    _pad "${PURPLE}System Profile${NC}"
    echo -e "${YELLOW}╠${sep}╣${NC}"

    _pad "${CYAN}* Distro${NC}"
    _pad "$pretty_name"
    [ -n "$distro_persona" ] && _pad_lines "$distro_persona"
    _dot

    _pad "${CYAN}* Desktop${NC}"
    _pad "$desktop"
    [ -n "$de_persona" ] && _pad_lines "$de_persona"
    _dot

    _pad "${CYAN}* CPU${NC}"
    _pad_lines "$cpu_output"
    _dot

    _pad "${CYAN}* RAM${NC}"
    _pad "$ram_detail"
    [ -n "$ram_output" ] && _pad_lines "$ram_output"

    echo -e "${YELLOW}╚${sep}╝${NC}"
    echo ""
}

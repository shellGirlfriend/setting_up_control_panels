checkControlPanel() {
    load_average=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}')
    load_average=${load_average%,*}
    load_average=$(echo "${load_average/,/.}")

    if (($(echo "$load_average < 2" | bc -l))); then
        load_average="\e[32m$load_average\e[0m"
    elif (($(echo "$load_average < 5" | bc -l))); then
        load_average="\e[33m$load_average\e[0m"
    else
        load_average="\e[31m$load_average (!)\e[0m"
    fi

    largest_disk=$(df -h | grep '^/dev/' | sort -k 4 -hr | head -n 1)
    disk_usage=$(echo "$largest_disk" | awk '{print $5}') # Використання місця на найбільшому диску
    
    echo -e "\n\033[1mInformation:\033[0m"

    if [[ -e /etc/debian_version ]]; then
        source /etc/os-release
        OS="${ID}"
    elif [[ -e /etc/fedora-release ]]; then
        source /etc/os-release
        OS="${ID}"
    elif [[ -e /etc/centos-release ]]; then
        source /etc/os-release
        OS=centos
    elif [[ -e /etc/oracle-release ]]; then
        source /etc/os-release
        OS=oracle
    elif [[ -e /etc/arch-release ]]; then
        OS=arch
    else
        echo "Схоже, ви не використовуєте цей інсталятор у системах Debian, Ubuntu, Fedora, CentOS, Oracle або Arch Linux"
        exit 1
    fi

    server_IP=$(hostname -I | awk '{print $1}')
    
    case $OS in
        "debian" | "ubuntu" | "fedora" | "centos" | "oracle" | "arch")
            if [ -d "/usr/local/hestia" ]; then
                hestia_info=$(/usr/local/hestia/bin/v-list-sys-info)

                hostname=$(echo "$hestia_info" | awk 'NR==3{print $1}')
                operating_system=$(echo "$hestia_info" | awk 'NR==3{print $2}')
                os_version=$(echo "$hestia_info" | awk 'NR==3{print $3}')
                hestia_version=$(echo "$hestia_info" | awk 'NR==3{print $5}')

                echo -e "Hostname:\033[32m$hostname\033[0m IP: $server_IP OS:\033[33m$operating_system\033[0m Ver:\033[34m$os_version\033[0m HestiaCP:\033[35m$hestia_version\033[0m"
                echo -e "Load Average: $load_average Disk Usage: $disk_usage"
            elif [ -d "/usr/local/vesta" ]; then
                vesta_info=$(/usr/local/vesta/bin/v-list-sys-info)

                hostname=$(echo "$vesta_info" | awk 'NR==3{print $1}')
                operating_system=$(echo "$vesta_info" | awk 'NR==3{print $2}')
                os_version=$(echo "$vesta_info" | awk 'NR==3{print $3}')
                vesta_version=$(echo "$vesta_info" | awk 'NR==3{print $5}')

                echo -e "Hostname:\033[32m$hostname\033[0m IP: $server_IP OS:\033[33m$operating_system\033[0m Ver:\033[34m$os_version\033[0m VestiaCP:\033[35m$vesta_version\033[0m"
                echo -e "Load Average: $load_average Disk Usage: $disk_usage"
            elif [ -d "/usr/local/mgr5" ]; then
                echo -e "\033[32mISPmanager is installed.\033[0m"
                /usr/local/mgr5/sbin/licctl info ispmgr
            elif [ -f "/usr/local/cpanel/cpanel" ]; then
                echo -e "\033[32mcPanel is installed.\033[0m"
                /usr/local/cpanel/cpanel -V
                cat /etc/*release
            else
                echo "No supported control panel found."
            fi
            ;;
        *)
            echo "No supported control panel found for the detected operating system."
            ;;
    esac
}

generate_random_password() {
    password=$(openssl rand -base64 12)
    echo -e "\n\nЗгенерований випадковий пароль: \e[91m$password\e[0m"
}

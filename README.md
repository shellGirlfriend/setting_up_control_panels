# setting_up_control_panels

wget https://raw.githubusercontent.com/shellGirlfriend/setting_up_control_panels/main/setting_up_control_panels.sh && bash ./setting_up_control_panels.sh 

history -d $(history | tail -n 2 | head -n 1 | awk '{print $1}')
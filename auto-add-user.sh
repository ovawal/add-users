# Script to add users to the local system and automate password generation

# Sudo validation
if [[ "$(id -u)" -ne 0 ]]; then
        echo "Kindly log in as root or use sudo "
        exit 1
fi

# Usage statement
if [[ "${#}" -lt 1 ]]; then
        echo "Usage: $(basename $0) LOGIN_NAME  [FULL_NAME] ..."
        exit 1
fi

# Begging of script message
echo -e "\nCreating user ${1}, please be patient....."

# Check if command expect is installed
if ! command -v expect &>/dev/null ; then
    if command -v yum ; then
        yum install expect -y &>/dev/null
        if [[ $? -ne 0 ]]; then
        echo "Failed to install expect. Install it manually."
        exit 1
        fi
    elif command -v apt -y &>/dev/null; then
            apt install expect -y &>/dev/null
            if [[ $? -ne 0 ]]; then
            echo "Failed to install expect. Install it manually."
            exit 1
            fi   
    else
    echo 'No supported package manager (yum/apt). Install expect manually'
    exit 1
    fi
fi

# FIrst argument as username and rest as comment
useradd -m -c "${@:2}" "${1}"

# Password message
echo -e "\nCreating password for ${1}...."

# Password creation
SPECIAL_CHARACTER=$( echo '!@#$%^&*()-=' | fold -w1 | shuf | head -c1 )
PASS=$(date +%s%N${RANDOM} | sha256sum | head -c15)
PASSWORD="${SPECIAL_CHARACTER}${PASS}"
# Funtion to set password with expect
set_password() {
    /usr/bin/expect <<EOF
    spawn passwd "${1}"
    expect "Enter new UNIX password:"
    send "${PASSWORD}\r"
    expect "Retype new UNIX password:"
    send "${PASSWORD}\r"
    expect eof
EOF
}

# Set the password
set_password "${1}" &>/dev/null
 if [[ $? -ne 0 ]]; then
        echo "Error: Failed to set password for user ${1}."
        exit 1
else
        echo -e "\nPassword set successfully for user ${1}."
 fi

# Expire message
echo -e "\nExpring password..."
# Expire password after first login
passwd -e "${1}" &>/dev/null
if [[ $? -ne 0 ]]; then
    echo 'Error expring password.'
    exit 1
    else
    echo 'Password will expire after first log in'
fi

# User information
echo -e "\n------User Information-----\n"
echo "User name: ${1}"
echo "Password:  ${PASSWORD}"
echo "Reset pasword after first login."

echo -e "\n---End of Script---\n"
exit 0

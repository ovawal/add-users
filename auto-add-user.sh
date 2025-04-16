# This script creates a new user on the local system

# You must supply a username as an argument to the script
# Sudo validation
if [[ "$(id -u)" -ne 0 ]]; then
	echo 'Please run with sudo or as root'
        exit 1
fi

# Usage statement- If they dont supply atleast on argument
if [[ "${#}" -lt 1 ]]; then
        echo "Usage: $(basename $0) USER_NAME [COMMENT]..."
	echo 'Create an account on the local system with the name of USER_NAME and a comment field of COMMENT.'
        exit 1
fi

# The first parameter is the user name
USER_NAME="${1}"

# The rest of the parameters are comments 
shift
COMMENT="${@}"
# Begging of script message
echo -e "\nCreating user ${USER_NAME}..."

# Check if command expect is installed
if ! command -v expect &>/dev/null; then
    if command -v yum &>/dev/null; then
        yum install expect -y &>/dev/null
        if [[ $? -ne 0 ]]; then
        echo "Failed to install expect. Install it manually."
        exit 1
        fi
    elif command -v apt  &>/dev/null; then
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
useradd -m -c "${COMMENT}" "${USER_NAME}"

# Check to see if useradd succeeded
if [[ "${?}" -ne 0 ]]; then
	echo 'The account could not be created.' 
	exit 1
fi

# Password message
echo -e "\nCreating password for ${USER_NAME}..."

# Password creation
SPECIAL_CHARACTER=$( echo '!@#$%^&*()-=' | fold -w1 | shuf | head -c1 )
PASS=$(date +%s%N${RANDOM} | sha256sum | head -c15)
PASSWORD="${SPECIAL_CHARACTER}${PASS}"

# Funtion to set password with expect
set_password() {
    /usr/bin/expect <<EOF
    spawn passwd "${USER_NAME}"
    expect "Enter new UNIX password:"
    send "${PASSWORD}\r"
    expect "Retype new UNIX password:"
    send "${PASSWORD}\r"
    expect eof
EOF
}

# Set the password
set_password "${USER_NAME}" &>/dev/null

# Check if password creation succeded
 if [[ $? -ne 0 ]]; then
        echo "Error: Failed to set password for user ${USER_NAME}."
        exit 1
else
        echo -e "\nPassword set successfully for user ${USER_NAME}."
 fi

# Expire message
echo -e "\nExpring password..."

# Expire password after first login
passwd -e "${USER_NAME}" &>/dev/null
if [[ $? -ne 0 ]]; then
    echo 'Error expring password.'
    exit 1
    else
    echo 'Password will expire after first log in'
fi

# User information
echo -e "\n---User Information---\n"
echo "User name: ${USER_NAME}"
echo "Password:  ${PASSWORD}"
echo "Host: ${HOSTNAME}"
echo "Reset pasword after first login."
echo -e "\n---End of Script---\n"
exit 0

### Script to add users to your local RHEL or DEBIAN system
#### ***This script does the following:***
- Sudo validation
- Checks and installs dependcies
- Creates the password
- Enforces password change after first log in
- Displays the user information i.e username & password

#### **Usage**
1. Download script to local machine
2. Move script to /usr/local/bin
```
	mv /path/to/your/download/auto-local-user.sh /usr/local/bin/
```
3. Change permissions
```
	sudo chmod 744 /usr/local/bin/auto-local-user.sh
```
4. Execute script. Replace username & fullname with new user.
```
	sudo /usr/local/bin/auto-local-user.sh  username [ Full_Name ]
```

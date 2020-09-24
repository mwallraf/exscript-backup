Fix a bug with some Cisco devices where it gives SSH login errors after sending the "auth_none".
Bypass the bug by updating the exscript ssh2.py file and replace auth_none() with auth_password().
For network devices with username/password authentication this shoul not give any problems

bash-5.0# vi /usr/lib/python3.8/site-packages/Exscript/protocols/ssh2.py
line 283:
change
        try:
            self.client.auth_none(username)
TO:
        try:
            #self.client.auth_none(username)
            self.client.auth_password(username, password)


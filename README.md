# hostinit
Sets up a new Linux system Yubikey SSH/sudo/gpg support and some other bells and whistles


Requirements
------------
`sudo apt-get install ansible curl make`

Installation
------------

1) Edit `Makefile` and replace `SSH_KEY_URL="https://github.com/logicwax.keys"` with the URL to your gpg key (replace github username should be good enough if you've updated your github account with your gpg key)

2) run `make`


# hostinit
Sets up a new Linux ubuntu/debian-based system with nice Z-shell defaults and Yubikey SSH/sudo/gpg support and some other bells and whistles.


Requirements
------------
`sudo apt-get install ansible curl make`

Default Installation
------------

1) Run `make`

Install with SSH/PGP keys
------------

1) If you wish to have ssh and pgp keys automatically installed, edit `Makefile` and replace `GITHUB_ACCOUNT="logicwax"` with your github account name (provided your pgp and ssh keys are already setup in your account already).

2) Run `make keys` (performs default installation as well)

#!/bin/bash 

# script to be run by udev rule to remove private key stubs 
# desired goal is to remove the <keygrip>.key files 
# of the associated subkeys on a newly inserted yubikey

# Digging through the Source yields fruit
# > The secret keys are stored in files with a name matching 
# > the hexadecimal representation of the keygrip[2] and suffixed with “.key”.
# Where [$SOURCE](https://github.com/gpg/gnupg/blob/6c000d4b78b836686e5a2789cc88a41e465e4400/agent/keyformat.txt)
#
# Time to really dive into the src to really see what's going on...
# curious as to "how the secret keys are _made_
# 
# url: https://gnupg.org/download/index.html#libgcrypt
# libgcrypt url: https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.4.tar.bz2
#
# interesting snippets
# > Return the so called KEYGRIP
#
# cipher/pubkey.c <_gcry_pk_get_keygrip>
# ```
# 617
# 618 /* Return the so called KEYGRIP which is the SHA-1 hash of the public
# 619    key parameters expressed in a way depending on the algorithm.
# 620
# ```
#
# 
#src/sexp.c <_gcry_sexp_find_token>
#```
# 430 /****************
# 431  * Locate token in a list. The token must be the car of a sublist.
# 432  * Returns: A new list with this sublist or NULL if not found.
# 433  */
# 434 gcry_sexp_t
# 435 _gcry_sexp_find_token( const gcry_sexp_t list, const char *tok, size_t toklen )
#```

user={{ user }}
update_card(){
  # pulls in card state/information
  # updates /<GPG_HOME>/private-keys-v1.d/<keygrip>.key files
  #TODO: check gpg2 src on why this isn't already happening after first update
  logger "updating card status"
  su $user -c "/usr/bin/gpg2 --card-status"
}

_test_file_exists(){
  file_path=$1

  logger "testing $file_path exists"
  if [ -f $file_path ];
  then 
    return 0
  fi
  exit 1
}
clean_private_keys_v1_dir() {
  # receives arrays of KEYGRIP
  # <Arg: KEYGRIP Array>
  # <Ret: None>
  # <Cmd: rm>

  local cmd="/bin/rm -f"

  for keygrip in ${kgrp_arr[@]}
  do
    logger "removing keygrip file: ${keygrip}.key"
    local keygrip_path="/home/${user}/.gnupg/private-keys-v1.d/${keygrip}.key"
    _test_file_exists ${keygrip_path}
    su $user -c "$cmd $keygrip_path"
  done
}

retrieve_card_fingerprints() {
  # eg. fpr:<fingerprint>:<fingerprint>:<fingerprint>:
  # <Arg: None>
  # <Ret: FingerPrint Array>

  logger "retrieving fingerprints from card"
  local main_args="gpg --card-status --with-colons |"
  local output_cleanse_addons=" grep ^fpr: | sed -e 's/fpr://' | sed -e 's/:/\ /g'"

  fpr_arr=( $(su $user -c "${main_args}${output_cleanse_addons}") )
  logger "fpr_arr= ${fpr_arr[@]}"

  return 0
}

retrieve_keygrip_arr(){
  # <Arg: Fingerprint Arr>
  # <Ret: Keygrip Arr>

  kgrp_arr=( )
  for fpr in ${fpr_arr[@]}
  do
    local main_args="gpg -K --with-keygrip --with-colons ${fpr} |"
    local output_cleanse_addons=" grep -A1 ${fpr}: | grep ^grp: | sed -e 's/^grp//g' | sed -e 's/://g'"

    kgrp_arr+=($(su $user -c "${main_args}${output_cleanse_addons}"))
  done
  logger "kgrp_arr= ${kgrp_arr[@]}"

  return 0
}


main(){
  update_card
  # set fpr_arr
  retrieve_card_fingerprints
  echo "fpr_arr= ${fpr_arr[@]}"
  # set kgrp_arr
  retrieve_keygrip_arr
  echo "kgrp_arr: ${kgrp_arr[@]}"
  clean_private_keys_v1_dir 
  update_card
}

main

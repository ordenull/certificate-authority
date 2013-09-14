DATA="$DIR/data"
CONF="$DIR/conf"
LOG="$DIR/data/output.log"

function print_error   { echo -e "\033[0;31m$1\033[0m"; }
function print_warning { echo -e "\033[1;33m$1\033[0m"; }
function print_info    { echo -e "\033[0;32m$1\033[0m"; }

function load_config {
  if [ ! -e "$CONF/globals.sh" ]; then
    print_error "The configuration file is missing, please save it at '$CONF/globals.sh'"
    exit 1
  fi

  if [ ! -d "$DATA/private" ]; then
    mkdir -p "$DATA/private" || {
      print_error "Unable to create a data directory in '$DATA', please verify write permissions"
      exit 1;
    }
  fi
  chmod 700 "$DATA"

  if [ ! -e "$DATA/private/random_seed" ]; then
    print_warning "The '$DATA/private/random_seed' is missing, making a new one"
    openssl rand -out "$DATA/private/random_seed" 4096 || {
      print_error "Unable to generate a random seed, please verify write permissions"
      exit 1;
    }
  fi

  #Load the configuration file
  source "$CONF/globals.sh"
}

function verify_ca {
  if [ ! -d "$DATA" ]; then
    mkdir -p "$DATA" || {
      print_error "Unable to create a data directory at '$DATA', please verify write permissions"
      exit 1;
    }
  fi

  if [ ! -d "$DATA/meta" ]; then
    mkdir -p "$DATA/meta" || {
      print_error "Unable to create a data directory at '$DATA/meta', please verify write permissions"
      exit 1;
    }
  fi

  if [ ! -d "$DATA/certs" ]; then
    mkdir -p "$DATA/certs" || {
      print_error "Unable to create a data directory at '$DATA/certs', please verify write permissions"
      exit 1;
    }
  fi

  if [ ! -e "$DATA/authority.crt" ]; then
    print_error "The CA certificates haven't been generated yet, please run './authority-generate.sh'"
    exit 1
  fi

  if [ ! -e "$DATA/private/authority.key" ]; then
    print_error "The CA key is missing, please place it at '$DATA/private/authority.key'"
    exit 1
  fi


  if [ ! -e "$DATA/meta/serial" ]; then
    print_warning "The CA serial number tracker is missing, a new one will be generated."
    echo "CAFEBABE0000" > "$DATA/meta/serial" || {
      print_error "Failed to write to '$DATA/meta/serial'"
      exit 1
    }
  fi

  if [ ! -e "$DATA/meta/crlnumber" ]; then
    print_warning "The CA revocation number tracker is missing, a new one will be generated."
    echo "F000BA000000" > "$DATA/meta/crlnumber" || {
      print_error "Failed to write to '$DATA/meta/crlnumber'"
      exit 1
    }
  fi

  if [ ! -e "$DATA/meta/index.txt" ]; then
    print_warning "The CA index is missing, a new one will be generated."
    : > "$DATA/meta/index.txt" || {
      print_error "Failed to write to '$DATA/meta/index.txt'"
      exit 1
    }
  fi
}

function generate_openssl_config {
  print_info "Generating an openssl configuration file in $DATA/generated.cnf"
  : > $DATA/generated.cnf || {
      print_error "Failed to write to '$DATA/generated.cnf'"
      exit 1
  }
  cat "$CONF/ssl_head.cnf"                                   >> $DATA/generated.cnf
  echo "# added by lib/functions.sh:generate_openssl_config" >> $DATA/generated.cnf
  echo "HOME = $DATA"                                        >> $DATA/generated.cnf
  echo "RANDFILE = $DATA/private/random_seed"                >> $DATA/generated.cnf
  echo ""                                                    >> $DATA/generated.cnf
  cat "$CONF/ssl_auth.cnf"                                   >> $DATA/generated.cnf
  cat "$CONF/ssl_policy.cnf"                                 >> $DATA/generated.cnf
  cat "$CONF/ssl_misc.cnf"                                   >> $DATA/generated.cnf
  cat "$CONF/ssl_req.cnf"                                    >> $DATA/generated.cnf

  if [ -e "$CONF/usr_cert.cnf" ]; then
    echo "#################################################" >> $DATA/generated.cnf
    echo "## usr_cert.cnf ########### generated ###########" >> $DATA/generated.cnf
    echo "#################################################" >> $DATA/generated.cnf
    echo ""                                                  >> $DATA/generated.cnf
    cat "$CONF/usr_cert.cnf"                                 >> $DATA/generated.cnf
  fi
}

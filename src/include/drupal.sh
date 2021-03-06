################################################################################
# Include script that holds helper functions about Drupal.
################################################################################


##
# Run drush from within the Drupal root ($DIR_WEB folder).
#
# Use this if you need to run the drush command from within the actual web root.
# Do not use it when installing the make files.
#
#
##
function drupal_drush {
  drupal_drush_run "$@" --root="$DIR_WEB"
}

##
# Run drush.
#
# This command will run by default the globally installed drush.
# If the $DRUSH_VERSION is set to a specific version, then it will expect drush
# to be installed using composer and will run drush from within the
# bin/vendor/bin directory.
##
function drupal_drush_run {
  local cmd_drush=""

  if [ -z "$DRUSH_VERSION" ] || [ "$DRUSH_VERSION" == "phar" ]; then
    cmd_drush="$DIR_BIN/packagist/drush.phar"
  elif [ "$DRUSH_VERSION" == "global" ]; then
    cmd_drush="drush"
  else
    cmd_drush="$DIR_BIN/packagist/vendor/bin/drush"
  fi

  $cmd_drush "$@"
}

##
# Create the $DRUSH_OPTIONS array based on the $SCRIPT_OPTIONS_ALL array.
##
function drupal_drush_filter_options {
  DRUSH_OPTIONS=()

  markup_debug "Filter drush options:"

  for drush_option in "${SCRIPT_OPTIONS_ALL[@]}"; do
    # Check if the option should be passed to drush.
    if [ $(drupal_drush_filter_option "$drush_option") -eq 1 ]; then
      markup_debug " • $drush_option"
    else
      DRUSH_OPTIONS+=("$drush_option")
    fi
  done

  markup_debug
}

##
# Remove druleton specific command options.
#
# @param string
#   The command options.
#
# @return string
#   The filtered options.
##
function drupal_drush_filter_option {
  local option="$1"

  # Druleton uses --no-color, drush does not support that.
  if [ "$option" == "--no-color" ]; then
    echo 1
    return
  fi

  # drush does not support environments.
  if [[ "$option" == "--env="* ]]; then
    echo 1
    return
  fi

  echo 0
}

##
# Make sure that the DRUSH_VERSION variable is set.
##
function drupal_drush_variable_version {
  if [ -z "$DRUSH_VERSION" ]; then
    DRUSH_VERSION="phar"
  fi
}

##
# Check if there is a working Drupak installation.
#
# @return is installed 1/0
##
function drupal_is_installed {
  drupal_is_installed_string=`drupal_drush status grep "Drupal bootstrap" \
    | grep "Successful"`

  if [[ "$drupal_is_installed_string" != "" ]]; then
    echo 1
    return
  fi

  echo 0
}


##
# Remove the protection from the sites/default directory.
##
function drupal_sites_default_unprotect {
  if [ -d "$DIR_WEB/sites/default" ]; then
    chmod -R u+w "$DIR_WEB/sites/default"
  fi
}

##
# Restore the protection of the sites/default directory.
##
function drupal_sites_default_protect {
  if [ -f "$DIR_WEB/sites/default/settings.php" ]; then
    chmod a-w "$DIR_WEB/sites/default/settings.php"
  fi

  if [ -d "$DIR_WEB/sites/default" ]; then
    chmod a-w "$DIR_WEB/sites/default"
  fi
}

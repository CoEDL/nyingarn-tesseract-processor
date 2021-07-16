#!/bin/bash

TESSERACT_DATAFILES="https://github.com/tesseract-ocr/tessdata_best/archive/refs/tags/4.1.0.tar.gz"
TESSERACT_DATAFILES_NAME="tessdata_best-4.1.0"

bailOrContinue() {
  response=${1}
  msg=${2}
  if [ $resp != 'Y' ] ; then
    echo $msg
    exit 0
  fi
}

#
# Setup local environment
#
setup() {
  
  if [ -z $(which docker) ] ; then
    echo "Can't find 'docker'. This script needs to be run on a server with 'docker' in the $PATH"
    exit -1
  fi

  if [ -z $(which curl) ] ; then
    echo "Can't find 'curl'. This script needs to be run on a server with 'curl' in the $PATH"
    exit -1
  fi

cat <<EOF

  Downloading the tesseract docker container.

EOF
docker pull -q clearlinux/tesseract-ocr > /dev/null

cat <<EOF

  Tesseract needs language data files. These can be quite big so I'll download
  them once to $HOME/.nyingarn so they're available for next time.

EOF

  mkdir -p $HOME/.nyingarn
  if [ ! -d "$HOME/.nyingarn/${TESSERACT_DATAFILES_NAME}" ] ; then
    if [ ! -f "$HOME/.nyingarn/datafiles.tgz" ] ; then
      curl -L $TESSERACT_DATAFILES --output $HOME/.nyingarn/datafiles.tgz
    fi
    cd $HOME/.nyingarn
    tar -zxf datafiles.tgz
  fi

}


#
# The workhorse
#   Iterate over folder content looking for images to process
#
processFolder() {
  DATA_PATH=${1}
  PACKAGE_NAME=${2}

  declare -a processed

  cd $DATA_PATH
  for f in $(ls) ; do
    file --mime-type $f | grep -qi image
    if [ $? == 0 ]; then
      BASENAME=$(echo $f | awk -F '.' '{print $1}')
      echo "Processing: $f"

      docker run --rm -it --name myapp \
        -v "$PWD":/app \
        -v "$HOME/.nyingarn/${TESSERACT_DATAFILES_NAME}":/tessdata \
        -e "TESSDATA_PREFIX=/tessdata" \
        -w /app \
        clearlinux/tesseract-ocr \
        tesseract --psm 6 $f $BASENAME

      processed+=("$f")
      processed+=("$BASENAME.txt")
    fi
  done
  for name in "${processed[@]}" ; do
    zip -u $PACKAGE_NAME $name
  done
}

# 
# Script args
#
usage() { echo "Usage: $0 [-d <string>] [-n <string>]" 1>&2; exit 1; }
while getopts ":d:n:" o; do
    case "${o}" in
        d)
            DATA_PATH=${OPTARG}
            ;;
        n)
            PACKAGE_NAME=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

#
# Batch processing with args
#
if [ ! -z "${DATA_PATH}" ] && [ ! -z "${PACKAGE_NAME}" ]; then
  setup
  processFolder $DATA_PATH $PACKAGE_NAME
  exit 0
fi

#
# interactive mode
#
cat <<EOF

  This script will help you process a folder of images using tesseract.

  Each image will have a correspondingly named text file with the output
  from tesseract in it.

  At the end, there will also be a zip file of the content ready for upload
  to fromthepage.
  
EOF
read -p '  Continue? [n|Y]: ' resp
bailOrContinue resp "> Ok. Stopping now."

cat <<EOF
  
  This tool operates on folder of images. Please specify a path to
  content to be preocessed.

EOF
read -p "  Where is the data to be processed? Provide the path. " DATA_PATH
[[ -z $DATA_PATH ]] && bailOrContinue N 'You need to specify a path to a folder of images to be processed.'

cat <<EOF

  This tool will produce a zip file for upload to Fromthepage. Specify
  a name for this file and keep in mind that the FTP project will be named that.

EOF
read -p "  What should this bundle be named? " PACKAGE_NAME
[[ -z $PACKAGE_NAME ]] && bailOrContinue N 'You need to specify a name for the bundle.' 

processFolder $DATA_PATH $PACKAGE_NAME

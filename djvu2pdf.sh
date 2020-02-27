#!/bin/bash

POSTSCRIPT=0

while test $# -gt 0; do
  case "$1" in
    -f|--file)
      shift
      FILE=$1
      shift
      ;;
    -o|--output)
      shift
      OUT=$1
      shift
      ;;
    -q|--quality)
      shift
      QUALITY=$1
      shift
      ;;
    -v|--verbose)
      shift
      STRING=$STRING" -verbose"
      ;;
    -b|--black)
      shift
      STRING=" -mode=black"
      ;;
    -ps|--postscript)
      shift
      POSTSCRIPT=1
      ;;
    *)
      echo -e $colError"Unknown flag: "$colArg$1$colClear
      exit 1
      ;;
  esac
done


if [ $POSTSCRIPT -eq 1 ] ; then
  module -expert load Ghostscript
  module -expert load libjpeg-turbo/1.5.1-intel-2017a
  module -expert load LibTIFF/4.0.7-intel-2017a

  djvups $STRING $FILE | ps2pdf - $OUT
else
  module -expert load libjpeg-turbo/1.5.1-intel-2017a
  module -expert load LibTIFF/4.0.7-intel-2017a

  ddjvu -format=pdf -quality=$QUALITY $STRING $FILE $OUT
fi

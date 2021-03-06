# Nyingarn Tesseract Processor

- [Nyingarn Tesseract Processor](#nyingarn-tesseract-processor)
  - [Info](#info)
  - [Dependencies](#dependencies)
  - [Running the script](#running-the-script)
  - [Interactive](#interactive)
  - [Batch](#batch)
    - [Run without a config](#run-without-a-config)
    - [Run with a config](#run-with-a-config)

A tool to run a folder of images through Tesseract OCR.

The tool has two modes of operation:

-   interactive
-   batch

## Info

-   [Tesseract Manual](https://github.com/tesseract-ocr/tessdoc)
-   [Tesseract Best Models](https://github.com/tesseract-ocr/tessdata_best)

## Dependencies

This must be run on a server with docker and bash. That's it.

## Running the script

Download it to your machine with:

```
> curl https://raw.githubusercontent.com/CoEDL/nyingarn-tesseract-processor/master/tesseract-batch-processor.sh --output tesseract-batch-processor.sh
> chmod +x tesseract-batch-processor.sh
```

You can put it anywhere.

Then run it as described in the following sections.

## Interactive

```
> ./tesseract-batch-processor.sh
```

It will prompt you for the information it needs

## Batch

In batch mode you can specify the path to the data and name for the output zip file:

-   -d folder of data to process (REQUIRED)
-   -n name of the resulting zip file (REQUIRED)
-   -c the tesseract config to use - must be in the same folder as the data(OPTIONAL)

### Run without a config

```
> ./tesseract-batch-processor.sh  -d /Users/mlarosa/src/pdsc/data/nyingarn/tmp -n bundle
```

### Run with a config

```
> ./tesseract-batch-processor.sh  -d /Users/mlarosa/src/pdsc/data/nyingarn/tmp -n bundle -c config.txt
```

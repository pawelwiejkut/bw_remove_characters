
# Remove special charters in BW transformations

[![Build Status](https://travis-ci.org/pawelwiejkut/bw_remove_charters.svg?branch=master)](https://travis-ci.org/pawelwiejkut/bw_remove_charters)

Welcome at github BW tool for remove special charters, fell free to contribute and create pull requests.

If you only have frequent data load from flat files in your BW, you know that user can provide wrong charters into. To prevent activation error of this data, please use this development in your transformation end routine on layer one. 

## Issue scenario

No all special charters defined in BW can be hanlded by infoobjects. Due to that, if user provide unexpected chart, we get an issue in case of data activation in our BW system:

![Issue](https://pawelwiejkut.net/github/bw_remove_charters_issue.png)

## Usage instructions:

1. Clone code using [ABAP Git](https://github.com/larshp/abapGit) or just copy class,
2. Add following code into end routine to your trnasformations between flatfile datasource and DSO,
3. Use and be happy !




# Remove special charters in BW transformations

[![Build Status](https://travis-ci.org/pawelwiejkut/bw_remove_charters.svg?branch=master)](https://travis-ci.org/pawelwiejkut/bw_remove_charters)

Welcome at github BW tool for remove special charters, fell free to contribute and create pull requests.

If you only have frequent data load from flat files in your BW, you know that user can provide wrong charters into. To prevent activation error of this data, please use this development in your transformation end routine on layer one. 

## Issue scenario

No all special charters defined in BW can be hanlded by infoobjects. Due to that, if user provide unexpected chart, we get an issue in case of data activation in our BW system:

![Issue](https://pawelwiejkut.net/github/bw_remove_charters_issue.png)

## How it works ?

This development check infoobject based on passed reference table. Best idea is to use this in end routine between flatfile source system and target DSO. You can't use this if your target object is field based instead of inffobect based. 

## Why better than other solutions ?

This development uses standard SAP function module RSKC_CHAVL_OF_IOBJ_CHECK, which basically checks every charter you tring to pass to particular infoobject and confirms is that charter allowed to be used in. Most of avaible implementations check correctness of passed charters based on SAP note [173241](https://launchpad.support.sap.com/#/notes/173241):

!"%&''()*+,-./:;<=>?_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ

This implementation addiotionaly:

* prevent you against pass unsupported charters into particular data types, like passing char values to data fields,
* bases on entries that you provided in RSKC transaction

## Usage instructions:

1. Clone code using [ABAP Git](https://github.com/larshp/abapGit) or just copy class,
2. Add following code into end routine to your trnasformations between flatfile datasource and DSO:

```ABAP
DATA(lr_tab) = REF #( result_package ).

DATA(lobj_check) = NEW zcl_bw_validate_special( ir_ref = lr_tab ).

lobj_check->validate(
  EXPORTING
    it_tab     =  result_package
    it_monitor =  monitor
  IMPORTING
    et_tab     = result_package
    et_monitor =  monitor
).
```

3. Use and be happy !

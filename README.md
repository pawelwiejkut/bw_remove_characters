
# Remove special characters in BW transformations

Welcome at github BW tool for remove special characters, fell free to contribute and create pull requests.

If you have frequent data load from flat files in your BW, you know that user can provide wrong characters into. To prevent activation error of this data, please use this development in your transformation end routine on the first layer (RSDS->DSO). 

## Issue scenario

No all special characters defined in BW can be hanlded by infoobjects. Due to that, if user provide unexpected chart, we get an issue in case of data activation in our BW system:


![Issue](https://pawelwiejkut.dev/bw_remove_charters/1.png)

or other informations like:
* Value ‘#’ (hex. ‘2300’) of characteristic  contains invalid characters
* Error when assigning SID: Action VAL_SID_CONVERT InfoObject
* (hex. ‘500072007A0065006C006500770020006E0061002000720061’) of characteristic  contains inva

## How it works ?

This development check infoobject based on passed reference table. Best idea is to use this in end routine between flatfile source system and target DSO. You can't use this if your target object is field based instead of inffobect based. If any invaild characters occurs, it will be automatically replaced by nothig ( cuted off).

## Why better than other solutions ?

This development uses standard SAP function module RSKC_CHAVL_OF_IOBJ_CHECK, which basically checks every character you are trying to pass to particular infoobject and confirms is that character allowed to be used in. Most of avaible implementations check correctness of passed characters based on SAP note [173241](https://launchpad.support.sap.com/#/notes/173241):

!"%&''()*+,-./:;<=>?_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ

This implementation addiotionaly:

* prevent you against pass unsupported characters into particular data types, like passing char values to date fields,
* bases on entries that you provided in RSKC transaction

## Usage instructions:

1. Clone code using [ABAP Git](https://github.com/larshp/abapGit) or just copy class,
2. Add following code into end routine to your trnasformations between flatfile datasource and DSO:

```ABAP
DATA(lobj_check) = NEW zcl_bw_validate_special(
ir_ref = REF #( result_package ) ).

lobj_check->validate(
  EXPORTING
    it_tab     =  result_package
    it_monitor =  monitor
  IMPORTING
    et_tab     = result_package
    et_monitor =  monitor ).
```

3. Use and be happy !

CLASS ltcl_test_valid DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      first_test FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_valid IMPLEMENTATION.

  METHOD first_test.

    DATA lt_sflight TYPE STANDARD TABLE OF sflight.

    APPEND VALUE sflight( carrid = '!# casa' ) TO lt_sflight.

    DATA(lro_sflight) = REF #( lt_sflight ).
    DATA(lobj_test) = NEW zcl_bw_validate_special( lro_sflight ).

    lobj_test->validate(
      EXPORTING
        it_tab     = lt_sflight               "  Income table, to be checked
*        it_monitor =
      IMPORTING
        et_tab     = lt_sflight                 "  Outcome table, special charters removed
*        et_monitor =
    ).

  ENDMETHOD.

ENDCLASS.

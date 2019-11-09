CLASS ltcl_test_valid DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      first_test FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_valid IMPLEMENTATION.

  METHOD first_test.

    DATA: lt_testtab TYPE STANDARD TABLE OF /bic/azbwhbt0100.

    lt_testtab = VALUE #( ( /bic/zhbcurdat = 'fgfg' /bic/zhbtrdesc = '#FAGSJD**' ) ).

    DATA(lr_tab) = REF #( lt_testtab ).

    DATA(lobj_test) = NEW zcl_bw_validate_special( ir_ref = lr_tab ).

    lobj_test->validate( it_tab = lt_testtab ).

  ENDMETHOD.

ENDCLASS.

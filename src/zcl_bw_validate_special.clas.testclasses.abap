class ltcl_ definition final for testing
  duration short
  risk level harmless.

  private section.
    methods:
      first_test for testing raising cx_static_check.
endclass.


class ltcl_ implementation.

  method first_test.

    DATA: lt_testtab type STANDARD TABLE OF /bic/azbwhbt0100.

    lt_testtab = value #( ( /bic/zhbcurdat = 'fgfg' /BIC/ZHBTRDESC = '#FAGSJD**'  ) ).

    get REFERENCE OF lt_testtab into data(lr_tab).

    DATA(lobj_test) = new zcl_bw_validate_special( ir_ref = lr_tab ).

    lobj_test->validate( it_tab = lt_testtab ).

  endmethod.

endclass.

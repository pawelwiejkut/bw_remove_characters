CLASS zcl_bw_validate_special DEFINITION
PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    "! <p class="shorttext synchronized" lang="en"></p>
    "! Constructor class used for get fields and infoobjects based on result package reference
    "! @parameter ir_ref | <p class="shorttext synchronized" lang="en">Reference of result package</p>
    METHODS constructor
      IMPORTING !ir_ref TYPE REF TO data.

    "! <p class="shorttext synchronized" lang="en">Run validation and remove unsupported special charters</p>
    "!
    "! @parameter it_tab | <p class="shorttext synchronized" lang="en"> Income table, to be checked</p>
    "! @parameter et_tab | <p class="shorttext synchronized" lang="en"> Outcome table, special charters removed</p>
    METHODS validate
      IMPORTING !it_tab     TYPE ANY TABLE
                !it_monitor TYPE rstr_ty_t_monitors OPTIONAL
      EXPORTING !et_tab     TYPE ANY TABLE
                !et_monitor TYPE rstr_ty_t_monitors.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_iboj_tab,
        tab_name   TYPE string,
        field_name TYPE fieldname,
        iobj_name  TYPE string,
        validated  TYPE boolean,
      END OF ty_iboj_tab.

    TYPES: ty_t_range TYPE RANGE OF ty_iboj_tab-field_name.

    DATA:
      mt_objtab TYPE STANDARD TABLE OF ty_iboj_tab,
      mr_result TYPE REF TO data,
      mr_master TYPE REF TO data.

    METHODS exclude_tech
      EXPORTING
        et_excl_fields TYPE ty_t_range.

    METHODS check_and_replace
      IMPORTING iv_data      TYPE any
                iv_iobj_name TYPE string
                it_monitor   TYPE rstr_ty_t_monitors
      EXPORTING
                et_monitor   TYPE rstr_ty_t_monitors
                ev_replaced  TYPE string.
ENDCLASS.



CLASS zcl_bw_validate_special IMPLEMENTATION.


  METHOD check_and_replace.

    DATA:
      lv_current_char TYPE c,
      lv_objnam       TYPE rsd_iobjnm,
      lv_text         TYPE c LENGTH 255,
      lv_index        TYPE i.

    lv_text = iv_data.
    lv_objnam = iv_iobj_name.
    DATA(lv_length) = strlen( lv_text ).

    DO lv_length TIMES.

      lv_current_char = lv_text+lv_index(1).

      CALL FUNCTION 'RSKC_CHAVL_OF_IOBJ_CHECK'
        EXPORTING
          i_chavl           = lv_current_char
          i_iobjnm          = lv_objnam
        EXCEPTIONS
          chavl_not_allowed = 1.

      IF sy-subrc <> 0.
        et_monitor = VALUE #( BASE et_monitor ( msgv1 = |Char { lv_current_char } is unsupported and will be removed|  ) ).
        lv_text+lv_index(1) = ''.
      ENDIF.

      lv_index = lv_index + 1.

    ENDDO.

    ev_replaced = lv_text.

  ENDMETHOD.


  METHOD constructor.

    DATA: lr_tab        TYPE REF TO cl_abap_tabledescr,
          lr_str        TYPE REF TO cl_abap_structdescr,
          lt_excl_names TYPE RANGE OF ty_iboj_tab-field_name,
          lv_iobname    TYPE  rs_char30,
          ls_viobj      TYPE rsd_s_viobj,
          ls_iobj       TYPE rsd_s_iobj,
          lv_ddname     TYPE  rs_char30,
          lt_comptab    TYPE cl_abap_structdescr=>component_table,
          lr_newstr     TYPE REF TO cl_abap_datadescr.


    lr_tab ?= cl_abap_structdescr=>describe_by_data_ref( ir_ref ).
    lr_str ?= lr_tab->get_table_line_type( ).


    exclude_tech(
      IMPORTING
      et_excl_fields = lt_excl_names ).


    LOOP AT lr_str->get_components( ) ASSIGNING FIELD-SYMBOL(<ls_comp>) WHERE name NOT IN lt_excl_names.

      lv_ddname = <ls_comp>-name.
      CALL FUNCTION 'RSD_IOBJNM_GET_FROM_FIELDNM'
        EXPORTING
          i_ddname   = lv_ddname
        IMPORTING
          e_name     = lv_iobname.

      CALL FUNCTION 'RSD_IOBJ_GET'
        EXPORTING
          i_iobjnm         = lv_iobname
          i_objvers        = 'A'
        IMPORTING
          e_s_viobj        = ls_viobj
          e_s_iobj         = ls_iobj.

      APPEND VALUE #( field_name = <ls_comp>-name
                      iobj_name  = lv_iobname
                      tab_name   = ls_viobj-chktab )  TO mt_objtab.

      APPEND <ls_comp> TO lt_comptab.


    ENDLOOP.

    TRY.
        lr_newstr = cl_abap_structdescr=>create( lt_comptab ).
        DATA(lr_newtab) = cl_abap_tabledescr=>create( p_line_type = lr_newstr ).
      CATCH cx_sy_struct_creation.
      CATCH cx_sy_table_creation.
    ENDTRY.


    CREATE DATA mr_result TYPE HANDLE lr_newtab.


  ENDMETHOD.


  METHOD exclude_tech.

    et_excl_fields = VALUE #( ( low = 'REQTSN'     option = 'EQ' sign = 'I' )
                              ( low = 'REQUEST'    option = 'EQ' sign = 'I' )
                              ( low = 'DATAPAKID'  option = 'EQ' sign = 'I' )
                              ( low = 'RECORD'     option = 'EQ' sign = 'I' )
                              ( low = 'RECORDMODE' option = 'EQ' sign = 'I' ) ).

  ENDMETHOD.


  METHOD validate.

    DATA lv_cursor TYPE cursor.

    FIELD-SYMBOLS:
      <lt_result> TYPE STANDARD TABLE.

    ASSIGN mr_result->* TO <lt_result>.

    <lt_result> = CORRESPONDING #( it_tab ).

    LOOP AT mt_objtab ASSIGNING FIELD-SYMBOL(<ls_objtab>).

      LOOP AT <lt_result> ASSIGNING FIELD-SYMBOL(<ls_result>).

        ASSIGN COMPONENT <ls_objtab>-field_name OF STRUCTURE <ls_result> TO FIELD-SYMBOL(<lv_value>).

        IF <lv_value> IS NOT INITIAL.

          check_and_replace(
                       EXPORTING
                       iv_data      = <lv_value>
                       iv_iobj_name = <ls_objtab>-iobj_name
                       it_monitor   = it_monitor
                       IMPORTING
                       et_monitor = et_monitor
                       ev_replaced = <lv_value> ).

        ENDIF.

      ENDLOOP.

    ENDLOOP.

    et_tab = CORRESPONDING #( <lt_result> ).


  ENDMETHOD.
ENDCLASS.

CLASS zcl_bw_validate_special DEFINITION
PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS: constructor
      IMPORTING !ir_ref TYPE REF TO data.

    METHODS: validate
      IMPORTING !it_tab TYPE ANY TABLE
      EXPORTING !et_tab TYPE ANY TABLE.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_iboj_tab,
        tab_name   TYPE string,
        field_name TYPE fieldname,
        iobj_name  TYPE string,
        validated  TYPE boolean,
      END OF ty_iboj_tab.

    TYPES: t_ty_range    TYPE RANGE OF ty_iboj_tab-field_name.

    DATA:
      ot_objtab TYPE STANDARD TABLE OF ty_iboj_tab,
      or_result TYPE REF TO data,
      or_master TYPE REF TO data.

    METHODS exclude_tech
      EXPORTING
        exclude_fields TYPE t_ty_range.

    METHODS check_and_replace
      IMPORTING iv_data            TYPE any
                iv_iobj_name       TYPE string
      RETURNING VALUE(rv_replaced) TYPE string.
ENDCLASS.



CLASS ZCL_BW_VALIDATE_SPECIAL IMPLEMENTATION.


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
        MOVE '' TO lv_text+lv_index(1).
      ENDIF.

      lv_index = lv_index + 1.

    ENDDO.

    rv_replaced = lv_text.

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
      exclude_fields = lt_excl_names ).


    LOOP AT lr_str->get_components( ) ASSIGNING FIELD-SYMBOL(<ls_comp>) WHERE name NOT IN lt_excl_names.

      lv_ddname = <ls_comp>-name.
      CALL FUNCTION 'RSD_IOBJNM_GET_FROM_FIELDNM'
        EXPORTING
          i_ddname   = lv_ddname
        IMPORTING
          e_name     = lv_iobname
        EXCEPTIONS
          name_error = 1
          OTHERS     = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CALL FUNCTION 'RSD_IOBJ_GET'
        EXPORTING
          i_iobjnm         = lv_iobname
          i_objvers        = 'A'
        IMPORTING
          e_s_viobj        = ls_viobj
          e_s_iobj         = ls_iobj
        EXCEPTIONS
          iobj_not_found   = 1
          illegal_input    = 2
          bct_comp_invalid = 3
          OTHERS           = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      APPEND VALUE #( field_name = <ls_comp>-name
                      iobj_name  = lv_iobname
                      tab_name   = ls_viobj-chktab )  TO ot_objtab.

      APPEND <ls_comp> TO lt_comptab.


    ENDLOOP.

    TRY.
        lr_newstr = cl_abap_structdescr=>create( p_components = lt_comptab ).
        DATA(lr_newtab) = cl_abap_tabledescr=>create( p_line_type = lr_newstr ).

      CATCH cx_sy_struct_creation.
      CATCH cx_sy_table_creation.
    ENDTRY.


    CREATE DATA or_result TYPE HANDLE lr_newtab.


  ENDMETHOD.


  METHOD exclude_tech.

    exclude_fields = VALUE #( ( low = 'REQTSN'     option = 'EQ' sign = 'I' )
                              ( low = 'REQUEST'    option = 'EQ' sign = 'I' )
                              ( low = 'DATAPAKID'  option = 'EQ' sign = 'I' )
                              ( low = 'RECORD'     option = 'EQ' sign = 'I' )
                              ( low = 'RECORDMODE' option = 'EQ' sign = 'I' ) ).

  ENDMETHOD.


  METHOD validate.

    DATA:lv_cursor TYPE cursor.

    FIELD-SYMBOLS:

      <lt_result> TYPE STANDARD TABLE.

    ASSIGN or_result->* TO <lt_result>.

    <lt_result> = CORRESPONDING #( it_tab ).

    LOOP AT ot_objtab ASSIGNING FIELD-SYMBOL(<ls_objtab>).

      LOOP AT <lt_result> ASSIGNING FIELD-SYMBOL(<ls_result>).

        ASSIGN COMPONENT <ls_objtab>-field_name OF STRUCTURE <ls_result> TO FIELD-SYMBOL(<lv_value>).

        IF <lv_value> IS NOT INITIAL.

          <lv_value>  = check_and_replace(
              EXPORTING
                iv_data      = <lv_value>
                iv_iobj_name = <ls_objtab>-iobj_name
            ).

        ENDIF.

      ENDLOOP.

    ENDLOOP.

    et_tab = CORRESPONDING #( <lt_result> ).


  ENDMETHOD.
ENDCLASS.

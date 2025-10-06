CLASS zcl_insert_resason DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_INSERT_RESASON IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  DELETE FROM zpr_reason.
  DATA lt_boolean TYPE STANDARD TABLE OF zpr_reason.
    lt_boolean = VALUE #( ( value = 'Budget Exceeded' )
                            ( value = 'Duplicate PR' )
                            ( value = 'Incorrect Data' )
                            ( value  = 'Specification Missing/Incomplete' )
                            ( value = 'Non-Approved Vendor' )
                            ( value = 'Policy Violation' )
                            ( value = 'Not Required Anymore' )
                            ( value = 'Overestimated Quantity' )
                            ( value = 'Wrong Cost Center/GL Account' )
                            ( value = 'Urgency Not Justified' ) ).
    insert zpr_reason from table @lt_boolean.
    if sy-subrc eq 0.
    commit work.
    out->write( 'Successfully updated' ).
    endif.

  ENDMETHOD.
ENDCLASS.

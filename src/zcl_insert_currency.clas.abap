CLASS zcl_insert_currency DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_INSERT_CURRENCY IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
   DELETE FROM zpr_currency.
   DATA lt_boolean TYPE STANDARD TABLE OF ZPR_CURRENCY.
    lt_boolean = VALUE #( ( value = 'AUD' )
                           ( value = 'CAD' )
                           ( value = 'CHF' )
                           ( value = 'CNY' )
                           ( value = 'EUR' )
                           ( value = 'GBP' )
                           ( value = 'INR' )
                           ( value = 'JPY' )
                           ( value = 'NZD' )
                           ( value = 'USD' ) ).
    insert ZPR_CURRENCY from table @lt_boolean.
    if sy-subrc eq 0.
    commit work.
    out->write( 'Successfully updated' ).
    endif.

  ENDMETHOD.
ENDCLASS.

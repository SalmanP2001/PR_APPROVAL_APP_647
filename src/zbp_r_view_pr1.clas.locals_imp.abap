CLASS lhc_Z_R_VIEW_PR DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR z_r_view_pr RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR z_r_view_pr RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR z_r_view_pr RESULT result.

    METHODS AcceptPR FOR MODIFY
      IMPORTING keys FOR ACTION z_r_view_pr~AcceptPR RESULT result.

    METHODS CancelPR FOR MODIFY
      IMPORTING keys FOR ACTION z_r_view_pr~CancelPR RESULT result.

    METHODS RejectPR FOR MODIFY
      IMPORTING keys FOR ACTION z_r_view_pr~RejectPR RESULT result.

    METHODS SubmitPR FOR MODIFY
      IMPORTING keys FOR ACTION z_r_view_pr~SubmitPR RESULT result.
    METHODS Validate_Totalvalue FOR VALIDATE ON SAVE
      IMPORTING keys FOR z_r_view_pr~Validate_Totalvalue.
    METHODS Setprnumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR z_r_view_pr~Setprnumber.
    METHODS set_auto_fiscal_year FOR DETERMINE ON SAVE
      IMPORTING keys FOR z_r_view_pr~set_auto_fiscal_year.

ENDCLASS.

CLASS lhc_Z_R_VIEW_PR IMPLEMENTATION.

  METHOD get_instance_features.

   READ ENTITIES OF Z_R_VIEW_PR IN LOCAL MODE
      ENTITY Z_R_VIEW_PR
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_claim)
      FAILED failed.

    result = VALUE #( FOR claim IN lt_claim
                      ( %tky = claim-%tky

                        %action-AcceptPR = COND #( WHEN claim-Status = 'Approved' OR claim-Status = 'Rejected' OR claim-Status = 'Cancelled' OR claim-Status = 'Submitted'
                                                       THEN if_abap_behv=>fc-o-disabled
                                                       ELSE if_abap_behv=>fc-o-enabled  )

                       %action-RejectPR = COND #( WHEN claim-Status = 'Rejected' OR claim-Status = 'Approved' OR claim-Status = 'Cancelled'
                                                     THEN if_abap_behv=>fc-o-disabled
                                                     ELSE if_abap_behv=>fc-o-enabled )

                       %action-SubmitPR = COND #( WHEN claim-Status = 'Submitted'
                                                     THEN if_abap_behv=>fc-o-disabled
                                                     ELSE if_abap_behv=>fc-o-enabled  )

                      %action-CancelPR = COND #( WHEN claim-Status = 'Cancelled' OR claim-Status = 'Approved' OR claim-Status = 'Rejected'
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled )



                      ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.
****************************************** Actions **************************************

*=> Accept

  METHOD AcceptPR.

    MODIFY ENTITIES OF z_r_view_pr IN LOCAL MODE
      ENTITY z_r_view_pr
        UPDATE FIELDS ( Status RejectionReason )
        WITH VALUE #(
          FOR key IN keys
            ( %tky   = key-%tky
              Status = 'Approved'
              RejectionReason = ' ' ) )
      REPORTED reported
      FAILED   failed.


    READ ENTITIES OF z_r_view_pr IN LOCAL MODE
        ENTITY z_r_view_pr
          ALL FIELDS
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_leaves).


    result = VALUE #(
        FOR lr IN lt_leaves
          ( %tky   = lr-%tky
            %param = lr ) ).


  ENDMETHOD.

*=> Cancel

  METHOD CancelPR.


    MODIFY ENTITIES OF z_r_view_pr IN LOCAL MODE
      ENTITY z_r_view_pr
        UPDATE FIELDS ( Status )
        WITH VALUE #(
          FOR key IN keys
            ( %tky   = key-%tky
              Status = 'Cancelled' ) )
      REPORTED reported
      FAILED   failed.


    READ ENTITIES OF z_r_view_pr IN LOCAL MODE
        ENTITY z_r_view_pr
          ALL FIELDS
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_leaves).


    result = VALUE #(
        FOR lr IN lt_leaves
          ( %tky   = lr-%tky
            %param = lr ) ).

  ENDMETHOD.

*=>  Reject

  METHOD RejectPR.


    MODIFY ENTITIES OF z_r_view_pr IN LOCAL MODE
        ENTITY z_r_view_pr
        UPDATE FIELDS ( Status RejectionReason )
        WITH VALUE #(
          FOR key IN keys
            ( %tky             = key-%tky
              Status           = 'Rejected'
              RejectionReason = key-%param-rejection_reason )
        ).


    READ ENTITIES OF z_r_view_pr IN LOCAL MODE
    ENTITY z_r_view_pr
    ALL FIELDS WITH
    VALUE #( FOR key IN keys  ( %tky = key-%tky ) )
    RESULT DATA(lt_data).

    result = VALUE #(
      FOR wa_data IN lt_data
        ( %tky = wa_data-%tky %param = wa_data )
    ).

  ENDMETHOD.

*=> Submit

  METHOD SubmitPR.

    "==>reading the entity
    READ ENTITIES OF z_r_view_pr IN LOCAL MODE
   ENTITY z_r_view_pr
     ALL FIELDS
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_data).
    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>). " if we select multiple claim ,or else use one variable with claim 1

      "==> Check if claim has at least one item
      READ ENTITIES OF z_r_view_pr IN LOCAL MODE
        ENTITY z_r_view_pr BY \_Child
          FIELDS ( ItemId )
          WITH VALUE #( ( %tky = <fs_data>-%tky ) )
          RESULT DATA(lt_items).

      IF lt_items IS INITIAL.
        " No items → fail
        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-z_r_view_pr.
        APPEND VALUE #(
          %tky = <fs_data>-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = 'At least one item is required to submit the claim'
                 )
        ) TO reported-z_r_view_pr.
        CONTINUE.
      ENDIF.

      " Update claim status
      IF <fs_data>-Status = ''.
        MODIFY ENTITIES OF z_r_view_pr IN LOCAL MODE
          ENTITY z_r_view_pr UPDATE
            FIELDS ( Status )
            WITH VALUE #( ( %tky = <fs_data>-%tky Status = 'Submitted' ) ).

        " Return updated claim directly
        result = VALUE #( (
                    %tky   = <fs_data>-%tky
                    %param = CORRESPONDING #( <fs_data> EXCEPT Status )
                  ) ).
        result[ 1 ]-%param-Status = 'Submitted'.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

****************************************** Validation *****************************************
  METHOD Validate_Totalvalue.

    READ ENTITIES OF z_r_view_pr IN LOCAL MODE
              ENTITY z_r_view_pr
                FIELDS ( Totalvalue )
                WITH CORRESPONDING #( keys )
                RESULT DATA(lt_leaves).

    LOOP AT lt_leaves ASSIGNING FIELD-SYMBOL(<fs_leave>).
      IF <fs_leave>-Totalvalue > 50000.
        APPEND VALUE #(
         "%tky = <fs _ leave>-%tky
          %msg = new_message(
                   id       = 'ZMSG_06'
                   number   = '002'
                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-z_r_view_item.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD SetPrNumber.

    " Get the highest existing PR Id from DB
    SELECT MAX( prId )
      FROM z_r_view_pr
      INTO @DATA(lv_last_prid).

    " If no record found, start from 4069 so first becomes 4070
    IF lv_last_prid IS INITIAL.
      lv_last_prid = 4069.
    ENDIF.

    " Read the triggering items (the ones being created)
    READ ENTITIES OF z_r_view_pr IN LOCAL MODE
      ENTITY z_r_view_pr
      FIELDS ( PrId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).

      " Only assign PR Id if initial
      IF ls_item-PrId IS INITIAL.

        " Increment the last PR Id
        lv_last_prid = lv_last_prid + 1.

        " Update entity with new PR Id
        MODIFY ENTITIES OF z_r_view_pr IN LOCAL MODE
          ENTITY z_r_view_pr
          UPDATE FIELDS ( PrId )
          WITH VALUE #(
            ( %tky           = ls_item-%tky
              %data-PrId     = lv_last_prid
              %control-PrId  = if_abap_behv=>mk-on ) ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD set_auto_fiscal_year.
    DATA lt_pr TYPE TABLE FOR UPDATE z_r_view_pr.

    " Read the entities that triggered the determination
    READ ENTITIES OF z_r_view_pr IN LOCAL MODE
      ENTITY z_r_view_pr
        FIELDS ( PrId CreatedAt )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_pr>).

      " Step 1: copy CreatedAt into same type variable
      DATA(lv_year) = <fs_pr>-CreatedAt.

      " Step 2: convert to string
      DATA(lv_year_str) = |{ lv_year }|.

      " Step 3: take first 4 chars
      DATA(lv_fiscyear) = lv_year_str(4).

      " Step 4: append to RAP buffer table
      APPEND VALUE #(
        %tky       = <fs_pr>-%tky
        Fiscalyear = lv_fiscyear
      ) TO lt_pr.

    ENDLOOP.

    " Update the Fiscalyear back to RAP buffer
    MODIFY ENTITIES OF z_r_view_pr IN LOCAL MODE
      ENTITY z_r_view_pr
        UPDATE FIELDS ( Fiscalyear )
        WITH lt_pr
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported).

  ENDMETHOD.


ENDCLASS.

CLASS lhc_Z_R_VIEW_ITEM DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS Validate FOR VALIDATE ON SAVE
      IMPORTING keys FOR z_r_view_item~Validate.
    METHODS SetFiscalYear FOR DETERMINE ON MODIFY
      IMPORTING keys FOR z_r_view_item~SetFiscalYear.
    METHODS setNetValue FOR DETERMINE ON MODIFY
      IMPORTING keys FOR z_r_view_item~setNetValue.
    METHODS CalculateAmount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR z_r_view_item~CalculateAmount.
    METHODS Setprid FOR DETERMINE ON SAVE
      IMPORTING keys FOR z_r_view_item~Setprid.
    METHODS Setitemid FOR DETERMINE ON SAVE
      IMPORTING keys FOR z_r_view_item~Setitemid.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE z_r_view_item.

ENDCLASS.
************************************ Class of child *******************************
CLASS lhc_Z_R_VIEW_ITEM IMPLEMENTATION.

  "                  ***************************** Validation ***************************
  METHOD Validate.

    READ ENTITIES OF z_r_view_pr IN LOCAL MODE
     ENTITY z_r_view_item
     FIELDS ( Price Quantity )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_validate).

    LOOP AT lt_validate ASSIGNING FIELD-SYMBOL(<ls_validate>).

* Check Price > 0
      IF <ls_validate>-Price <= 0.
        APPEND VALUE #(
          %tky = <ls_validate>-%tky
          %element-Price        = if_abap_behv=>mk-on
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Price should be filled with positive number'
                 )

        ) TO reported-z_r_view_item.
      ENDIF.

* Check Quantity > 0
      IF <ls_validate>-Quantity <= 0.
        APPEND VALUE #(
          %tky = <ls_validate>-%tky
          %element-Quantity       = if_abap_behv=>mk-on
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Quantity must be greater than zero'
                 )

        ) TO reported-z_r_view_item.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD SetFiscalYear.

    DATA pr TYPE zpr_db-prnumber.

    LOOP AT keys INTO DATA(key).
      pr = key-Prnumber.
    ENDLOOP.

    SELECT * FROM zpr_db
    WHERE prnumber = @pr
    INTO TABLE @DATA(lt_table).

    LOOP AT lt_table ASSIGNING FIELD-SYMBOL(<fs_data>).

      MODIFY ENTITIES OF z_r_view_pr IN LOCAL MODE
      ENTITY z_r_view_item
      UPDATE FIELDS ( Fiscalyear )
      WITH VALUE #( FOR key1 IN keys ( %tky = key1-%tky
                                       Fiscalyear = <fs_data>-fiscalyear ) ).

    ENDLOOP.

  ENDMETHOD.

  METHOD setNetValue.

    READ ENTITIES OF z_r_view_pr IN LOCAL MODE
           ENTITY z_r_view_item
           FIELDS ( Price Quantity )
           WITH CORRESPONDING #( keys )
           RESULT DATA(lt_pr).

    LOOP AT lt_pr INTO DATA(ls_pr).
      DATA lv_netvalue TYPE z_r_view_item-Netvalue.
      lv_netvalue = 0.
      lv_netvalue = ls_pr-Quantity * ls_pr-Price.
      MODIFY ENTITIES OF z_r_view_pr IN LOCAL MODE
          ENTITY z_r_view_item
          UPDATE FIELDS ( Netvalue )
          WITH VALUE #(
            ( %tky       = ls_pr-%tky
              %data-Netvalue  = lv_netvalue
              %control-Netvalue = if_abap_behv=>mk-on ) ).

    ENDLOOP.

  ENDMETHOD.


  METHOD CalculateAmount.


    READ ENTITIES OF z_r_view_pr IN LOCAL MODE
      ENTITY z_r_view_pr
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_parents).

    SORT lt_parents BY %tky.
    DELETE ADJACENT DUPLICATES FROM lt_parents COMPARING %tky.

    "==>  Loop through each parent claim
    LOOP AT lt_parents ASSIGNING FIELD-SYMBOL(<fs_parent>).

      " Read child items for this parent
      READ ENTITIES OF z_r_view_pr IN LOCAL MODE
        ENTITY z_r_view_pr BY \_Child
          FIELDS ( Netvalue )
          WITH VALUE #( ( %tky = <fs_parent>-%tky ) )
          RESULT DATA(lt_items).

      " Calculate total
      DATA(lv_total) = REDUCE #( INIT sum = 0
                                 FOR <fs_item> IN lt_items
                                 NEXT sum = sum + <fs_item>-Netvalue ).

      " Update parent with calculated total
      MODIFY ENTITIES OF z_r_view_pr IN LOCAL MODE
        ENTITY z_r_view_pr
        UPDATE FIELDS ( Totalvalue )
        WITH VALUE #( (
          %tky = <fs_parent>-%tky
          Totalvalue = lv_total
          %control-Totalvalue = if_abap_behv=>mk-on
        ) ).

    ENDLOOP.


  ENDMETHOD.

  METHOD Setprid.

    DATA pr TYPE zpr_db-prnumber.

    LOOP AT keys INTO DATA(key).
      pr = key-Prnumber.
    ENDLOOP.

    SELECT * FROM zpr_db
    WHERE prnumber = @pr
    INTO TABLE @DATA(lt_table).

    LOOP AT lt_table ASSIGNING FIELD-SYMBOL(<fs_data>).

      MODIFY ENTITIES OF z_r_view_pr IN LOCAL MODE
      ENTITY z_r_view_item
      UPDATE FIELDS ( PrId )
      WITH VALUE #( FOR key1 IN keys ( %tky = key1-%tky
                                       PrId = <fs_data>-pr_id ) ).

    ENDLOOP.


  ENDMETHOD.


  METHOD Setitemid.

    " Get the highest existing PR Id from DB
    SELECT MAX( ItemId )
      FROM z_r_view_item
      INTO @DATA(lv_last_prid).

    "Assigning first value 4501
    IF lv_last_prid IS INITIAL.
      lv_last_prid = 4501.
    ENDIF.

    " Read the triggering items (the ones being created)
    READ ENTITIES OF z_r_view_pr IN LOCAL MODE
      ENTITY z_r_view_item
      FIELDS ( ItemId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).

      " Only assign PR Id if initial
      IF ls_item-ItemId IS INITIAL.

        " Increment the last PR Id
        lv_last_prid = lv_last_prid + 1.

        " Update entity with new PR Id
        MODIFY ENTITIES OF z_r_view_pr IN LOCAL MODE
          ENTITY z_r_view_item
          UPDATE FIELDS ( ItemId )
          WITH VALUE #(
            ( %tky           = ls_item-%tky
              %data-ItemId     = lv_last_prid
              %control-ItemId  = if_abap_behv=>mk-on ) ).

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD precheck_update.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_amt>).

      IF <fs_amt>-Price <= 0.
        APPEND VALUE #(
          %key    = <fs_amt>-%key
          %update = if_abap_behv=>mk-on
        ) TO failed-z_r_view_item.

        APPEND VALUE #(
          %key             = <fs_amt>-%key
          %msg             = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = |Prize must be greater than zero. Entered: { <fs_amt>-Price }|
                             )
          %update          = if_abap_behv=>mk-on
          %element-Price  = if_abap_behv=>mk-on
        ) TO reported-z_r_view_item.

      ENDIF.

      IF <fs_amt>-Quantity <=  0.
        APPEND VALUE #(
          %key    = <fs_amt>-%key
          %update = if_abap_behv=>mk-on
        ) TO failed-z_r_view_item.

        APPEND VALUE #(
          %key             = <fs_amt>-%key
          %msg             = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = |Quantity must be greater than zero. Entered: { <fs_amt>-Quantity }|
                             )
          %update          = if_abap_behv=>mk-on
          %element-Quantity  = if_abap_behv=>mk-on
        ) TO reported-z_r_view_item.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

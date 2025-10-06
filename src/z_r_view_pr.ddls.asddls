@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Root view'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z_R_VIEW_PR
  as select from Z_I_view_PR
  composition [1..*] of Z_R_VIEW_ITEM as _Child

//composition [0..*] of Z_R_ATTACHMENT as _Attachments
{
  key Prnumber,
      Fiscalyear,
      PrId,
      cast(case Status
      when 'Approved' then 3
      when 'Cancelled' then 2
      when 'Rejected' then 1
      when 'Submitted' then 3
      else 0
      end as abap.int4) as Statuscriticality,
      Status,
      CukyField,
      @Semantics.amount.currencyCode : 'CukyField'
      Totalvalue,
      RejectionReason,
      @Semantics.systemDateTime.createdAt: true
      createdat,
      @Semantics.user.createdBy: true
      createdby,
      Lastchangedby,
      Lastchangedat,
      Locallastchanged,

      _Child
//     _Attachments
}

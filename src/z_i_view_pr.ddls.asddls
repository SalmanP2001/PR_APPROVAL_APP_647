@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds i view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_I_view_PR as select from zpr_db
{
    key prnumber as Prnumber,
    fiscalyear as Fiscalyear,
    pr_id as PrId,
    status as Status,
    cuky_field as CukyField,
    @Semantics.amount.currencyCode : 'CukyField'
    totalvalue as Totalvalue,
    rejection_reason as RejectionReason,
    @Semantics.systemDateTime.createdAt: true
    createdat,
    @Semantics.user.createdBy: true
    createdby,
    lastchangedby as Lastchangedby,
    lastchangedat as Lastchangedat,
    locallastchanged as Locallastchanged
}

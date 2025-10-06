@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Root view'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_R_VIEW_ITEM as select from Z_I_VIEW_ITEM
association to parent Z_R_VIEW_PR as _Root on $projection.Prnumber = _Root.Prnumber 
{
    key Prnumber,
    key ItemNo,
    PrId,
    ItemId,
    Fiscalyear,
    Material,
    Quantity,
    @Semantics.amount.currencyCode : 'currency'
    Price,
    @Semantics.amount.currencyCode : 'currency'
    Netvalue,
    Currency,
  
    @Semantics.user.createdBy: true
    Createdby,
    @Semantics.systemDateTime.createdAt: true
    Createdat,
    Lastchangedby,
    Lastchangedat,
    Locallastchanged,
    _Root 
}

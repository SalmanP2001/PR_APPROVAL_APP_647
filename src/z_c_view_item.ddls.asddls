@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '${ddl_source_description}'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity Z_C_VIEW_ITEM 
as projection on Z_R_VIEW_ITEM
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
    Locallastchanged ,
   
  _Root : redirected to parent Z_C_VIEW_PR
}

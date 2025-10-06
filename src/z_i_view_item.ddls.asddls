@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'I view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_I_VIEW_ITEM as select from zitem_db
{
    key prnumber as Prnumber,
    key item_no as ItemNo,
    pr_id as PrId,
    item_id as ItemId,
    fiscalyear as Fiscalyear,
    material as Material,
    quantity as Quantity,
    @Semantics.amount.currencyCode : 'currency'
    price as Price,
    @Semantics.amount.currencyCode : 'currency'
    netvalue as Netvalue,
    currency as Currency,
    
    @Semantics.user.createdBy: true
    createdby as Createdby,
    @Semantics.systemDateTime.createdAt: true
    createdat as Createdat,
    lastchangedby as Lastchangedby,
    lastchangedat as Lastchangedat,
    locallastchanged as Locallastchanged
}





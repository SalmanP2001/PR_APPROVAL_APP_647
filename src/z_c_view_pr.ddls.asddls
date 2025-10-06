@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS C VIEW'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z_C_VIEW_PR 
provider contract transactional_query
as projection on Z_R_VIEW_PR
{
    key Prnumber,
    Fiscalyear,
    PrId,          
    Status,
    Statuscriticality,
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
    Locallastchanged ,
    _Child : redirected to composition child Z_C_VIEW_ITEM
}

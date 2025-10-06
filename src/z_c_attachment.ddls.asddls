@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'C view of attachment'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_C_ATTACHMENT as select from Z_R_ATTACHMENT
{

@UI.facet: [{
            id:'Attachment',
            purpose: #STANDARD,
            label: 'Attachment Information',
            type: #IDENTIFICATION_REFERENCE,
            position: 10
      }]
      
      @UI:{
              lineItem: [{ position: 10 }],
              identification: [{ position: 10 }]
          }
    key Itemno,
          @UI:{
              lineItem: [{ position: 20 }],
              identification: [{ position: 10 }] }
    Attachment,
    Mimetype,
    Filename
}

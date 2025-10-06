@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'r view attachment'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_R_ATTACHMENT as select from zpr_attachment
//association to parent Z_R_VIEW_PR as _Root on $projection.Itemno = _Root.
{   
    key itemno as Itemno,
     @EndUserText.label: 'Attachments'
      @Semantics.largeObject: {
      mimeType: 'Mimetype',
      fileName: 'Filename',
      contentDispositionPreference: #INLINE
      }
    
    attachment as Attachment,
    @EndUserText.label: 'File Type'
    mimetype as Mimetype,
    @EndUserText.label: 'File Name'
    filename as Filename,
    pr_id as PrId

}

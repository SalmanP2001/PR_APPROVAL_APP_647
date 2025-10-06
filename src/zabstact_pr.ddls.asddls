@EndUserText.label: 'Abstract Entity'
define abstract entity ZABSTACT_PR
{

@Consumption.valueHelpDefinition: [{ entity:{ name: 'Z_R_REASON', element: 'Value' } }]
  @EndUserText.label: 'RejectionReason'
 
    rejection_reason : abap.char(150);
    
}

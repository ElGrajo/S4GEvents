  
trigger OpportunityChangeTrigger on OpportunityChangeEvent (after insert) {

    //Si el trigger es sobre un objeto custom el formato es nombreObjeto__ChangeEvent por ej. Employee__ChangeEvent
    //El objeto tiene que estar seleccionado en Change Data Capture o Captura de datos de cambio.
    //El usuario tiene que tener permiso sobre el objeto y los campos que quiera ver los cambios.

    //Solo son after insert por el evento ya ha ocurrido.

    //El componente lightning para suscribirse a eventos: 
    //https://developer.salesforce.com/docs/component-library/bundle/lightning:empApi/documentation

    List<Task> tasks = new List<Task>();
    
    // Iterate through each event message.
    for (OpportunityChangeEvent event : Trigger.New) {
        
        // Get some event header fields
        
        EventBus.ChangeEventHeader header = event.ChangeEventHeader;
        System.debug('Received change event for ' + header.entityName + ' for the ' + header.changeType + ' operation.'); 
        // For updates, get all the fields that were explicitly set to null
        
        if (header.changetype == 'UPDATE') {
            // Get record fields and display only if not null.
            // Fields can be null either because they are set to null (see nulledFields header)
            // or if unchanged.
            System.debug('Employee Changed Record Fields');
            if (event.isWon != null && event.isWon == true) {
                // Create a followup task
                Task task = new Task();
                task.Subject = 'Follow up on won opportunities: ' + header.recordIds; 
                task.OwnerId = header.CommitUser; 
                tasks.add(task);
            }
            if (header.nulledFields.size() > 0) {
                System.debug('The following fields were set to null in the update operation:');
                for (String field : header.nulledFields) {
                    System.debug(field);
                }
            }
        } 
        
        // Insert all tasks in bulk.
        if (tasks.size() > 0) {
            insert tasks;
        }
    }
}

public with sharing class BulkTestCont {
    public SObject sObj {get;set;}
    public List<String> lFieldApiName{get;set;}
    public String selectedObject{get;set;}
    public Integer noOfRec{get;set;}
    public List<SelectOption> availableRecTypes{get;set;}
    public ID selectedRecType{get;set;}
    
    //display state housekeeping

    //public Boolean isDisabledNoOfRec{get;set;}
    public Boolean isVisibleCreate{get;set;}
    public Boolean isVisibleUpdate{get;set;}
    public Boolean isVisibleDelete{get;set;}

    
    private List<ID> lSobjIds;
    private Schema.SObjectType sObjType;
    private Boolean hasNameField;
    private Set<String>filterSObjects;
    
    public BulkTestCont(){
         lFieldApiName=new List<String>();
         noOfRec=1;
        lSobjIds=new List<ID>();
        availableRecTypes=new List<SelectOption>();
        hasNameField=false;
        filterSObjects=new Set<String>();
		filterSObjects.add('Lead');        
        //isDisabledNoOfRec=false;
        isVisibleCreate=false;
        isVisibleUpdate=false;
        isVisibleDelete=false;
    }
     public List<String> getFieldNames( Schema.SObjectType s ){
        List<String> result = new List<String>() ; 

        //Get the token for this object
       // Schema.SObjectType s = Schema.getGlobalDescribe().get(objName) ;
        Map<String, Schema.SObjectField> fMap = s.getDescribe().fields.getMap() ;
        List<Schema.SObjectField> fTokens = fMap.values() ;
        
         hasNameField= false;
        
         for( Integer i = 0 ; i < fTokens.size() ; i++ ){
            Schema.DescribeFieldResult f = fTokens.get(i).getDescribe() ;
            if(f.isHtmlFormatted())
                continue;
            
            if('Name'.equalsIgnoreCase(f.getName())){
                hasNameField= true;
              //  System.debug('$$$$$$method$$$'+hasNameField);
            }
            
           result.add(f.getName());
             
    
           
        }
         
         result.sort();
         return result ;
    } 
    public List<SelectOption> getSObjectNames(){
        List<SelectOption> options = new List<SelectOption>();
        List<String> lNames=new List<String>();
 		options.add(new SelectOption('', ''));
        for(String name : Schema.getGlobalDescribe().keySet()) {
        	
        	if (name.endsWithIgnoreCase('history') || name.endsWithIgnoreCase('share') || name.endsWithIgnoreCase('tag')) {
        		continue;
        	}
            	
        	if (name.equalsIgnoreCase('ApexComponent') || name.equalsIgnoreCase('ApexClass') || name.equalsIgnoreCase('ApexTrigger') || name.equalsIgnoreCase('ApexPage') || name.equalsIgnoreCase('ProcessInstance') || name.equalsIgnoreCase('ProcessInstanceHistory') || name.equalsIgnoreCase('ProcessInstanceStep') || name.equals('ProcessInstanceHistory') || name.equalsIgnoreCase('Document') || name.equalsIgnoreCase('DocumentAttachmentMap') || name.equalsIgnoreCase('Note') || name.equals('NoteAndAttachment') ||name.equalsIgnoreCase('EmailServicesAddress') || name.equalsIgnoreCase('EmailServicesFunction') || name.equalsIgnoreCase('EmailStatus') || name.equalsIgnoreCase('FiscalYearSettings') || name.equalsIgnoreCase('Folder') || name.equalsIgnoreCase('ForecastShare') || name.equalsIgnoreCase('Group') || name.equalsIgnoreCase('GroupMember')) {
        		continue;
        	}        	
       		lNames.add(name.capitalize());
           //  options.add(new SelectOption(name,name));
        }
        
        lNames.sort();
        
        for(String name : lNames){
            options.add(new SelectOption(name,name));
        }
        return options;
        
    }
    public PageReference selectObject(){

       sObjType=Schema.getGlobalDescribe().get(selectedObject);
      //  sObj = sObjType.newSObject() ;
      //  lFieldApiName=getFieldNames(sObjType);
    	availableRecTypes = getAvailableRecordTypeNamesForSObject(sObjType);
        
        lFieldApiName.clear();
       // isDisabledNoOfRec=false;
        isVisibleCreate=false;
        isVisibleUpdate=false;
        isVisibleDelete=false;
       
     
        return null;
        
    }
    

     public PageReference onSubmit(){
		
         if(!validateOnSubmit()){
             return null;
         }
		
        ID recTypeID= String.isNotBlank(selectedRecType)?selectedRecType:null;
         //System.debug('$$$$$$$$$$$$$$$selectedRecType' +selectedRecType);
        sObj = sObjType.newSObject(recTypeID,true) ;
        lFieldApiName=getFieldNames(sObjType);
         
         
        //isDisabledNoOfRec=true;
        isVisibleCreate=true;
        isVisibleUpdate=false;
        isVisibleDelete=false;

         
        return null;
        
    }
    
    private Boolean validateOnSubmit(){
        
        Boolean result=true;
        if(String.isBlank(selectedObject)){
           Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Choose an Object'));
            result=false;
        }
        
        if(noOfRec==null || noOfRec<=0){
             Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Choose a value > 0 for No. of Records'));
             result=false;
        }
        
        return result;
    }
    // Returns a List of the Names of all RecordTypes
// available to the running user for a given SOBject type
public  List<SelectOption> getAvailableRecordTypeNamesForSObject(Schema.SObjectType objType) {
   // List<String> names = new List<String>();
     List<SelectOption> options = new List<SelectOption>();
 	//options.add(new SelectOption('', ''));
    List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
    for (RecordTypeInfo i : infos) {
           if (i.isAvailable() &&  !String.valueOf(i.getRecordTypeId()).endsWith('AAA')){
                   options.add(new SelectOption(i.getRecordTypeId(),i.getName()));
               }
        }
    // If there are 2 or more RecordTypes...
    /*if (infos.size() > 1) {
        for (RecordTypeInfo i : infos) {
           if (i.isAvailable() 
           // Ignore the Master Record Type, whose Id always ends with 'AAA'.
           // We check the Id because Name can change depending on the user's language.
               && !String.valueOf(i.getRecordTypeId()).endsWith('AAA')){
                   options.add(new SelectOption(i.getRecordTypeId(),i.getName()));
                     //names.add();
               }
              
        }
    } 
    // Otherwise there's just the Master record type,
    // so add it in, since it MUST always be available
    else {
        options.add(new SelectOption(infos[0].getRecordTypeId(),infos[0].getName()));
       // names.add(infos[0].getName());
    }*/
    return options;
}
    

    public PageReference createRec(){
     
   
        
        lSobjIds.clear();
        
        List<SObject> lInsSObj=new List<SObject>();
        
        for(Integer i=0;i<noOfRec;i++){
        SObject obj=sObj.clone(false, true);
         System.debug('$$$$$$createRec$$$'+hasNameField);
           if(hasNameField && !filterSObjects.contains(selectedObject)){
           String s=i+'';
          
                 obj.put('Name', obj.get('Name')+s ); 
            }
       
        lInsSObj.add(obj);
        }
        
        Database.SaveResult[] srList =null;
        Long startTime=null;
        Long endTime=null;
        Long transTime=null;
        GovernorLimits startLimit=null;
        GovernorLimits endLimit=null;
        try{
            
            startLimit=new GovernorLimits(true);
            startTime=DateTime.now().getTime();
            
      	 	srList =Database.insert(lInsSObj,true);
            
            endTime=DateTime.now().getTime();
            transTime=(endTime-startTime);
            endLimit=new GovernorLimits(true);
            
        }catch(Exception e){    
			Apexpages.addMessages(e);            
        }
        
        if(srList==null)
            return null;
        
        for (Database.SaveResult sr : srList) {
            if(sr.isSuccess()){
               lSobjIds.add(sr.getId()) ;
            }
            else{
        // Operation failed, so get all errors                
        for(Database.Error err : sr.getErrors()) {
             Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,err.getStatusCode() + ' : ' + err.getMessage()));
            Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Fields that affected this error: ' + err.getFields()));
            //System.debug('The following error has occurred.');                    
            //System.debug(err.getStatusCode() + ': ' + err.getMessage());
            //System.debug('Fields that affected this error: ' + err.getFields());
        }
    }
}
        if(srList!=null &&srList.size()== lInsSObj.size()){
        
        Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,srList.size()+' record(s) created successfully. Transaction time = '+transTime+' ms'));  
        Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,(new GovernorLimits()).displayLimitResults(startLimit,endLimit)));   
       // isDisabledNoOfRec=true;
        isVisibleCreate=false;
        isVisibleUpdate=true;
        isVisibleDelete=true;

        }
        
        return null;
    }
    
    public PageReference updateRec(){
         List<SObject> lUpdSObj=new List<SObject>();
        Integer lIdSize=lSobjIds.size();
        for(Integer i=0;i<noOfRec;i++){
        SObject obj=sObj.clone(false, true);
        
            if(i<lIdSize){
                obj.put('Id', lSobjIds.get(i) );
            }   
            if(hasNameField && !filterSObjects.contains(selectedObject)){
        String s=i+'';
        obj.put('Name', obj.get('Name')+s );
            }
        lUpdSObj.add(obj);
        }
        
        Database.SaveResult[] srList =null;
         Long startTime=null;
        Long endTime=null;
        Long transTime=null;
           GovernorLimits startLimit=null;
        GovernorLimits endLimit=null;
        try{
            startLimit=new GovernorLimits(true);
            startTime=DateTime.now().getTime();
        srList =Database.update(lUpdSObj,true);
             endTime=DateTime.now().getTime();
            transTime=(endTime-startTime);
            endLimit=new GovernorLimits(true);
        }catch(Exception e){
            Apexpages.addMessages(e);
        }
        
         if(srList==null)
            return null;
        
        
        for (Database.SaveResult sr : srList) {
           if(!sr.isSuccess()){
        // Operation failed, so get all errors                
        for(Database.Error err : sr.getErrors()) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,err.getStatusCode() + ' : ' + err.getMessage()));
            Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Fields that affected this error: ' + err.getFields()));
            
          //  System.debug('The following error has occurred.');                    
          //  System.debug(err.getStatusCode() + ': ' + err.getMessage());
          //  System.debug('Fields that affected this error: ' + err.getFields());
        }
    }
        }
        
        if(srList!=null &&srList.size()== lUpdSObj.size()){
        
         Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,srList.size()+' record(s) updated successfully. Transaction time = '+transTime+' ms'));    
         Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,(new GovernorLimits()).displayLimitResults(startLimit,endLimit)));  
        }
        return null;
    }
    public PageReference deleteRec(){
		List<SObject> lDelSObj=new List<SObject>();
        Integer lIdSize=lSobjIds.size();
        for(Integer i=0;i<noOfRec;i++){
        SObject obj= sObjType.newSObject();
        
            if(i<lIdSize){
                obj.put('Id', lSobjIds.get(i) );
            }   
        
        lDelSObj.add(obj);
        }
        
        Database.DeleteResult[] srList =null;
         Long startTime=null;
 			Long endTime=null;
 			Long transTime=null;
           GovernorLimits startLimit=null;
        GovernorLimits endLimit=null;
        try{
            startLimit=new GovernorLimits(true);
            startTime=DateTime.now().getTime();
         srList =Database.delete(lDelSObj,true);
            endTime=DateTime.now().getTime();
            transTime=(endTime-startTime);
            endLimit=new GovernorLimits(true);
            
        }catch(Exception e){
             Apexpages.addMessages(e);
        }
        
         if(srList==null)
            return null;
        
        for (Database.DeleteResult sr : srList) {
            if(!sr.isSuccess()){
              // lSobjIds.add(sr.getId()) ;
             for(Database.Error err : sr.getErrors()) {
             Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,err.getStatusCode() + ' : ' + err.getMessage()));
            Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Fields that affected this error: ' + err.getFields()));
           // System.debug('The following error has occurred.');                    
           // System.debug(err.getStatusCode() + ': ' + err.getMessage());
           // System.debug('Fields that affected this error: ' + err.getFields());
            }
            }
    }
        if(srList!=null &&srList.size()== lDelSObj.size()){
        
         Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,srList.size()+' record(s) deleted successfully. Transaction time = '+transTime+' ms'));    
 		Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,(new GovernorLimits()).displayLimitResults(startLimit,endLimit)));   
            //isDisabledNoOfRec=false;
        isVisibleCreate=false;
        isVisibleUpdate=false;
        isVisibleDelete=false;
 		lSobjIds.clear();
        lFieldApiName.clear();    
        }
       
        return null;
    }
   
    
    class GovernorLimits{
        Integer aggregateQueries;
        Integer callouts;
        Integer cpuTime;
        Integer dMLRows;
        Integer dMLStatements;
        Integer emailInvocations;
        Integer futureCalls;
        Integer heapSize;
        Integer mobilePushApexCalls;
        Integer soqlQueries;
        Integer queryLocatorRows;
        Integer soqlqueryRows;
        Integer queueableJobs;
        Integer soslQueries;
        
        GovernorLimits(Boolean autoSet){
            if(autoSet){
            aggregateQueries= Limits.getAggregateQueries();
             callouts= Limits.getCallouts();
             cpuTime= Limits.getCpuTime();
             dMLRows= Limits.getDMLRows();
             dMLStatements= Limits.getDMLStatements();
             emailInvocations= Limits.getEmailInvocations();
             futureCalls= Limits.getFutureCalls();
             heapSize= Limits.getHeapSize();
             mobilePushApexCalls= Limits.getMobilePushApexCalls();
             soqlQueries= Limits.getQueries();
             queryLocatorRows= Limits.getQueryLocatorRows();
             soqlqueryRows= Limits.getQueryRows();
             queueableJobs= Limits.getQueueableJobs();
             soslQueries= Limits.getSoslQueries();  
            }
        }
        GovernorLimits(){
         

        }
        
        String displayLimitResults(GovernorLimits startLimit,GovernorLimits endLimit){
             String result='';
            
            if(startLimit==null || endLimit==null)
                return result;
           
            result+= 'Number of SOQL queries: '+(endLimit.soqlQueries-startLimit.soqlQueries)+' out of '+Limits.getLimitQueries()+'<br/>';
            result+= 'Number of query rows: '+(endLimit.soqlqueryRows-startLimit.soqlqueryRows)+' out of '+Limits.getLimitQueryRows()+'<br/>';
            result+= 'Maximum CPU time: '+(endLimit.cpuTime-startLimit.cpuTime)+' out of '+Limits.getLimitCpuTime()+'<br/>';
            result+= 'Number of DML rows: '+(endLimit.dMLRows-startLimit.dMLRows)+' out of '+Limits.getLimitDMLRows()+'<br/>';
            result+= 'Number of DML statements: '+(endLimit.dMLStatements-startLimit.dMLStatements)+' out of '+Limits.getLimitDMLStatements()+'<br/>';
            result+= 'Maximum heap size: '+(endLimit.heapSize-startLimit.heapSize)+' out of '+Limits.getLimitHeapSize()+'<br/>';
            result+= 'Number of queueable jobs added to the queue: '+(endLimit.queueableJobs-startLimit.queueableJobs)+' out of '+Limits.getLimitQueueableJobs()+'<br/>';
            
            result+= 'Number of Webservice callouts: '+(endLimit.callouts-startLimit.callouts)+' out of '+Limits.getLimitCallouts()+'<br/>';
            
            
            result+= 'Number of Email Invocations: '+(endLimit.emailInvocations-startLimit.emailInvocations)+' out of '+Limits.getLimitEmailInvocations()+'<br/>';
            result+= 'Number of future calls: '+(endLimit.futureCalls-startLimit.futureCalls)+' out of '+Limits.getLimitFutureCalls()+'<br/>';
            result+= 'Number of aggregate queries: '+(endLimit.aggregateQueries-startLimit.aggregateQueries)+' out of '+Limits.getLimitAggregateQueries()+'<br/>';
            result+= 'Number of Mobile Apex push calls: '+(endLimit.mobilePushApexCalls-startLimit.mobilePushApexCalls)+' out of '+Limits.getLimitMobilePushApexCalls()+'<br/>';
            
            result+= 'Number of Database.getQueryLocator() rows: '+(endLimit.queryLocatorRows-startLimit.queryLocatorRows)+' out of '+Limits.getLimitQueryLocatorRows()+'<br/>';
            
            
            result+= 'Number of SOSL queries: '+(endLimit.soslQueries-startLimit.soslQueries)+' out of '+Limits.getLimitSoslQueries()+'<br/>';
            
            return result;
        }        
    }
}
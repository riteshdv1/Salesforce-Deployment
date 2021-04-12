public with sharing class JobAttachments {
    @testVisible private Map<Id, List<Attachment>> attachmentMap;
    public JobAttachments(){
        attachmentMap = new Map<Id, List<Attachment>>();
    }

    public Attachment getByName(String name, Id parentId){
        return getByName(name, getByParent(parentId));
    }

    public Attachment getByName(String name, List<Attachment> attachmentList){
        if(attachmentList == null){
            return null;
        }
        for(Attachment file : attachmentList){
            if(file.name.equalsIgnoreCase(name)){
               return file;
            }
         }
        return null;
    }

    public List<Attachment> getByParent(Id parentId){
       if(this.attachmentMap.containskey(parentId)){
          return this.attachmentMap.get(parentId);
       }
        return null;
    }

    public void loadAll(List<Id> parentIds){
        List<Attachment> attachmentList = [SELECT Id,Name,Body,ParentId FROM Attachment Where ParentId IN: parentIds];
        for(Attachment file : attachmentList){
           List<Attachment> tempList = attachmentMap.containsKey(file.parentId) ? attachmentMap.get(file.parentId) : new List<Attachment>();
           tempList.add(file);
           attachmentMap.put(file.parentId, tempList);
        }
    }
}
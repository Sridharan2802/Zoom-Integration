/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class accountHelper {

@AuraEnabled(cacheable=true)
public static List<Account> getAccounts(String searchKey) {
    // Base query
    String query = 'SELECT Id, Name, Industry, Type FROM Account';
    
    // Add search filter if provided
    if (searchKey != null && searchKey.trim() != '') {
        String key = '%' + searchKey + '%';
        query += ' WHERE Industry LIKE :key';
    }
    
    // Add limit
    query += ' LIMIT 10';
    
    // Execute the query
    return Database.query(query);
}

@AuraEnabled
public static List<Account> getAccountsByIndustry(String industry) {
    
    return [

        SELECT Id, Name, Industry, Phone, Website
        FROM Account
        WHERE Industry = :industry
    ];
}

@AuraEnabled
public static List<Account> getAccountRecords() {
    return [SELECT Name, Industry, Phone FROM Account LIMIT 1];
}

   
}
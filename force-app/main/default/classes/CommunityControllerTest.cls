@IsTest
public class CommunityControllerTest {
    @TestSetup
    static void dataSetUp(){
        
        List<Product2> products = new List<Product2>();
        for(Integer i = 0; i < 10; i++){
            Product2 product = new Product2(
                Name = 'Test Product' + i,
                Model__c = 'Suv',
                Brand__c = 'Toyota',
                Color__c = 'Red',
                Price__c = 300000,
                DisplayUrl = 'www.salesforce.com',
                IsActive = true);
                products.add(product);
            Product2 noActiveProduct = new Product2(
                Name = 'Test Product' + (4+i),
                Model__c = 'Car',
                Brand__c = 'MG',
                Color__c = 'Blue',
                Price__c = 280000,
                DisplayUrl = 'www.salesforce.com',
                IsActive = false);
                products.add(noActiveProduct);
        }
        insert products;

        //////////////////////////////////////////

        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i < 10; i++){
            Lead lead = new Lead(
                FirstName = 'Test' + i,
                LastName = 'Lastname',
                Email = ('Leadtest' + i + '@test.com'),
                Company = 'Testing',
                City = 'Merida',
                State = 'Yucatan',
                LeadSource = 'WebToLead');
                leads.add(lead);
        }
        insert leads;

        Profile profile = [SELECT Id FROM Profile WHERE Name='Community User'];
        
        List<User> users = new List<User>();
        for(Integer i = 0; i < 3; i++){
            User adminUser = new User(
                Alias = 'aUser', 
                Email='adminuser@test1.com',
                EmailEncodingKey='UTF-8', 
                LastName='Admin', 
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', 
                ProfileId = profile.Id,
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='auser012522' + i + '@test.com');
                users.add(adminUser);
        }
        insert users;
    }

    
    @isTest
    public static void getActiveProductsTest(){
        Test.startTest();
        List<Product2> getActiveProducts = CommunityController.getActiveProducts();
        Test.stopTest();
        System.assertEquals(10, getActiveProducts.size(), 'There are not 10 products displaying');
    }

    @isTest
    public static void getAllCarsTest(){
        Test.startTest();
        List<Product2> getAllCars = CommunityController.getAllCars();
        Test.stopTest();
        System.assertEquals(20, getAllCars.size(), 'There are not 20 Cars');
    }

    public static void getCarsTest(){
        Test.startTest();
        List<Product2> getCars = CommunityController.getCars();
        Test.stopTest();
        System.assertEquals(10, getCars.size(), 'There are not 10 products displaying');
    }

    @isTest
    public static void getAvailableCarsTest(){
        Test.startTest();
        List<Product2> getAvailableCars = CommunityController.getAvailableCars('Suv', 'Toyota', 'Red');
        Test.stopTest();
        System.assertEquals(10, getAvailableCars.size(), 'There are not 10 Available Cars');
    }

    @isTest
    public static void getWebToLeadLeadsTest(){
        Test.startTest();
        List<Lead> getWebToLeadLeads = CommunityController.getWebToLeadLeads();
        Test.stopTest();
        System.assertEquals(10, getWebToLeadLeads.size(), 'There are not 10 Leads with LeadSource called WebToLeadLeads');
    }

    @isTest
    public static void leadToUptTest(){
        Lead leadToTest = [SELECT Id, FirstName, LastName, Email, Company, City, State FROM Lead LIMIT 1];
        Id leadId = leadToTest.Id;
        String fname = 'Hola';
        Test.startTest();
        CommunityController.leadToUpt(leadToTest.Id,fname,leadToTest.LastName,leadToTest.Email,leadToTest.Company,leadToTest.City,leadToTest.State);
        Lead finalLead = [SELECT Id, FirstName, LastName, Email, Company, City, State FROM Lead WHERE Id = :leadId];
        Test.stopTest();
        System.assertEquals('Hola', finalLead.FirstName, 'The Firstname is not Hola');
    }

    @isTest
    public static void assignUserTest(){
        Lead leadToTest = [SELECT Id, Name, OwnerId FROM Lead LIMIT 1];
        Id userId = [SELECT Id, Name, UserName FROM User WHERE UserName = 'auser0125222@test.com'].Id;
        Id leadId = leadToTest.Id;
        Test.startTest();
        CommunityController.assignUser(leadId,userId);
        Lead finalLead = [SELECT Id, Name, OwnerId FROM Lead WHERE Id = :leadId];
        Test.stopTest();
        System.assertEquals(userId, finalLead.OwnerId, 'The Lead Owner does not changed');
    }

    //Debe estar el LeadToUptTest//

    @isTest
    public static void getAdminUsersTest(){
        List<User> users = [SELECT Id, Name, Email FROM User WHERE Email = 'adminuser@test1.com'];
        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Admin_User'];
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();

        for(Integer i = 0; i < users.size(); i++){
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
            permissionSetAssignment.AssigneeId = users[i].Id;
            permissionSetAssignment.PermissionSetId = permissionSet.Id;
            permissionSetList.add(permissionSetAssignment);
        }
        insert permissionSetList;
        Test.startTest();
        List<PermissionSetAssignment> getAdminUsers = CommunityController.getAdminUsers();
        Test.stopTest();
        System.assertEquals(5, getAdminUsers.size(), 'There are not 5 Users with Admin_user permissionSet');
    }

    @isTest
    public static void isAdminTest(){
        Profile profile = [SELECT Id FROM Profile WHERE Name='Community User'];

        User adminUser = new User(Alias = 'aUser', Email='adminuser@test.com',
                          EmailEncodingKey='UTF-8', LastName='Admin', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = profile.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='auser012522@test.com');
        insert adminUser;

        User clientUser = new User(Alias = 'cUser', Email='clientuser@test.com',
                          EmailEncodingKey='UTF-8', LastName='Client', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = profile.Id,
                          TimeZoneSidKey='America/Los_Angeles',     UserName='cUser012522@test.com');
        insert clientUser;
        
        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Admin_User'];
       
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
        permissionSetAssignment.AssigneeId = adminUser.Id;
        permissionSetAssignment.PermissionSetId = permissionSet.Id;
        insert permissionSetAssignment;

        Test.startTest();
        User admin = [SELECT Id, Name, Email FROM User WHERE Email = 'adminuser@test.com'];
        Boolean adminPositive = CommunityController.isAdmin(admin.Id);
        User client = [SELECT Id, Name, Email FROM User WHERE Email = 'clientuser@test.com'];
        Boolean adminNegative = CommunityController.isAdmin(client.Id);
        Test.stopTest();
        System.assertEquals(true, adminPositive, 'It is a client user');
        System.assertEquals(False, adminNegative, 'It is an admin user');
    }


    @isTest
    public static void uploadFileTest(){
        String base64 = '/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAoHCBYWFRgWFhYZGRgaHBoeHBwcHB4cHBwcHBwaHBoaGhwjJC4lHiErHxwcJjgnKy8xNTU1HCQ7QDs0Py40NTEBDAwMEA8QHhISHjQhISQ0NDQ0NDQ0NDQ0NDQ0NDE0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDE0NDQ0P//AABEIALcBEwMBIgACEQEDEQH/xAAcAAABBQEBAQAAAAAAAAAAAAADAAIEBQYBBwj/xABHEAACAQIEAgcEBggEBAcBAAABAhEAAwQSITFBUQUiYXGBkaEGE7HRFDJCUsHwYnKCkqLS4fEHFRayM5PC4iM0RFNUY4ND/8QAGAEBAQEBAQAAAAAAAAAAAAAAAAECAwT/xAAgEQEBAAIBBQEBAQAAAAAAAAAAAQIREgMTITFBUWEi/9oADAMBAAIRAxEAPwDWe7pwSpowp5UVMLXB02gC1T1sGrJcNRFtRTVOSvXD9lEXDVPy0G9dRPrMAeXHy3pxOVCFimupFAu9JD7Kk9p0Hlv8KgX8Y7btpyXT+vrUWbWbYhV+swHx8qC/Sg+ypPadB86qVB4CussfWMelPLWokXsa7cY7F09d6jEfk04N91SfCPU0vdseQ9T5n5U0vKQPLTDl56+Zo/0ccZbvP4bURbcbCKcTmiZTwXz09K77kndvLT13qdaVZ68x2UK+6AnKSRV4pzRlsKOGvM6+tPyUG/0iqidAObEAVUYn2mtgxnB7EBb1GnrTgdxpTYTJmzjN90g+U1XXLyDc1lcR7Tz9VGP6xA9BPxqFc6YvvoMqdyyfNpq3GJMsq1z4wfZUmoGJ6WC/WdE7JE+W/pWVu27j/XdyORJjy2omL6G92qNntuGH2HDQd9V3HiKbxi6yqwxHtAn3nf8AVED1j4VXXOn2M5EA7WJb4RUX6MPGnpY0HDU1OUWdNy5j77buVH6ML6jX1qJdtMxBJJ13Op2O5NTxZ/O/OnrhiSPqjc6sFGgPFiBU5t8Irxh6IbXMVKAHAg92vwrgWRME98fj8qzzrUxiLkEnTlThbopDTIAHDWY0nup6pKkzwOwEaedS1ZiCLXZ+e6hXdGMxsN45mppw/OSe0mPKmG2V2A8uFSZLcTbaoUks+bgAhK+L5hHlQB3Ed8D+tTQJ3oS2wR+e2kyLiBmP6P7xpUb3fYfKu1dmn0ILApe6qnTptgNQvfE/A0y9jWb7Rg8PqjyFd9x4+NWl68ibsO7c+Q1qHd6SH2VntbT0H9KrXYDcx2bf38q4CeCnvOnx19Km7TwJexTt9qByXT139ajhD2CjC2x7O4SfM/KnrhZ3E/rSfTamjkh5Rzzd2vw0rotngoHefwHzqc6AbkCo9zEqPz86cS5B/Ryd2PcOqPn60VsFk1yxPH+tVOJ9oLSTLoI4A5j5Cq3E+2C/VUO/8I+fpV4py/GmIA3IFJMUi7jNWMt9LYi7ORFQeLHeNzp6VDv+/Zgty8ygxMdUAc4WKskLyrZYrpRE1JVB+kQPjvVLivai39lmb9RfxMA+dZ+/0OquMrpcnUMubeeOYAzVl/lGUZipHHbz/PbS2QmNv1GxHtM5+pbA7WJPoI+NQHx+JuGM5Ucl6vLY/W9atLd90QoApQ75kVuESCRI7xQMMilhqOWnWI24CTUuTWOEQ16KLdZySeZMnzOvKjYPA2Aze9DxwKZdDpuGGvmK0r4VVH2m0GoGUceDdbhy4VSYm2wJ6qxzkn8BXPnXXhFbfwgB6uojiNeUxVn0d0UXAOw50OxhmaM23ICN/Wtz0J0GGSXEzzJb41jLK3w3NSbrI4/ofIA2dDP6S5tuKgk1T3IyjfQRAH4mK33TPRoRoAgcu2sticJxB1+J41nk1JvypVUkSFHCJIG/dM10W37Bvwk77SanW0EUXJAmlyamKqFljoSeHGPhFEOGUAGBP53PhVh7oDyHHv2prAcfSs3KrqIYSPztw0p9vDCB3D4UYqo1+NMOJQRLJsPtA99TzfRuT2a+FB0O9NOEIVoECGPpx8vjTG6ST73kp+UUJ+lFIIAc6dgHxNWY5HLH9SPo5j5Vx7McOeunwNRW6YPBB4sTUZ+kbh2yjuG3nSdPJe7jE9rQjWgDYaH+lV1zEXDu58NPhUK6ebT3ma6Y9K/a5ZdWfIuc47K7WdzCuVvtf1z7/wDH0Pcs2SkqCG4/3FAW2Obef59aKbBFdW2a62vPDVRRwA9KV6+EElWI5iI8ddKHiMVbT67ovYWAPlvVJ0v03h3tvbRi7OCBCmJPMmPSm11UnE+1lpNMyzyHXP8ADoKpcV7aMdERj+sQo9JqlXCgbwO/xqZgMLacw7sojdULjsnWnJeH6FienMS+xCdwk+s1X3Q7/Xd27GJI8tqtLuFIJC6gEwTpPlNBbDttp+eX9qzcm8cIrvow4CpiYM7kEDmRFHRSNMzAGNjHPlFS+i0zOoIWd5I7uNZuTUwaf2d6OQWyTrPLX4aVVe0HRxViwU5e2PmfhW06NQ5BPzqp6cIDQ2xOnl/SnzbM85aY7ojDM7rCqNRBIYkd2oHnWrxeAIXrM50HGNY/Rg1z2ZwgJkbACNKo/a/2/RHaxYQXChh3ZiFDDQqgGrREEyBynekxuXoyymNQMVghm0HEb6n11qZhsIRqIbu7+ANYnE+1mIfbIv6qE/E1Cfp3Et//AGcfqwvwrXZyvunexnqPWFWVk6dUb/tfOqrFPb2LoO3MK8wfFO27uT2saEznjJ8T86Tof1O//HqGAxuHVlz3FVQBzPLkK1lv236PRcvv9uSP+K18/lxyHxpZ+weQ+Vbx6Ml2xl1ssvD2/pb21wDrC3CT3R8SKy97phGMh1AniRPiBNedC4fzFSrYzMkfpHty6AT6+VL0cbd0nWyk1GvuYpNP/FB0+yrieMzlob4pD9uP2GPhwrGYlxMkkDhAkkAkZjqNzMdlDW6OFxx+z8np2cPw72f62/0lOFz+Ej8DVa3vG3vKe4svwUVn0vf/AGt/GPgxotu+4ZczNlaYIJ1gE/aG+nKrOnhPhernfq1OCY8VP7Q/GK4cC/Ke5lPwNViYx/8A3MupGoXUjeOqTRR0k4+2h7yo+Va4Ysc8k5cE/wBx/wB011bBGhhT26VETpa991D3a+UMaMvtK4AlARJH1mGoiRBB+8KzcJ+tTOz3E/DYNGOtz90A8++tZ0b7Go6hirkHUZnCDvgLNY3De1AUyLYB7AjH1ArSYD/EgoACkjtU/FGI9K5ZdHK3xfDp3sdemkT2HtBf+Gk8yzv6MQKqOlfZfIG92EBnYIF4KYmSeNaP2a9t7GLf3QGRyJAJPWjUgSAZifKrfpDChgdPzArnnhcfTWPU28OvYW4GII9KVb7FYBc7SDv92lWe868MXoYSsH7W5/pDqHYLlXqhjl+qCdNq21jpC02guIT2OvzrJ+01lWxLnQ9VO37IrvlfDz4TdZYYQbaT8daKmDh1DKwnmGGneRVrbtgHkI4eFTLd1HZFN4lpgI0GJP2esfhXO5O3FVjAqNgBJOwphw8NA5DbvNTOmZRWysZH1QMs+cVkcR0gxOXrlpMyzR5R3+dTHeX0up8Xl+ROwjUgmNfxGlC+l2wOs6z+jrHlNZ+6CurCPAk/AV3ot89wBGuBhOqQpEAkmZ00rfGa9s8rvUi+94D11DFSND58zPGp+ABBEAD19I/GqwqwUyzMebGSddSTVvgsKuYHTTeTHrXK11mPjy3WAVsg60dwAPjOas/7Zo/u5QuXJAECTE6wFH4VfdH3UCLDrtsDP9ar+n+kbdtGZzAAnVWBPYJAknauvnUef7Xl+O6Xe2hRbjtcYlYzHqcCSOB4D+lZq5YA4kkb99TsVfa473isF2JAGwk8O6objKD26duhBn0jzr04zUcLd1Fil7v8604U4VTQJGsUlE8aJl1PjTUSKrJOgJ0gD860z3fdRStJbZJ6onuqKElsnarDDLlR3H6id40HgW/3UJLDKCSCDGmnE6KfPXuBp16+JSyu1uSTzYD8GjxBoRWYlCG7NAO5QAPhQ8pq2PQeJbfIBOkkAdnCm3sFltsVyvkIzuIhSdFAjgTAk7yI50FWAavblsfR7bcVuLJ7AcseRqlt6sBzIFXrrOGvL90mP2Xn8BUFLiF9GY/vBT+JoMUfFHVjzyn/AHD8BUajQ9wTbT9FnXzyt+Jo+PSCI2YI4/bWG9QKjoZRhyZT5hh+AqRizNu0f0WXybT/AGmqIgFIGmingTPZUE3ojpBrF+3dU/UdW8mX012r6NcFlzB9GAIKgDQgEbzwr5nRJQntj0P4la9/9icd77o+w53CZD2FOqP4QDXLqTxtvD2V3DGT138rf8lKpMg8fj8qVeXw9Gnkt7AHKGy7xyiIrT+zuFjDJw/4n+88PGszculQBmbTgdogdvpFbboC0zYZGzcX7PtkV6Ot4xcujrkY9pUZTCtrtO+uxiDUbEqPpWGdFykuqlQSVgAkEA6z4xVjj8KZUKCSZjjJ00FV9u1kv4Zrq5FF1ZZuqAACNSdIrzyvRlPC16VwhmTrm35DsPfULC+zDMQOrJM/WJOuo3Hf5Vc9KdJ4eAFvIxnYMDEAxt31JwvS9pPrZtBwR9dOGkDfnXOc/Ui3LGY7UWP9nwVI64I+8qxppwaY8KrvZXosrfu9QnKrg6Rpk7Y41pL/ALS2WP1rdtZOty4gO5iEUtw5kVXWum8NbLlcTalxDEa6REAcNK749PqXcvpxvUx9/UNsKFMRPZv3AVZdG4aGB7Ozmu3w/vVa3TuGG2JG0aISY7yTQ29pcOP/AFLeFofy1Z0MvtXLrz5G7fpKzZVffXUtg7Z3VJiJgsddx514d0l0y+IYveADuSxg8CfqjMwju5Za1d32mw0z7xyRsfdgHwOXSomJ9scONC+JbsR8nwr04Y8Y82WW2WfEyOqvCAJXzENqfnTblkwDlOYiYJjQaSGAIiZ5bHlVrc6ewxllwt1p+099zJ7erXB7QH7GGtj9brHz0remFN7ncQAe2T8CK4bcfdHbDfiTV5/n186BUX9UEfjTWx99tCR+6Pidaaq7UlskTJnnC694Jkfh3UUp905p10VQQO4AVPTDckQdyIP+mi/Q53RD+wvyppNqksRvm+FcTEoWygMWmI18dxFXC9Gr9xfBQPgKQ6PRSGygEaggmRHHs/rV0K+6+VC5WAmoHMmRJPPw48ONVg7g94Q27CAe066+JPlU7pu7ICLxYsQNe789lP6F6VxCs1q1e92LjZj1igzHTcCdo00GlZt8rPQVy2gA94b5E7MpC79bKYg8prgxiJbe3bPVuhQ4ZSD1GLqVY8iAPE6camYtMaW66u8cSHcRPME/Go+XEf8Axx/y7vzooFjCKq5mGsrE8JYfgDVpZXNYv6iCz9+qk1Dz4jY2BHaj/iaFea+VKizlBnZHG4g9m2lVnVVrvoP1QPKPmaDNTFwrqVOSY3BBgg8D2cKOzrxw4HcwH/RUaQrR6jjsU+TAf9VSGtscOjZTlDMM0aTO0/tGiC4gn/wTqIPXXbQ/c7BQ72IJT3aKVWZgvmHPQQNZ40EKntzouHW2J95J5ZHVSO+VIPpTrhs/ZF395D8FFA60IS4p+yQR2nh8BXpn+FXSNz6Pes27Yue7uZtXyZQ4gfZMjqV5eMhnW7rvopnv6wmvQv8ACDHn6ZeQzD2idRuUyBZ8M1Yzn+auPts3xWLn/wAqn/PX+WlV/c3MA+QpV5dz8ejz+vJnx15Tqo4asgJ7dSK13Q19r1hRJQ5nJKBRPW2IIIjXgJrJJ0/iVjryI+0oOtaToHE3rttWLoGJYa2yePGHUennXbrT/P459G/6S7+DLZZdzBiS2WNd9IioagJiLDuz5Uu5jmd2+qpJIBJB41Z4oraze/uoGI6kLkMz1pBdiwGmgjvqk6e6Xse6yZQzPmVW0kEqQzDSICg8z8a49Pp5W7+O2XUxks15UuI6Zx+PZipdUEkKkKBObKn1TnbRhw+qdeqxrNMpJedYBIOY6xHIDn6VqfZoPZse8S9kRb12RlVpyIrDfVZQPEEfbPfmExIzZQsK+WJ3XKWPrlFeuePEeWhtZICnjrILORAMaHNvvpFENnrsCRlAJmCT2E9bUeW9cGKlAwAGTLoOJUh2Pedq6cVDrCjrj93MczAeVXZoz3PV1y5pAnLI2lhvuBrPGlcwq9XRdpYZBO+hBnYj4eTreKJLpAAUkzGpMxr4Cn2b3vFYaKVBVNOKqAoPOJO/IVNiV0J0KMS5ClVRYzEATqzKoBOkkq520VGOugM7Gey7JdVAjOHLBY3JXLmC5o2zDXqg66cu+yGH6lwredWW7bJyEqxQnJJg6hWKqZkD3kkb1a9OdOvbNpGZ3a2ZysuVgxRAB2yVzHsfjTZpnWvBUyXCqsjXEIMSwkOpIXTRjEidIqIt5ZiU8Hk+WWnYLoC5cXOtp7kFpZFcjMTJ6wHWOsTUy30PixouHvAcgjgfCtSpUdXPCP3Hb4EU9Lzcif1bbD4saFcvXUJUlwRuNZB5d9Qr2PymCde2WPiJ/GnKX6XGz3FmcQ/BLnjkX4g/Cgvi8QNlY/uH0UAmq9+lRwB+Brn+bnTqx471dxNOX+mL0wxII4dZCO8AzUXEYl2+v/Ezk+RM1Y3b63VMmHiEcaDfY8uU1Rkef41FHw+HZld1yjJB3IOoY6CeSn0omEw6OQGLCRMrBA1AgrBPH8jWoylhIBiRBE7jtprOYA2A5c+08dZ32moJidK30lVusQCQJhtAeGYGB2U7/PsT/wC5/An8tVprk0FqvT2JkD3sfsp/LUq50xeVo+kk9qpbjbtYd3hVBNOt3SpBHAgwdQY5jiKbNL3/ADy+CR74kATmypOwkRqOI48PGu4np/EowAvZxEzkVeJEQR2VSXL5Z2eFBYsYA0BYz1ROm+lDLE7meHhwFXaajQ4X2jxLkg3UWATLKsGOA03p/wDqa/BIuWyQNsh17BWarpJJ4knT5U2ai/PtXe4pZO26HiJ+9XD7UOd7OHP/AOZ/mqtwqB7mwIAHdlUBQY7gPOrX3mHUf8FW4TA4drEA+FIXQR9oR9rDYY//AJ/91ab2T6ZFnG2ibSJOZXCIqtBQnLJ31C8RqBvWbOJw/G0nko+B/Gpy9IC5dRwWktLgmRpsRqQKX0seyYX2iw91RcS+uVpiSyncgyCNNQaVYropVuW8/wBbM90gzMj3jx6Uq4cY7cv4Q6SxDW2ZLrgypBm2SBDzsgETB8O+tT0BiMQ2Yg5wHuASwXQOQBosaDTeedJfYzXJ726MwzZgEkFerH1I1Dk/sirbo/DphVhy3XYsGYoOs5koBImCY2rWW6xj4YC5/ixbJZkw9x5gAM8HTuB46+NY/wBoulHxGIzlGBIzaTlUtb6qA8csxPOa9pxvSmDAKB0Vp2APMTBVSD4Vk/a3FWPeW7Sy43crPVlWkNMQYKnrQNudJlfUhxnu15nd6dJtm2ihVczc1kuVJZdDoDOsjXUiSC2boU+/QRoEHwNQEwpRhmyuBIKgkTpEQwE6mjfTWJJCPm0jT6o224cR51tk+yjG0wG5Iy8Psqd++aNlOdOxVnuIf8YoC4ownUaAFB00YxEg8TJ0HcN9aPhb5LkKjMzAZVykkAE7Lvx3/IAdre8exvjc+VMuMVskjQ59P3hz/tvVoMCzIEiHdrgy7nm0kbfW2g8ZPAQscm6EEQIgZgQw4HMBJnQ+HKmg7B+0ly2VKqgYSMwUSA2j6R1pG4bMDxqTjsYSVuNmcsDtLaaCdBEcAOS91UCWCSJUxx4GOVGx91mMlWVYABIjb050G36J9vrlu2llMMkLIBKss7nWDE1Zf6/u5WJsWxA4ZydSBoPHjpXlatOg1PnXGuGYE0FxiMewGuo1OojUnQAacTPd4VUFp3OvPtpiox2Gv9qOMEeLAeE/jUkk9NW3L3Q81dBp/wBDPBh4yPnQntMv1hHbwPjVZHsNE/nv9K5iXMg9nqN/wPjTrS9Se3+34+VNAzEKATJgBdyeAGh1Ij92rEBzGmsa0KdGMzmMNcEzoVYawYAnQa9kbeNRYKgBmCsJZSDxIg6HUjcc+6gh0qLcClmyiFkwOzhTCtA2lTiK5FB0AQez5j502pFowAI1OadtAYA1O2oPnXMVdDZdACBBIET2/HgO6gBTk4nwHef6T6U2jJbkqvmeU7nwEeRoJeF6iTMF9Z4hROv+49ulQLjSZj+g4DuAo965mJgaHRR+iIgegHgaf7pQIiT3mrRDmrHo26iujPqgdSw5qGGcc9Vn0oYwYI0OU9swfOi4TDq7C2xW2WaAzsVQRvmIB07gdxUV9GWOjrVtQlpbaIPqqFEAHXTvmfGlWb6G6Uu+4tAYvCNlRVmXMlBlJnSdRyFKvN5/K7bn63f0FZks5Pa01477XdM4lMdibdu4yJbNvKNPqsi8I+9mPjXtqqOFebf4lexVy+/0rCjNcygXLexcKIVlP3gAAV4gCNRr3kcXn2I9qL6gC5iLxzbZPdxAMHMCpIMjy7xVfiulWgM1zODBAzIW11GZViPEAiqzpFbgbLcR0dAAVZCGGgiVMEaRv2VGbENoNwNBmHwmtcjS5T2iIEZbmn/2wPLIY7pNc/1CfuP/AM3/ALKpcp5rr2H5V0Kea+vyqcjS6/z/APQuf83/ALKOvTpA+syTvs7nunqgTx7NBxqik8cnkflT1ZQomJE9o3kba8TV5Gl63SmVA4uXACNBltgnUj7sbjjTreJvNEO0HMJLIACphlkgSRvAkwREyJo3x0qFDZREdXTixkkjT63pRLfSmRnKD65nWZVocEqwjg7jx4U3RZXsZcVipZ5BIMFCNORoLY9gCSX0BOuThrGknhyqnfEanLmjt38TXFuMamzSxxPSHVH2ZAOpLMQdQQIA486j2ERjpqx1M68NuVQrzTpv3VZ9D2wM7t9VBGv2nbZfQk9goDe6gakAfn8/Kgi+g4Ek9vHw8ONR8diix1M7/L5fDhUIqTJAmBM6bCgtEv2zplM8xr/1R/eiBdNCGU6Ef0qnWQZgwTGmvh61OtXMrET3DjHb2fMUBblsKJX6p01+ydxUG6h/EeGvzqzft2O/z8KgX7qroZkE8DB7j61UBGJeAA7wNhmaB4TQyx51xuwGO6uqTwn1oFmFNmaMXaAJPE784/AD1rhL828zQDCE7A+VdFo8QQOJI2/PKiC054H1pDCtyoBMZPw7ANh5Uvdns8x86N9GbkPOl9FfkKAERvHnv2VOtYeLT3cwOoQATMuCSduQI/aoK4X7xju+ZFK6pAIDsRvE6E0DsNbkzy08f7z50W/cCCB9Y+nbR8BbhJ8fSod5c0todcsSNNMwIJ7j51FOs58ruTomXNM/abKIGxPHuBol22CwbUFYOmsga78vnTjbIUIZh3U6SRlVSAfEODUz2ewSYi/asszBXfJIHWHEQDxMgUoYrAbzSr23C9A2LSLbXDAhREsuZjxMnjrSrl3f43w/ouHxzjYr6/GTVpY6ReNz4a/EVBsog1nzAP4TUi1jlXgh/ZA9Zqefg8D9ssY1/F4m6Zk3XHblRsifwqNqokcnST51a9OoUxN9TuL1zyztHhBB8aiYW4Eu27uUNkZWKnZgrAlTod4jY11YAKHiT4V3J+ka0PtZ0Q9sre+jiwl3VUVi4QwCVzZQBIMhdRAMbQM0XjeaKLlP3j+fGkFP3qfhbD3GyojO0TlRWYxtMAE8R501xlYqxhlJBB5gwR5jhQcOf8im5GPH1p5cfeFXKeymNO2Gu/ux8YoKEqddfWg5idyTVl0t0RiLGUXbTW885c0CcsZo17R51CwyHOsxE8xRE7B4MaFv3fn+flVj0g+VEQabsRED7q/A/vUC22v55D5U3Hvmydyj+LWqISIrO0mBw1mAPxjj31JOHX3jL71AGA60krLKCyyBqRJnhIidQajYd1EDZgVMjWMsSRGvCpN4qxFu3Zhwzbli2mYkMDAEAEwBw76BlguABsqmDMqrMpBMnYsBlMTpoajOgDGDI4HUE98/HyornKBJBknqiZXQdcDaI071PZScIzplLZAFBaOtuZJExMHad+NBMw75k1GoMVCuXyrdhGoOxjTUeAq4uBCbhQAJPVidtOBJg8PCqbFodDrBLAGNCREgHskeYoCDFr+SKQxSDgPOoLfnQCi2EmSTAUTvqTIAAHHfwrW6molfTRwHxNcON7PQ1DuAzr6bVrvYH2Zt4trj3g4tpCrkYKWc6nrEHYRP6wrNujTOfTeQ8gPnXPprcvQV7An+H3R43t3GHM3/AIwBFH/0N0YP/TOe6++v8YqdyNcXij4xvyT8qG+Kbs85/GvbT7CdGkhvcXAN8ouswPYYct61p8MmFRQqYdEA0AFmNOGuWp3InF86dFYM4h8nvrNrQnNebImhAy5oOuvHkaiYi2VdlJVirFZUypKmJU8QY0NfS2LGFuLlu2rTrydEjwDDSvBvazo9LOOvogCoGDIB9UK6hgF7BmjwpMpRGtPCGg2SQVKaFg6sSAQZYgA8OI1Go1I2pyt1YqFmImCeemmmsjz/ABrUB8yqIZY0g65iVIWMvARw8e2p3RD5rtn3cqTeRVJ0gkqAZHKQap10ILAxofz36mtb7DYUPjbEaKhe4e5V6p/eyedTK6lpGsfBYqf/ADX8b/OlW09/+mfIfKuV5e7fxvjf1W207Ce0BTp8aJ71F0JI7+qPWBUD6S3Fz/DS+k/eZiOxlX0ArvIztgv8RMBlvi8oOS6ok7jOoCnY8UCkcyG5VjSYr2DpHB2r6NbddGEyGkg8GB4Ef02rzDproe5h3hxKk9Vx9Vv5T+ifUa1uIvei/aB8SmGwF0otkOuZ2MMyJqluZGXQZQQZPV7ZL0l0JgreO+jvedLLWw2aVOVySQmYqQFyjcydRJrE99PtSplTB7KqL/p69bw2IX6BddVCBGcMwLMSc3W0lcuXYZdNKz99wTA2HH8B2V24pbUsT3mu4fDM7ZVGvEnQDtJqi49juiPpGJQESlsh3kaZVOinnmMCOU8q9pbEN2fvEV590HetYW3kVpLau2xZvPQDgPmal3PaBOc+ZppLWh6bwqYm37u9bkDVWVuspiMykxr3yDxFZbC+xuFVpdrj6HKCVADcGOXUkbx5zTX9ol4D4UB/aVuH4VnjSVlApUlW+sCVbsYGD6ile1H540fpW8Hc3Bu5lv1ufj8ailqrSZhsLbuWnm4qXQ+aHYKr2yF6oJMBgwbzAPAiLfRygID5FU9YKYiSACecEnX71DZZBAMdtFt4xgoSDAI4iCAcx07dRFNCyOAa0TiGVHtoUGRyFNxQAoYAbAmGg6mTpzpUVndiTq5LNp1dSSdOU0+3ez5c7FlXTLMScsAzrrJ5cO2j4W1BJYnLOi7T39lNG0p7YtWgs7yx5xrl04SNYqfhktPghackOWd1I1CsdBpOxUAH5iaosbii7Eb86IcYQIAjgOymtptX37bISrcOWo86EGqUbhNMINU2HbXMQJA7TsK9D6H6atYe0lpD1V45TJY6sx1GpPloOFYATRQ550s2belf6nXi5/PjTD7TL9494n5V5zmbnTgzVnhDlXoX+qV2ztHf/WjW/alB9s+hrzgFq7mNS4ReVem2/akfePlA+FZf23urfy30PXUZW7VklWH6pJH7Q5VnBcP9qcbrcz8fjSYyXcNoiPQ2AmDtw8dxXTYJOlOGFY1Q5STOY9UhREk6CY+J869I9gMKiI992yNcARBGuQGS232mg9yg7GvPsP0c066jlw8a1uDuXCuragbAwNNu4VjqXeOlx8VuHuLP/Gb+ClWWzXOY/eX+alXm4f102sLmLA39YqNd6TCzrJ7J/CaqCz9h7ZCny1nzFALkmNAeRJB/r4V69OSfc6bOwWO/X4xVL0n0qzgqTIPCNI7edEuqRpIqE9me01uRFI9kTpp8KZ7mrd8MO3yoRw1XSbVgt1Jsvl04UcWacLdNGzRd7T8fjTTdajBfzFIiqm0c3DyppejkCuZAaaNo5M0wsR2ipXuRy1prWfzM1LF2jB+WtP8AejjTjh+71FdGG7J7jU1V3DfpCimNfZtF07aL9GX++lOFkcKaTYaW4G9IrRfdU73VXRtGKUsg5VJNqu+7po2jC3+ZpwQ0fJSK00bBCn86fOnAHl608V2RTSbDB/O9PUjsp0jhpXRTQeDSc6U3IOVOKd/nTQSipFtRQV0/IoqP3Hwj1rNjSdh213/PlVtafkI10BEHt1+dUQvkfZ/PjUm3iwsNl20757jXPKVZYvvf/oj9/wDrSql/zIfeHma5WOOTe8Upr2ny0oL3Qe388aVKvRHJG91JhSQe/TyI08KCwYaQD3aeh+dcpVpAcwbbhXSOZpUqqUMrTStKlVDctdy0qVAslcyzpXaVRCKxSC0qVFIxSyd1KlUUgBtQyg5UqVAhb7fz41yDzpUqBFuc+kUkZTqD8aVKg5pxrs0qVAia5mFKlQOzjlSzUqVB0MK770fmaVKgQcU9btKlWWizDejJej512lUHfpA+8fWuUqVND//Z';
        Test.startTest();
        Id recordId = [SELECT Id, IsActive FROM Product2 WHERE IsActive = true LIMIT 1].Id;
        String cdlId = CommunityController.uploadFile(base64, 'download', recordId);
        Test.stopTest();
        System.assert(cdlId != null, 'ID null');
    }

    @isTest
    public static void simulatorTest(){
        List<CommunityController.SimulatorProperties> totalRows = CommunityController.simulator(289900, 93000, '24');
        System.assertEquals(25, totalRows.size(), 'The table does not have 0-24 rows, must be 25 rows');
    }
}

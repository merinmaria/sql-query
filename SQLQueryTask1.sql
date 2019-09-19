-- 1)list of all property name and id for owner id 1426
-----------------------------------------------------------------------
SELECT [dbo].[Property].Id PropertID,
[dbo].[Property].Name AS property ,
[dbo].[OwnerProperty].OwnerId 
FROM Property
LEFT OUTER JOIN  OwnerProperty
      ON Property.Id=OwnerProperty.PropertyId
WHERE OwnerProperty.OwnerId=1426
------------------------------------------------------------------------
--2) current home value
-------------------------------------------------------------------------
SELECT [dbo].[Property].Id PropertID,
[dbo].[Property].Name AS property ,
[dbo].[OwnerProperty].OwnerId ,[dbo].[PropertyHomeValue].Value HomeValue
FROM Property
LEFT JOIN OwnerProperty
  ON Property.Id=OwnerProperty.PropertyId
INNER JOIN PropertyHomeValue
  ON OwnerProperty.PropertyId=PropertyHomeValue.PropertyId
WHERE OwnerProperty.OwnerId=1426 
AND PropertyHomeValue.HomeValueTypeId=1
AND PropertyHomeValue.IsActive=1
--------------------------------------------------
--3) sum of all the payment from start date to end date  
---------------------------------------------------------------------------------
SELECT dbo.Property.Id PropertID,
Property.Name  property ,
OwnerProperty.OwnerId ,
[StartDate],
[EndDate], [PaymentAmount] ,
 [dbo].[TenantPaymentFrequencies].Name Frequency,
 [dbo].[PropertyHomeValue].Value,
CASE
WHEN [PaymentFrequencyId]=1 
   THEN DATEDIFF(WEEK,[StartDate],[EndDate])*[PaymentAmount]
WHEN [PaymentFrequencyId]=2
   THEN DATEDIFF(WEEK, [StartDate],[EndDate])/2*[PaymentAmount]
ELSE DATEDIFF(MONTH,[StartDate],[EndDate])*[PaymentAmount]
END AS SumOfPayment
FROM [dbo].[TenantProperty]
INNER JOIN [dbo].[TenantPaymentFrequencies]
  ON [dbo].[TenantProperty].PaymentFrequencyId=[dbo].[TenantPaymentFrequencies].Id
INNER JOIN Property
  ON Property.Id=TenantProperty.PropertyId
INNER JOIN OwnerProperty
  ON OwnerProperty.PropertyId=TenantProperty.PropertyId
INNER JOIN PropertyHomeValue
  ON OwnerProperty.PropertyId=PropertyHomeValue.PropertyId
WHERE OwnerProperty.OwnerId=1426 
AND PropertyHomeValue.HomeValueTypeId=1
AND PropertyHomeValue.IsActive=1
-----------------------------------------------------------------------------------------
--b)display yield
----------------------------------------------------------------------------------------
SELECT dbo.Property.Id PropertID,
Property.Name  Property ,
OwnerProperty.OwnerId ,
 [dbo].[PropertyFinance].yield,[dbo].[PropertyFinance].currenthomevalue
 ,
 CASE
WHEN [PaymentFrequencyId]=1 
   THEN DATEDIFF(WEEK,[StartDate],[EndDate])*[PaymentAmount]
WHEN [PaymentFrequencyId]=2
   THEN DATEDIFF(WEEK, [StartDate],[EndDate])/2*[PaymentAmount]
ELSE DATEDIFF(MONTH,[StartDate],[EndDate])*[PaymentAmount]
END AS SumOfRentalPayment
FROM [dbo].[TenantProperty]
INNER JOIN [dbo].[TenantPaymentFrequencies]
  ON [dbo].[TenantProperty].PaymentFrequencyId=[dbo].[TenantPaymentFrequencies].Id
INNER JOIN Property
  ON Property.Id=TenantProperty.PropertyId
INNER JOIN OwnerProperty
  ON OwnerProperty.PropertyId=TenantProperty.PropertyId
INNER JOIN [dbo].[PropertyFinance]
  ON OwnerProperty.PropertyId=[dbo].[PropertyFinance].PropertyId
WHERE OwnerProperty.OwnerId=1426 

--------------------------------------------------------------------
--4-display jobs available in the market place (owner to service supplier)
------------------------------------------------------------------------------
SELECT [JobDescription] AS Job,
Job.OwnerId,
Job.ProviderId,
Job.PropertyId,
ServiceProviderJobStatus.Name Status,
Job.JobStatusId
FROM [dbo].[Job]
INNER JOIN JobMedia
  ON Job.Id=JobMedia.JobId
INNER JOIN ServiceProviderJobStatus
  ON ServiceProviderJobStatus.Id=Job.JobStatusId
LEFT JOIN [dbo].[JobQuote] 
  ON [dbo].[Job].JobRequestId =[dbo].[JobQuote].[JobRequestId]
WHERE JobMedia.IsActive=1 and Job.JobStatusId in(1,3,2)
--------------------------------------------------------------------------
--5e display property name ,tenants and rentel payment
----------------------------------------------------------------------------
SELECT dbo.Property.Id PropertId,
Property.Name  Property ,
Person.FirstName  TenantFirstname,
Person.LastName TenentLastname,
TenantProperty.PaymentAmount  Rent,
TenantPaymentFrequencies.Name  Frequency
FROM TenantProperty
INNER JOIN Property 
  ON Property.Id=TenantProperty.PropertyId
INNER JOIN Person
  ON TenantProperty.TenantId=Person.Id
INNER JOIN TenantPaymentFrequencies 
  ON TenantPaymentFrequencies.Id=TenantProperty.PaymentFrequencyId
LEFT OUTER JOIN OwnerProperty
  ON Property.Id=OwnerProperty.PropertyId
WHERE OwnerProperty.OwnerId=1426
-----------------------------------------------------------------------------------
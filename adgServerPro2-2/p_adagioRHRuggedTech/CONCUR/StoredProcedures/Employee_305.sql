USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 [CONCUR].[Employee_305] 
*/

CREATE PROCEDURE  [CONCUR].[Employee_305]   
AS    
BEGIN 

    DECLARE 
    @empleados [RH].[dtEmpleados]   


    insert into @empleados                  
    Select * from RH.tblEmpleadosMaster


	DECLARE 		
    @IDTipoContactoEmail int,
    @IDActiveConcur int,
    @IDSupervisorConcur int ,
    @IDEmployee int
	;

    if object_id('tempdb..#tempHeader') is not null drop table #tempHeader;    
	create table #tempHeader(Respuesta nvarchar(max));    
  
	insert into #tempHeader(Respuesta)  
	select     
		  replace([App].[fnAddString](3,'100','',2),' ','')--Transaction Type 
        + ','
		+ replace([App].[fnAddString](1,'0','',2),' ','') --Error Threshold
        + ','
		+ replace([App].[fnAddString](7,'Welcome','',2),' ','') --Password Generation
        + ','
		+ replace([App].[fnAddString](6,'UPDATE','',2),' ','') --Existing Record Handling
        + ','
        + replace([App].[fnAddString](4,'EN','',2),' ','') -- Language Code
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','') -- Validate Expense Group
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','') -- Validate Payment Group


    Set @IDTipoContactoEmail = (Select IDTipoContacto from rh.tblCatTipoContactoEmpleado where Descripcion = 'EMAIL CORPORATIVO')
    Set @IDActiveConcur = (select IDDatoExtra from rh.tblCatDatosExtra where Nombre = 'CONCURACTIVE')
    Set @IDSupervisorConcur = (select IDDatoExtra from rh.tblCatDatosExtra where Nombre = 'SUPERVISORID')
    set @IDEmployee = (select IDDatoExtra from rh.tblCatDatosExtra where Nombre = 'SUCCESSFACTORID')


    if object_id('tempdb..#tempBody') is not null drop table #tempBody;    
	create table #tempBody(Respuesta nvarchar(max));  

    insert into #tempBody(Respuesta)
    select     
          replace([App].[fnAddString](3,'305','',2),' ','')
        + ','
        + replace([App].[fnAddString](32,ISNULL(e.Nombre,''),'',2),' ','')--2. First Name
        + ','
        + replace([App].[fnAddString](32,ISNULL(e.SegundoNombre,''),'',2),' ','')--3. Middle Name Only if ID has it
        + ','
        + ISNULL(e.Paterno + COALESCE(' ' + e.Materno,''),'')--4. Last Name
        + ','
        + replace([App].[fnAddString](48,ISNULL(employee.Valor,''),'',2),' ','')--5. Employee ID
        + ',' 
        + replace([App].[fnAddString](48,ISNULL(ce.[Value],''),'',2),' ','') --6. Login ID (EMAIL) 
        + ','
        + replace([App].[fnAddString](48,'welcome','',2),' ','')--7. Password (Not necesary)
        + ','
        + replace([App].[fnAddString](48,ISNULL(ce.[Value],''),'',2),' ','')--8. EMAIL ADRESS
        + ','
        + replace([App].[fnAddString](5,'es_MX','',2),' ','')--9. Locale Code 
        + ','
        + replace([App].[fnAddString](3,'MX','',2),' ','')--10. Country Code
        + ','
        + replace([App].[fnAddString](6,'','',2),' ','')--11. Country sub code
        + ','
        + replace([App].[fnAddString](20,'S4','',2),' ','')--12. Ledger Code
        + ','
        + replace([App].[fnAddString](3,'MXN','',2),' ','')--13. Reinbursment Currency code
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--14. Cash Advance Account Code
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--15. Active
        + ','
        + replace([App].[fnAddString](20,'EP1CLNT200','',2),' ','')--16. Organizational Unit /* sequential 16 - 21 */
        + ','
        + replace([App].[fnAddString](4,'3004','',2),' ','')--17. Organizational Unit
        + ','
        + replace([App].[fnAddString](6,'OTHERS','',2),' ','')--18. Organizational Unit    
        +','
        + replace([App].[fnAddString](2,'CC','',2),' ','')--19. Organizational Unit
        + ','
        + replace([App].[fnAddString](20,ISNULL(cc.CuentaContable,''),'',2),' ','')--20. Organizational Unit
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--21. Organizational Unit
        + ','
        + replace([App].[fnAddString](20,'N','',2),' ','')--22. Custom /* sequential  22 - 41 */
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--23. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--24. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--25. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--26. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--27. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--28. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--29. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--30. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--31. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--32. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--33. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--34. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--35. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--36. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--37. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--38. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--39. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--40. Custom 
        + ','
        + replace([App].[fnAddString](20,'','',2),' ','')--41. Custom 
        +','
        + [App].[fnAddString](14,'RTMX EMPLOYEES','',2)--42 Employee Custom

        /*Employee Preferences: Workflow*/

        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--43. Send email when the cash advance status changes .Default = Y [CONCUR].[Employee_305] 1
        +','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--44. Send email whena cash advance is awaiting approval .Default = Y
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--45. Send email when the report status changes .Default = Y
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--46. Send email when a report is awaiting approval. .Default = Y
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--47. Prompt for approver when submitting a report .Default = N
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--48. Send email when the request status changest .Default = Y
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--49. Send email whena request is awaiting approval .Default = Y
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--50. Prompt for approver when submitting a request. Default = N 
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--51. Send email whenthe payment status changes. Default = Y
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--52. Send email whena payment is awaiting approval. Default = Y
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--53. Prompt for approver when submitting a payment. Default = N

        /*Employee Preferences*/

        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--54. Prompt to add company card transactions to report. Default = Y
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--55. Send email when new company card transactions arrive. Default = Y
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--56. This field has been decommissioned
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--57. Display instructional help on the application pages. Default = Y
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--58. Display imaging introduction page. Default = Y

        /*Approvers*/

        + ','
        + replace([App].[fnAddString](48,ISNULL(case when supervisor.Valor is not null then case when CAST(LEFT(supervisor.Valor, 1) + REPLICATE('0', LEN(supervisor.Valor) - 5) AS INT) = 1000 then '000' + supervisor.Valor Else supervisor.Valor end end,''),'',2),' ','')--59. Employee ID of the Expense Report Approver --Agregar 000 a los que empiecen con 1000
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--60. Employee ID of the Cash Advance Approver 
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--61. Employee ID of the Request Approver
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--62. Employee ID of the Invoice Approver

        /*Non-Group Roles*/
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--63. Expense User. Default = Y   
        + ','
        + replace([App].[fnAddString](1,ISNULL((Select top 1 'Y' 
                                        from rh.tblDatosExtraEmpleados ex
                                        Inner join rh.tblDatosExtraEmpleados active on ex.IDEmpleado = active.IDEmpleado and active.IDDatoExtra = @IDActiveConcur and active.Valor = 'TRUE'
                                        where ex.IDDatoExtra = @IDSupervisorConcur 
                                            and ex.Valor = employee.Valor),'N'),'',2),' ','')--64. Expense and/or Cash Advance Approver. Default = N
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--65. Company Card Administrator

        /*Non-Group Roles*/

        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--66. Future Use
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--67. Receipt Processor. Default = N
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--68. Future Use
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--69. Import/Extract Monitor. Default = N
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--70. Company Info Administrator. Default = N
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--71. Offline User. Default = N
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--72. Reporting Configuration administrator. Default = N
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--73. Invoice User. Default = N
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--74. Invoice Approver. Default = N
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--75. Invoice Vendor Manager. Default = N
        + ','
        + replace([App].[fnAddString](3,'','',2),' ','')--76. Expense Audit Required. One of these:• REQ: Required conditionally • ALW: Always required • NVR: Never required
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--77.BI Manager Employee ID. 48 characters maximum
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--78. Request User. Default = N
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--79. Request Approver. Default = N
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--80. Expense Report Approver Employee ID 2. 48 characters maximum    
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--81. A Payment Request has been Assigned. Default = Y
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--82. Future Use. 
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--83. Future Use.
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--84. TaxAdministrator. Default = N
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--85. FBT Administrator. Default = N
        + ','
        + replace([App].[fnAddString](1,'Y','',2),' ','')--86. Travel Wizard User. Default = N
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--87. Employee Custom 22. 48 characters maximum
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--88. Request Approver Employee ID 2. 48 characters maximum
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--89. Is Non Employee. Default = N
        + ','
        + replace([App].[fnAddString](7,'','',2),' ','')--90. Reimbursement Type. • ADPPAYR: ADPPayroll •CNQRPAY:  Pay by Concur •APCHECK: Accounts Payable/Company Check •PMTSERV: Other Reimbursement Method
        + ','
        + replace([App].[fnAddString](1,'','',2),' ','')--91. ADP Employee ID. 
        + ','
        + replace([App].[fnAddString](1,'','',2),' ','')--92. ADP Company Code. 
        + ','
        + replace([App].[fnAddString](1,'','',2),' ','')--93. ADP Deduction Code.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--94. Budget Manager Employee ID.
        + ','
        + replace([App].[fnAddString](1,'','',2),' ','')--95. Budget Owner.
        + ','
        + replace([App].[fnAddString](1,'','',2),' ','')--96. Budget Viewer.
        + ','
        + replace([App].[fnAddString](1,'','',2),' ','')--97. Budget Approver.
        + ','
        + replace([App].[fnAddString](1,'','',2),' ','')--98. Budget Admin.

        /*FUTURE USE  (sequential = 99 - 137)*/


        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--99. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--100. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--101. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--102. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--103. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--104. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--105. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--106. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--107. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--108. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--109. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--110. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--111. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--112. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--113. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--114. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--115. Future Use. 
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--116. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--117. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--118. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--119. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--120. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--121. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--122. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--123. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--124. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--125. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--126. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--127. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--128. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--129. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--130. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--131. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--132. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--133. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--134. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--135. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--136. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','') --137. Future Use. 
        as Result
        
	FROM @empleados e 
     Inner join rh.tblDatosExtraEmpleados active on active.IDEmpleado = e.IDEmpleado and active.IDDatoExtra = @IDActiveConcur
     Left join rh.tblDatosExtraEmpleados supervisor on supervisor.IDEmpleado = e.IDEmpleado and supervisor.IDDatoExtra = @IDSupervisorConcur
     Left join rh.tblContactoEmpleado ce on ce.IDEmpleado = e.IDEmpleado and ce.IDTipoContactoEmpleado = @IDTipoContactoEmail and ce.Predeterminado = 1
     Left join rh.tblDatosExtraEmpleados employee on employee.IDEmpleado = e.IDEmpleado and employee.IDDatoExtra = @IDEmployee
     Left join rh.tblCentroCostoEmpleado cce on cce.IDEmpleado = e.IDEmpleado
     Left join rh.tblCatCentroCosto cc on cce.IDCentroCosto = cc.IDCentroCosto
    Where IDCliente = 1 and active.Valor = 'TRUE'

    

    Select * from #tempHeader
    Union all 
    Select * from #tempBody

END

GO

USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create proc Utilerias.spEliminarDuplicados
as
	declare @Ref varchar(max) = 'Copia el siguiente código y cambia los nombres correspondientes!' 

	print @Ref
	select @Ref
	---- CTE que elimina los colaboradores duplicados	
	--WITH TempEmp (IDEmpleado,duplicateRecCount)
	--AS
	--(
	--SELECT IDEmpleado,ROW_NUMBER() OVER(PARTITION by IDEmpleado ORDER BY IDEmpleado) 
	--AS duplicateRecCount
	--FROM #tempFinalEmpleados
	--)

	----Now Delete Duplicate Records
	--DELETE FROM TempEmp
	--WHERE duplicateRecCount > 1 ;
GO

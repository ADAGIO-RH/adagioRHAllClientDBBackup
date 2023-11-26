USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Borrar plan de accion
** Autor			: Javier Peña
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2023-02-20
** Paremetros		:   
			@IDObjetivoEmpleado int
			@IDUsuario int				
			
				    		  

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE proc [App].[spBorrarPlanAccion](
	@IDPlanAccion int
   ,@IDUsuario int
   
) as

	declare 

        @OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[App].[spBorrarPlanAccion]',
		@Tabla		varchar(max) = '[App].[tblPlanAccion]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	if object_id('tempdb..#tempResponse') is not null drop table #tempResponse;
			
    BEGIN TRY  
	
					SELECT @OldJSON = a.JSON 
                    FROM (
                        SELECT PAO.*,OE.IDEmpleado
                        FROM [App].[tblPlanAccion] PAO
                            INNER JOIN Evaluacion360.tblObjetivosEmpleados OE
                                    ON PAO.IDReferencia=OE.IDObjetivoEmpleado
                              WHERE PAO.IDPlanAccion=@IDPlanAccion
                    ) b
			    CROSS APPLY (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a


                    
            DELETE FROM [App].[tblPlanAccion] WHERE IDPlanAccion=@IDPlanAccion
    

			EXEC [Auditoria].[spIAuditoria]
				@IDUsuario		= @IDUsuario
				,@Tabla			= @Tabla
				,@Procedimiento	= @NombreSP
				,@Accion		= @Accion
				,@NewData		= @NewJSON
				,@OldData		= @OldJSON
				,@Mensaje		= @Mensaje
				,@InformacionExtra		= @InformacionExtra

			SELECT 'Se ha eliminado correctamente' as Mensaje
		    RETURN;

		
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO

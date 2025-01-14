USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de crear un tablero junto con sus configuraciones necesarios para hacer funcionar el 'Dashboard de Tareas'.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:              
    @Titulo 
        Titulo del tablero.
    @Descripción
        Es una descripción breve acerca del tablero.
    @IDsUsuarios
        Son los `IDUsuarios` concatenados por ','.
    @dtEstatusTareas   
        Son los estatus tareas iniciales que tendra el tablero. Se relaciona con la tabla `Tareas.tblCatEstatusTareas`
    @IDUsuario
        Usuarios que ejecuto la acción.    
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/

CREATE proc [Tareas].[spITablero](    
	@Titulo varchar(100),
    @IDsUsuarios varchar(max),   
    @Descripcion varchar(max),    
    @Style varchar(max),
    @dtEstatusTareas [Tareas].[dtCatEstatusTareas] readonly,
	@IDUsuario int
) as
begin
    print 'Comentado por cambios en la tabla Tareas.tblTablero'
    --DECLARE @IDTablero int 
    --DECLARE @TIPO_TABLERO_GENERAL INT
    --SET @TIPO_TABLERO_GENERAL=1;
    
    --INSERT INTO Tareas.tblTablero(Titulo,Descripcion,Style)
    --values(@Titulo, @Descripcion,@Style)
    --SET @IDTablero =SCOPE_IDENTITY()  
    
    --IF( EXISTS(SELECT TOP 1 1 FROM @dtEstatusTareas))
    --BEGIN        
    --    EXEC [Tareas].[spImportarEstatusTareas]
	   --     @dtEstatusTareas =@dtEstatusTareas,         
    --        @IDReferencia=@IDTablero,   
	   --     @IDUsuario =@IDUsuario
    --END

    --IF( ISNULL(@IDsUsuarios,'') <> '')
    --begin 
    --    exec [Tareas].[spITableroUsuarios]
	   --     @IDsUsuarios =@IDsUsuarios, 
    --        @IDTipoTablero=@TIPO_TABLERO_GENERAL,
    --        @IDReferencia =@IDTablero ,
	   --     @IDUsuario =@IDUsuario 
    --end     
    --SELECT [IDTablero], [Titulo], [Descripcion], [IDUsuarioCreacion], [FechaRegistro],Style FROM Tareas.tblTablero WHERE IDTablero=@IDTablero
end
GO

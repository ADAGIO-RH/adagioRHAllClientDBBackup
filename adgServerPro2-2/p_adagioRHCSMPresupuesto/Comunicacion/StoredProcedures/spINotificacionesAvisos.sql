USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-02  
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
 
CREATE PROCEDURE [Comunicacion].[spINotificacionesAvisos] ( 
 @dtDestinatarios [Comunicacion].[dtEnviarNotificacionA] readonly,
 @IDUsuario int =0
)  
AS  
BEGIN  
    
    declare @IDNotificacion int;
    declare @IDTipoNotificacion varchar (255)                    
    declare @htmlbody varchar (max)                    
    declare @subject varchar (max)
    declare @isGeneral bit
    declare @TotalEmailValidos int 
    select  @TotalEmailValidos=count(*) from @dtDestinatarios s where  Utilerias.fsValidarEmail(s.Destinatario)=1 

    if(@TotalEmailValidos>0)
    BEGIN
        set @IDTipoNotificacion='NuevoAviso'    
        set @subject='Avisos'

        insert into App.tblNotificaciones (IDTipoNotificacion,Parametros)
        values(@IDTipoNotificacion,null)                
        
        set @IDNotificacion=SCOPE_IDENTITY();

        insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros)    
        select @IDNotificacion,  s.IDMedioNotificacion,s.Destinatario,0,
                '{ "subject":"'+s.Subject+'","body":"'+REPLACE( s.Body,'"','\"')+'"}'  
        from @dtDestinatarios s
        where  Utilerias.fsValidarEmail(s.Destinatario)=1
    END    
    
END
GO

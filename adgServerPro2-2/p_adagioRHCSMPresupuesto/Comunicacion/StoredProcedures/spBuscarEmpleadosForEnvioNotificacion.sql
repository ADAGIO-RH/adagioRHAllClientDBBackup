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
CREATE PROCEDURE [Comunicacion].[spBuscarEmpleadosForEnvioNotificacion] ( 
 @IDAviso int,
 @IDUsuario int
)  
AS  
BEGIN          
    declare @htmlbody varchar (max)                    
    declare @subject varchar (max)
    declare @isGeneral bit

    set @subject='Avisos'

    select 
		@isGeneral = v.isGeneral,
		@htmlbody='<h1>'+v.Titulo+'</h1><br>'+  
				case when v.IDTipoAviso=1 then '<small>'+v.Ubicacion + ' / ' + FORMAT (v.FechaInicio, 'MMM dd yyyy')+' / '+FORMAT (cast (v.HoraInicio as datetime), 'hh:mm:ss tt') +'</small><br>' else '' end + 
					v.DescripcionHTML,
		@subject=   case when v.IDTipoAviso=1 then 'Proximo Evento' else 'Comunicado de la Empresa' end    
    from Comunicacion.tblAvisos v where v.IDAviso=@IDAviso

    if( @isGeneral = 1 )
        begin                
            select   
				'Email' as IDMedioNotificacion, 
				--COALESCE(ce.[Value],ce2.[Value] ,u.Email) as Destinatario, 
				[Utilerias].[fnGetCorreoEmpleado](m.IDEmpleado, u.IDUsuario, 'NuevoAviso') as Destinatario,             
				@htmlbody as [Body],
				cast(m.IDEmpleado  as int) AS IDEmpleado,
				@subject as [Subject],
				@IDAviso as IDAviso
            From RH.tblEmpleadosMaster  m                
				--left join [RH].[tblContactosEmpleadosTiposNotificaciones]  cetn on m.IDEmpleado=cetn.IDEmpleado  and cetn.IDTipoNotificacion='NuevoAviso'
				--left join [RH].[tblContactoEmpleado] ce on ce.IDContactoEmpleado=cetn.IDContactoEmpleado    
				--left join [RH].[tblContactoEmpleado] ce2 on ce2.IDEmpleado= m.IDEmpleado  and ce2.Predeterminado=1
				--left join [rh].[tblCatTipoContactoEmpleado] ctp on ctp.IDTipoContacto =ce2.IDTipoContactoEmpleado and ctp.IDMedioNotificacion='Email' 
				left join [Seguridad].[tblUsuarios] u on u.IDEmpleado=m.IDEmpleado
            where  
			 --(ce.[Value] is not null or ce2.[Value] is not null or u.Email is not null) and
			 m.Vigente=1
        END
    else 
        begin                 
            select   
                'Email' as IDMedioNotificacion, 
                --COALESCE(ce.[Value],ce2.[Value] ,u.Email) as Destinatario,  
				[Utilerias].[fnGetCorreoEmpleado](m.IDEmpleado, u.IDUsuario, 'NuevoAviso') as Destinatario,
                @htmlbody as [Body],
                cast(m.IDEmpleado  as int) AS IDEmpleado,
            @subject as [Subject],
            @IDAviso as IDAviso
            From RH.tblEmpleadosMaster  m
                inner join Comunicacion.tblEmpleadosAvisos ea on ea.IDEmpleado=M.IDEmpleado and ea.IDAviso=@IDAviso 
                --left join [RH].[tblContactosEmpleadosTiposNotificaciones]  cetn on m.IDEmpleado=cetn.IDEmpleado  and cetn.IDTipoNotificacion='NuevoAviso'
                --left join [RH].[tblContactoEmpleado] ce on ce.IDContactoEmpleado=cetn.IDContactoEmpleado    
                --left join [RH].[tblContactoEmpleado] ce2 on ce2.IDEmpleado= m.IDEmpleado  and ce2.Predeterminado=1
                --left join [rh].[tblCatTipoContactoEmpleado] ctp on ctp.IDTipoContacto =ce2.IDTipoContactoEmpleado and ctp.IDMedioNotificacion='Email' 
                left join [Seguridad].[tblUsuarios] u on u.IDEmpleado=m.IDEmpleado
            where  
			--(ce.[Value] is not null or ce2.[Value] is not null or u.Email is not null) and 
			m.Vigente=1
        end
END
GO

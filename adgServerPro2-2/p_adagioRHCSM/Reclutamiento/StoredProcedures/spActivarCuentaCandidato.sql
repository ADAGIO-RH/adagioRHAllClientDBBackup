USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [Reclutamiento].[spActivarCuentaCandidato](    
	@IDCandidato int,
	@password varchar(max)    
) as   
	
	update Reclutamiento.tblCandidatos
		set
			Password = @Password,
			ActivationKey = null,
			AvaibleUntil = null
	where IDCandidato = @IDCandidato
GO

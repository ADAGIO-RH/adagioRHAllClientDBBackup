USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from Seguridad.tblUsuarios where cuenta = '0424'

CREATE PROCEDURE [Docs].[spBuscarMisDocumentosPendientesAprobacion]--125
(
	@IDUsuario int 
)
AS
BEGIN
	
	declare @TotalPaginas int = 0
		,@DOCS0001 bit = 0
	;      
	
	if exists(select top 1 1 
		from Seguridad.tblPermisosEspecialesUsuarios pes	
			join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
		where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'DOCS0001')
	begin
		set @DOCS0001 = 1
	end;


	if OBJECT_ID('tempdb..#tempAprobadores') is not null drop table #tempAprobadores;

	select * ,ROW_NUMBER()OVER(Partition by IDDocumento order by IDAprobadorDocumento)RN
	into #tempAprobadores
	from Docs.tblAprobadoresDocumentos ad
	where ad.Aprobacion = 0
	or ad.Aprobacion = 2
	and ad.Secuencia = (select max(Secuencia) from Docs.tblAprobadoresDocumentos where IDDocumento = ad.IDDocumento)

	Select 
	 d.IDItem
	,d.TipoItem
	,d.IDParent
	,d.Nombre
	,d.FilePath 
	,d.[Descripcion] 
	,d.[Version] 
	,d.[PalabrasClave] 
	,d.[Comentario] 
	,isnull(d.[ValidoDesde],'1900-01-01') as [ValidoDesde]
	,isnull(d.[ValidoHasta],'9999-12-31') as [ValidoHasta] 
	,isnull(d.[Expira],0) as [Expira] 
	,isnull(d.[DiasAntesCaducidad],0) as  [DiasAntesCaducidad]
	,isnull(d.[IDTipoDocumento],0) as [IDTipoDocumento] 
	,isnull(td.[Descripcion],'') as [TipoDocumento] 
	,isnull(d.[Icono], case when TipoItem = 0 then 'fa fa-folder-open-o' else 'fa fa-file-o' end) as [Icono]
	,isnull(d.[IDAutor],0) as [IDAutor]
	,isnull(d.[IDPublicador],0) as [IDPublicador]
	,isnull(d.[FechaCreacion],getdate()) as [FechaCreacion]
	,isnull(d.[FechaUltimaActualizacion],getdate()) as [FechaUltimaActualizacion]
	,isnull(d.[Visualizar],0) as  [Visualizar]
	,isnull(d.[Descargar],0) as [Descargar] 
	,isnull(d.[Color],'#000') as [Color]
	,ROW_NUMBER()Over(Order by IDItem asc) as ROWNUMBER
	from Docs.tblCarpetasDocumentos d
		left join Docs.tblCatTiposDocumento td
			on d.IDTipoDocumento = td.IDTipoDocumento
	where 
		 ((d.IDPublicador = @IDUsuario) OR (@DOCS0001 = 1))
		AND (((d.Expira = 1) and getdate() > ( dateadd(DAY,-(d.DiasAntesCaducidad),d.[ValidoHasta])))
			OR (d.IDItem in (select IDDocumento from #tempAprobadores))
			)
END
GO
